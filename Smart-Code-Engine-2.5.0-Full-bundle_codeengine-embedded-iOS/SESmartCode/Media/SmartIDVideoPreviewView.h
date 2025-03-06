/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SmartIDVideoPreviewView : UIView

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer* videoPreviewLayer;
@property (nonatomic) AVCaptureSession* session;

@end
