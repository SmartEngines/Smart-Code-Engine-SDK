/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import "SmartIDQuadrangleView.h"

static NSString * const kAnimation = @"path";

@interface SmartIDQuadrangleView()

@property (nonatomic, strong) CAShapeLayer* animLayer;
@property (nonatomic, assign) QuadrangleAnimationMode mode;

@end

@implementation SmartIDQuadrangleView

- (instancetype) init {
  if (self = [super init]) {
    [self setBackgroundColor:[UIColor clearColor]];
  }
  return self;
}

- (void) configureWithMode:(QuadrangleAnimationMode)mode {
  if (mode == QuadrangleAnimationModeSmoothOneQuadrangle) {
    [self setAnimLayer:[CAShapeLayer new]];
    [[self layer] addSublayer:[self animLayer]];
    [[self animLayer] setStrokeColor:[UIColor yellowColor].CGColor];
    [[self animLayer] setFillColor:[UIColor clearColor].CGColor];
    [[self animLayer] setPath:[UIBezierPath new].CGPath];
    [[self animLayer] setLineWidth:1.5];
  }
  _mode = mode;
}

- (void) hideQuad {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[self animLayer] removeAllAnimations];
    [[self animLayer] setPath:[UIBezierPath new].CGPath];
  });
}

- (void) animateQuadrangle:(SECommonQuadrangle *)quadrangle
                     color:(UIColor *)color
                     width:(CGFloat)width
                     alpha:(CGFloat)alpha
                   offsetX:(CGFloat)offsetX
                   offsetY:(CGFloat)offsetY
         deviceOrientation:(UIDeviceOrientation)dOrientation
      interfaceOrientation:(UIInterfaceOrientation)iOrientation
                sourceSize:(CGSize)size
                   isFront:(BOOL)isFront {
  
  [quadrangle preprocesssWithFrameSize:[self frame].size
                            sourceSize:size
                     deviceOrientation:dOrientation
                  interfaceOrientation:iOrientation
                               offsets:CGPointMake(offsetX, offsetY)
                               isFront:(BOOL)isFront];
  
  if ([self mode] == QuadrangleAnimationModeDefault && quadrangle != nil) {

    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [quadrangle bezierPath].CGPath;
    layer.backgroundColor = UIColor.redColor.CGColor;
    layer.strokeColor = color.CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = width;
    layer.opacity = 0.0f;
    
    [self.layer addSublayer:layer];
    
    __weak CAShapeLayer *weakLayer = layer;
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [CATransaction begin];
      [CATransaction setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakLayer removeFromSuperlayer];
        });
      }];
      
      CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
      animation.fromValue = @(alpha);
      animation.toValue = @(0.0f);
      animation.duration = 0.7f;
      
      [weakLayer addAnimation:animation forKey:animation.keyPath];
      
      [CATransaction commit];
      [self setNeedsDisplay];
    });
  } else {
    if ([[self animLayer] isHidden]) {
      return;
    }
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:kAnimation];
    [anim setFromValue:[[[self animLayer] presentationLayer] valueForKeyPath:kAnimation]];
    [[self animLayer] removeAnimationForKey:kAnimation];
    if (quadrangle != nil) {
      [anim setToValue:(id)[quadrangle bezierPath].CGPath];
    } else {
      [anim setToValue:nil];
    }
    [anim setDuration:0.1];
    [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [[self animLayer] removeAnimationForKey:kAnimation];
    [anim setFillMode:kCAFillModeBoth];
    [anim setRemovedOnCompletion:NO];
    [[self animLayer] addAnimation:anim forKey:kAnimation];
    
    CABasicAnimation *strokeAnim = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    [strokeAnim setFromValue:[[[self animLayer] presentationLayer] valueForKeyPath:@"strokeColor"]];
    [[self animLayer] removeAnimationForKey:@"strokeColor"];
    strokeAnim.toValue = (id) color.CGColor;
    strokeAnim.duration = 0.1;
    strokeAnim.repeatCount = 10;
    [strokeAnim setRemovedOnCompletion:NO];
    [[self animLayer] addAnimation:strokeAnim forKey:@"strokeColor"];
  }
}

@end

