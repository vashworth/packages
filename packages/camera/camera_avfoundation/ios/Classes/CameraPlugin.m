// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraPlugin.h"
#import "CameraPlugin_Test.h"

@import AVFoundation;

#import "CameraPermissionUtils.h"
#import "CameraProperties.h"
#import "FLTCam.h"
#import "FLTThreadSafeEventChannel.h"
#import "FLTThreadSafeTextureRegistry.h"
#import "QueueUtils.h"
#import "messages.g.h"

static FlutterError *FlutterErrorFromNSError(NSError *error) {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
                             message:error.localizedDescription
                             details:error.domain];
}

@interface CameraPlugin ()
@property(readonly, nonatomic) FLTThreadSafeTextureRegistry *registry;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property(nonatomic) FCPCameraGlobalEventApi *globalEventAPI;
@end

@implementation CameraPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/camera_avfoundation"
                                  binaryMessenger:[registrar messenger]];
  CameraPlugin *instance = [[CameraPlugin alloc] initWithRegistry:[registrar textures]
                                                        messenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];
  SetUpFCPCameraApi([registrar messenger], instance);
}

- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  return
      [self initWithRegistry:registry
                   messenger:messenger
                   globalAPI:[[FCPCameraGlobalEventApi alloc] initWithBinaryMessenger:messenger]];
}

- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger
                       globalAPI:(FCPCameraGlobalEventApi *)globalAPI {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _registry = [[FLTThreadSafeTextureRegistry alloc] initWithTextureRegistry:registry];
  _messenger = messenger;
  _globalEventAPI = globalAPI;
  _captureSessionQueue = dispatch_queue_create("io.flutter.camera.captureSessionQueue", NULL);
  dispatch_queue_set_specific(_captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);

  [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(orientationChanged:)
                                               name:UIDeviceOrientationDidChangeNotification
                                             object:[UIDevice currentDevice]];
  return self;
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [UIDevice.currentDevice endGeneratingDeviceOrientationNotifications];
}

- (void)orientationChanged:(NSNotification *)note {
  UIDevice *device = note.object;
  UIDeviceOrientation orientation = device.orientation;

  if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown) {
    // Do not change when oriented flat.
    return;
  }

  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    // `FLTCam::setDeviceOrientation` must be called on capture session queue.
    [weakSelf.camera setDeviceOrientation:orientation];
    // `CameraPlugin::sendDeviceOrientation` can be called on any queue.
    [weakSelf sendDeviceOrientation:orientation];
  });
}

- (void)sendDeviceOrientation:(UIDeviceOrientation)orientation {
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [weakSelf.globalEventAPI
        deviceOrientationChangedOrientation:FCPGetPigeonDeviceOrientationForOrientation(orientation)
                                 completion:^(FlutterError *error){
                                     // Ignore errors; this is essentially a broadcast stream, and
                                     // it's fine if the other end
                                     // doesn't receive the message (e.g., if it doesn't currently
                                     // have a listener set up).
                                 }];
  });
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  // Invoke the plugin on another dispatch queue to avoid blocking the UI.
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf handleMethodCallAsync:call result:result];
  });
}

- (void)availableCamerasWithCompletion:
    (nonnull void (^)(NSArray<FCPPlatformCameraDescription *> *_Nullable,
                      FlutterError *_Nullable))completion {
  dispatch_async(self.captureSessionQueue, ^{
    NSMutableArray *discoveryDevices =
        [@[ AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera ]
            mutableCopy];
    if (@available(iOS 13.0, *)) {
      [discoveryDevices addObject:AVCaptureDeviceTypeBuiltInUltraWideCamera];
    }
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
        discoverySessionWithDeviceTypes:discoveryDevices
                              mediaType:AVMediaTypeVideo
                               position:AVCaptureDevicePositionUnspecified];
    NSArray<AVCaptureDevice *> *devices = discoverySession.devices;
    NSMutableArray<FCPPlatformCameraDescription *> *reply =
        [[NSMutableArray alloc] initWithCapacity:devices.count];
    for (AVCaptureDevice *device in devices) {
      FCPPlatformCameraLensDirection lensFacing;
      switch (device.position) {
        case AVCaptureDevicePositionBack:
          lensFacing = FCPPlatformCameraLensDirectionBack;
          break;
        case AVCaptureDevicePositionFront:
          lensFacing = FCPPlatformCameraLensDirectionFront;
          break;
        case AVCaptureDevicePositionUnspecified:
          lensFacing = FCPPlatformCameraLensDirectionExternal;
          break;
      }
      [reply addObject:[FCPPlatformCameraDescription makeWithName:device.uniqueID
                                                    lensDirection:lensFacing]];
    }
    completion(reply, nil);
  });
}

