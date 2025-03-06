/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <UIKit/UIKit.h>

#import <objcsecommon/se_geometry.h>

typedef enum : NSUInteger {
  QuadrangleAnimationModeSmoothOneQuadrangle,
  QuadrangleAnimationModeDefault,
} QuadrangleAnimationMode;

@interface SmartIDQuadrangleView : UIView

- (instancetype) init;

- (void) hideQuad;

- (void) configureWithMode:(QuadrangleAnimationMode)mode;

- (void) animateQuadrangle:(SECommonQuadrangle *)quadrangle
                     color:(UIColor *)color
                     width:(CGFloat)width
                     alpha:(CGFloat)alpha
                   offsetX:(CGFloat)offsetX
                   offsetY:(CGFloat)offsetY
         deviceOrientation:(UIDeviceOrientation)dOrientation
      interfaceOrientation:(UIInterfaceOrientation)iOrientation
                sourceSize:(CGSize)size
                   isFront:(BOOL)isFront;
@end

