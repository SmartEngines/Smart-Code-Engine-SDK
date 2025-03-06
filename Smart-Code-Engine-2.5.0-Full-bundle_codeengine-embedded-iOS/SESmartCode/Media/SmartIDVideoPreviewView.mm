/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import "SmartIDVideoPreviewView.h"

@implementation SmartIDVideoPreviewView

+ (Class) layerClass {
  return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer *) videoPreviewLayer {
  return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession *) session {
  return self.videoPreviewLayer.session;
}

- (void) setSession:(AVCaptureSession *)session {
  self.videoPreviewLayer.session = session;
}

@end