- (void)handleMethodCallAsync:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"create" isEqualToString:call.method]) {
    [self handleCreateMethodCall:call result:result];
  } else if ([@"startImageStream" isEqualToString:call.method]) {
    [_camera startImageStreamWithMessenger:_messenger];
    result(nil);
  } else if ([@"stopImageStream" isEqualToString:call.method]) {
    [_camera stopImageStream];
    result(nil);
  } else if ([@"receivedImageStreamData" isEqualToString:call.method]) {
    [_camera receivedImageStreamData];
    result(nil);
  } else {
    NSDictionary *argsMap = call.arguments;
    NSUInteger cameraId = ((NSNumber *)argsMap[@"cameraId"]).unsignedIntegerValue;
    if ([@"initialize" isEqualToString:call.method]) {
      NSString *videoFormatValue = ((NSString *)argsMap[@"imageFormatGroup"]);

      [_camera setVideoFormat:FLTGetVideoFormatFromString(videoFormatValue)];

      __weak CameraPlugin *weakSelf = self;
      _camera.onFrameAvailable = ^{
        if (![weakSelf.camera isPreviewPaused]) {
          [weakSelf.registry textureFrameAvailable:cameraId];
        }
      };
      _camera.dartAPI = [[FCPCameraEventApi alloc]
          initWithBinaryMessenger:_messenger
             messageChannelSuffix:[NSString stringWithFormat:@"%ld", cameraId]];
      [_camera reportInitializationState];
      [self sendDeviceOrientation:[UIDevice currentDevice].orientation];
      [_camera start];
      result(nil);
    } else if ([@"takePicture" isEqualToString:call.method]) {
      [_camera captureToFile:result];
    } else if ([@"dispose" isEqualToString:call.method]) {
      [_registry unregisterTexture:cameraId];
      [_camera close];
      result(nil);
    } else if ([@"prepareForVideoRecording" isEqualToString:call.method]) {
      [self.camera setUpCaptureSessionForAudio];
      result(nil);
    } else if ([@"startVideoRecording" isEqualToString:call.method]) {
      BOOL enableStream = [call.arguments[@"enableStream"] boolValue];
      if (enableStream) {
        [_camera startVideoRecordingWithResult:result messengerForStreaming:_messenger];
      } else {
        [_camera startVideoRecordingWithResult:result];
      }
    } else if ([@"stopVideoRecording" isEqualToString:call.method]) {
      [_camera stopVideoRecordingWithResult:result];
    } else if ([@"pauseVideoRecording" isEqualToString:call.method]) {
      [_camera pauseVideoRecordingWithResult:result];
    } else if ([@"resumeVideoRecording" isEqualToString:call.method]) {
      [_camera resumeVideoRecordingWithResult:result];
    } else if ([@"getMaxZoomLevel" isEqualToString:call.method]) {
      [_camera getMaxZoomLevelWithResult:result];
    } else if ([@"getMinZoomLevel" isEqualToString:call.method]) {
      [_camera getMinZoomLevelWithResult:result];
    } else if ([@"setZoomLevel" isEqualToString:call.method]) {
      CGFloat zoom = ((NSNumber *)argsMap[@"zoom"]).floatValue;
      [_camera setZoomLevel:zoom Result:result];
    } else if ([@"setFlashMode" isEqualToString:call.method]) {
      [_camera setFlashModeWithResult:result mode:call.arguments[@"mode"]];
    } else if ([@"setExposureMode" isEqualToString:call.method]) {
      [_camera setExposureModeWithResult:result mode:call.arguments[@"mode"]];
    } else if ([@"setExposurePoint" isEqualToString:call.method]) {
      BOOL reset = ((NSNumber *)call.arguments[@"reset"]).boolValue;
      double x = 0.5;
      double y = 0.5;
      if (!reset) {
        x = ((NSNumber *)call.arguments[@"x"]).doubleValue;
        y = ((NSNumber *)call.arguments[@"y"]).doubleValue;
      }
      [_camera setExposurePointWithResult:result x:x y:y];
    } else if ([@"getMinExposureOffset" isEqualToString:call.method]) {
      result(@(_camera.captureDevice.minExposureTargetBias));
    } else if ([@"getMaxExposureOffset" isEqualToString:call.method]) {
      result(@(_camera.captureDevice.maxExposureTargetBias));
    } else if ([@"getExposureOffsetStepSize" isEqualToString:call.method]) {
      result(@(0.0));
    } else if ([@"setExposureOffset" isEqualToString:call.method]) {
      [_camera setExposureOffsetWithResult:result
                                    offset:((NSNumber *)call.arguments[@"offset"]).doubleValue];
    } else if ([@"lockCaptureOrientation" isEqualToString:call.method]) {
      [_camera lockCaptureOrientationWithResult:result orientation:call.arguments[@"orientation"]];
    } else if ([@"unlockCaptureOrientation" isEqualToString:call.method]) {
      [_camera unlockCaptureOrientationWithResult:result];
    } else if ([@"setFocusMode" isEqualToString:call.method]) {
      [_camera setFocusModeWithResult:result mode:call.arguments[@"mode"]];
    } else if ([@"setFocusPoint" isEqualToString:call.method]) {
      BOOL reset = ((NSNumber *)call.arguments[@"reset"]).boolValue;
      double x = 0.5;
      double y = 0.5;
      if (!reset) {
        x = ((NSNumber *)call.arguments[@"x"]).doubleValue;
        y = ((NSNumber *)call.arguments[@"y"]).doubleValue;
      }
      [_camera setFocusPointWithResult:result x:x y:y];
    } else if ([@"pausePreview" isEqualToString:call.method]) {
      [_camera pausePreviewWithResult:result];
    } else if ([@"resumePreview" isEqualToString:call.method]) {
      [_camera resumePreviewWithResult:result];
    } else if ([@"setDescriptionWhileRecording" isEqualToString:call.method]) {
      [_camera setDescriptionWhileRecording:(call.arguments[@"cameraName"]) result:result];
    } else if ([@"setImageFileFormat" isEqualToString:call.method]) {
      NSString *fileFormat = call.arguments[@"fileFormat"];
      [_camera setImageFileFormat:FCPGetFileFormatFromString(fileFormat)];
    } else {
      result(FlutterMethodNotImplemented);
    }
  }
}

