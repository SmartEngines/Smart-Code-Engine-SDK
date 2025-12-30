/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <UIKit/UIKit.h>

@interface SmartIDRoiView : UIView

@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) BOOL displayRoi;

+ (CGRect) calculateRoiWith:(UIDeviceOrientation)deviceOrientation
                   viewSize:(CGSize)previewSize
                orientation:(UIInterfaceOrientation)orientation
                 cameraSize:(CGSize)camSize
                 andOffsets:(CGSize)offsets
                 displayRoi:(BOOL)displayroi;

@end
