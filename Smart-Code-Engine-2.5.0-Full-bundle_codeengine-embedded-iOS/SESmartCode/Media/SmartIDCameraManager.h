/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIView.h>

#import "SmartIDVideoPreviewView.h"

@interface SmartIDCameraManager : NSObject

@property (atomic) CGSize currentVideoSize;

- (nonnull instancetype) init;
- (nonnull instancetype) initWithBestDevice:(BOOL)bestDevice;
- (nonnull instancetype) initWithCaptureDevicePosition:(AVCaptureDevicePosition)position
                                        WithBestDevice:(BOOL)bestDevice;
- (nonnull instancetype) initWithBestDevice:(BOOL)bestDevice
                             WithLockCamera:(BOOL)lockCamera;
- (nonnull instancetype) initWithCaptureDevicePosition:(AVCaptureDevicePosition)position
                                        WithBestDevice:(BOOL)bestDevice
                                        WithLockCamera:(BOOL)lockCamera;

- (CGSize) videoSize;

- (void) setSampleBufferDelegate:(nonnull id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate;
- (void) configurePreview:(nonnull SmartIDVideoPreviewView *)view;

- (void) startCaptureSession;
- (void) stopCaptureSession;

- (void) focusAtPoint:(CGPoint)point
    completionHandler:(nullable void(^)(void))completionHandler;
- (BOOL) isAdjustingFocus;

- (void) changeSessionPreset:(nonnull AVCaptureSessionPreset)preset;
- (void) updateCaptureSessionPreset;

- (void) turnTorchOnWithLevel:(float)level;
- (void) turnTorchOff;
- (BOOL) isTorchOn;
- (void) switchCamera;
- (nullable AVCaptureDevice*) getCaptureDevice;

typedef enum {
  sUltrawide,
  sWide,
  sTelephoto
} ZoomState;

@end