- (void)handleCreateMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  // Create FLTCam only if granted camera access (and audio access if audio is enabled)
  __weak typeof(self) weakSelf = self;
  FLTRequestCameraPermissionWithCompletionHandler(^(FlutterError *error) {
    typeof(self) strongSelf = weakSelf;
    if (!strongSelf) return;

    if (error) {
      result(error);
    } else {
      // Request audio permission on `create` call with `enableAudio` argument instead of the
      // `prepareForVideoRecording` call. This is because `prepareForVideoRecording` call is
      // optional, and used as a workaround to fix a missing frame issue on iOS.
      BOOL audioEnabled = [call.arguments[@"enableAudio"] boolValue];
      if (audioEnabled) {
        // Setup audio capture session only if granted audio access.
        FLTRequestAudioPermissionWithCompletionHandler(^(FlutterError *error) {
          // cannot use the outter `strongSelf`
          typeof(self) strongSelf = weakSelf;
          if (!strongSelf) return;
          if (error) {
            result(error);
          } else {
            [strongSelf createCameraOnSessionQueueWithCreateMethodCall:call result:result];
          }
        });
      } else {
        [strongSelf createCameraOnSessionQueueWithCreateMethodCall:call result:result];
      }
    }
  });
}

// Returns number value if provided and positive, or nil.
// Used to parse values like framerates and bitrates, that are positive by nature.
// nil allows to ignore unsupported values.
+ (NSNumber *)positiveNumberValueOrNilForArgument:(NSString *)argument
                                       fromMethod:(FlutterMethodCall *)flutterMethodCall
                                            error:(NSError **)error {
  id value = flutterMethodCall.arguments[argument];

  if (!value || [value isEqual:[NSNull null]]) {
    return nil;
  }

  if (![value isKindOfClass:[NSNumber class]]) {
    if (error) {
      *error = [NSError errorWithDomain:@"ArgumentError"
                                   code:0
                               userInfo:@{
                                 NSLocalizedDescriptionKey :
                                     [NSString stringWithFormat:@"%@ should be a number", argument]
                               }];
    }
    return nil;
  }

  NSNumber *number = (NSNumber *)value;

  if (isnan([number doubleValue])) {
    if (error) {
      *error = [NSError errorWithDomain:@"ArgumentError"
                                   code:0
                               userInfo:@{
                                 NSLocalizedDescriptionKey :
                                     [NSString stringWithFormat:@"%@ should not be a nan", argument]
                               }];
    }
    return nil;
  }

  if ([number doubleValue] <= 0.0) {
    if (error) {
      *error = [NSError errorWithDomain:@"ArgumentError"
                                   code:0
                               userInfo:@{
                                 NSLocalizedDescriptionKey : [NSString
                                     stringWithFormat:@"%@ should be a positive number", argument]
                               }];
    }
    return nil;
  }

  return number;
}

- (void)createCameraOnSessionQueueWithCreateMethodCall:(FlutterMethodCall *)createMethodCall
                                                result:(FlutterResult)result {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    typeof(self) strongSelf = weakSelf;
    if (!strongSelf) return;

    NSString *cameraName = createMethodCall.arguments[@"cameraName"];

    NSError *error;

    NSNumber *framesPerSecond = [CameraPlugin positiveNumberValueOrNilForArgument:@"fps"
                                                                       fromMethod:createMethodCall
                                                                            error:&error];
    if (error) {
      result(FlutterErrorFromNSError(error));
      return;
    }

    NSNumber *videoBitrate = [CameraPlugin positiveNumberValueOrNilForArgument:@"videoBitrate"
                                                                    fromMethod:createMethodCall
                                                                         error:&error];
    if (error) {
      result(FlutterErrorFromNSError(error));
      return;
    }

    NSNumber *audioBitrate = [CameraPlugin positiveNumberValueOrNilForArgument:@"audioBitrate"
                                                                    fromMethod:createMethodCall
                                                                         error:&error];
    if (error) {
      result(FlutterErrorFromNSError(error));
      return;
    }

    NSString *resolutionPreset = createMethodCall.arguments[@"resolutionPreset"];
    NSNumber *enableAudio = createMethodCall.arguments[@"enableAudio"];
    FLTCamMediaSettings *mediaSettings =
        [[FLTCamMediaSettings alloc] initWithFramesPerSecond:framesPerSecond
                                                videoBitrate:videoBitrate
                                                audioBitrate:audioBitrate
                                                 enableAudio:[enableAudio boolValue]];
    FLTCamMediaSettingsAVWrapper *mediaSettingsAVWrapper =
        [[FLTCamMediaSettingsAVWrapper alloc] init];

    FLTCam *cam = [[FLTCam alloc] initWithCameraName:cameraName
                                    resolutionPreset:resolutionPreset
                                       mediaSettings:mediaSettings
                              mediaSettingsAVWrapper:mediaSettingsAVWrapper
                                         orientation:[[UIDevice currentDevice] orientation]
                                 captureSessionQueue:strongSelf.captureSessionQueue
                                               error:&error];

    if (error) {
      result(FlutterErrorFromNSError(error));
    } else {
      if (strongSelf.camera) {
        [strongSelf.camera close];
      }
      strongSelf.camera = cam;
      [strongSelf.registry registerTexture:cam
                                completion:^(int64_t textureId) {
                                  result(@{
                                    @"cameraId" : @(textureId),
                                  });
                                }];
    }
  });
}

@end
