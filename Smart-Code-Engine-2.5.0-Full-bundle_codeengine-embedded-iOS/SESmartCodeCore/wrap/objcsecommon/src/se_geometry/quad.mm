/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_geometry_impl.h>
#import <objcsecommon_impl/se_serialization_impl.h>
#import <objcsecommon_impl/se_common_proxy_impl.h>

#include <secommon/se_exception.h>

#include <memory>

@implementation SECommonQuadrangle {
  std::unique_ptr<se::common::Quadrangle> internal;
}

- (instancetype) initFromInternalQuadrangle:(const se::common::Quadrangle &)quad {
  if (self = [super init]) {
    internal.reset(new se::common::Quadrangle(quad));
  }
  return self;
}

- (const se::common::Quadrangle &) getInternalQuadrangle {
  return *internal;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(new se::common::Quadrangle);
  }
  return self;
}

- (instancetype) initWithPoints:(NSArray *)points {
  if (4 != [points count]) {
    NSException* exc = [NSException
        exceptionWithName:@"InvalidArgumentException"
        reason:@"Quadrangle must have 4 points"
        userInfo:nil];
    @throw exc;
    return nil;
  }
  if (self = [super init]) {
    for (int i = 0; i < 4; ++i) {
      if (![[points objectAtIndex:i] isKindOfClass:[SECommonPoint class]]) {
        NSException* exc = [NSException
            exceptionWithName:@"InvalidArgumentException"
            reason:@"Quadrangle must contain points"
            userInfo:nil];
        @throw exc;
        return nil;
      }
    }
    internal.reset(new se::common::Quadrangle(
        [[points objectAtIndex:0] getInternalPoint],
        [[points objectAtIndex:1] getInternalPoint],
        [[points objectAtIndex:2] getInternalPoint],
        [[points objectAtIndex:3] getInternalPoint]));
  }
  return self;
}

- (SECommonPoint *) getPointAt:(int)index {
  try {
    return [[SECommonPoint alloc] 
        initFromInternalPoint:internal->GetPoint(index)];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) setPointAt:(int)index
                 to:(SECommonPoint *)point {
  try {
    return internal->SetPoint(index, [point getInternalPoint]);
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
}

- (SECommonRectangle *) getBoundingRectangle {
  return [[SECommonRectangle alloc]  initFromInternalRectangle:internal->GetBoundingRectangle()];
}

- (void) serialize:(SECommonSerializer *)serializer {
  internal->Serialize([serializer getInternalSerializer]);
}

#ifndef OBJCSECOMMON_WITHOUT_UIKIT
static CGSize CGSizeMakeAspectFill(const CGSize aspectRatio, const CGSize minSize) {
  CGSize aspectFillSize = CGSizeMake(minSize.width, minSize.height);
  const CGFloat minWidth = minSize.width / aspectRatio.width;
  const CGFloat minHeight = minSize.height / aspectRatio.height;
  if (minHeight > minWidth) {
      aspectFillSize.width = minHeight * aspectRatio.width;
  } else {
      aspectFillSize.height = minWidth * aspectRatio.height;
  }
  return aspectFillSize;
}

- (void) shiftPoints:(CGPoint)offsets {
  for (int i = 0; i < 4; ++i) {
    internal->GetMutablePoint(i).x += offsets.x;
    internal->GetMutablePoint(i).y += offsets.y;
  }
}

- (void) preprocesssWithFrameSize:(CGSize)frameSize                 // frame size of the view for drawing
                       sourceSize:(CGSize)ssize                     // source image size
                deviceOrientation:(UIDeviceOrientation)dOrientation // orientation when frame with given quadrangle captured
             interfaceOrientation:(UIInterfaceOrientation)iOrientation // interface orientatino
                          offsets:(CGPoint)offsets                   // roi offsets
                          isFront:(BOOL)isFront{
    
  [self shiftPoints:offsets];
  
  const UIInterfaceOrientation current = iOrientation;
  
  if (UIInterfaceOrientationIsPortrait(current)) {
    ssize = CGSizeMake(ssize.height, ssize.width);
  }
  
  const CGSize aspectFillFrameSize = CGSizeMakeAspectFill(ssize, frameSize);
  
  for (int i = 0; i < 4; ++i) {
    se::common::Point cur = internal->GetPoint(i);

    cur.x /= ssize.width;
    cur.x *= aspectFillFrameSize.width;
    cur.y /= ssize.height;
    cur.y *= aspectFillFrameSize.height;
    
    if (isFront) {
      cur.x = aspectFillFrameSize.width - cur.x;
    }
    
    internal->SetPoint(i, cur);
  }
  
  const CGPoint aspectDifference = CGPointMake(
      (frameSize.width - aspectFillFrameSize.width) / 2,
      (frameSize.height - aspectFillFrameSize.height) / 2);
  
  if (current == UIInterfaceOrientationLandscapeRight) {
    if (dOrientation == UIDeviceOrientationPortrait) {
      [self rotate90cw:CGSizeMake(frameSize.height, frameSize.width)];
    }
    [self shiftPoints:CGPointMake(aspectDifference.x, aspectDifference.y)];
  } else if (current == UIInterfaceOrientationLandscapeLeft) {
    if (dOrientation == UIDeviceOrientationPortrait) {
      [self rotate90ccw:CGSizeMake(frameSize.height, frameSize.width)];
    }
    [self shiftPoints:CGPointMake(aspectDifference.x, aspectDifference.y)];
  } else {
    if (dOrientation == UIDeviceOrientationLandscapeLeft) {
      [self rotate90ccw:CGSizeMake(frameSize.width, frameSize.height)];
      [self shiftPoints:CGPointMake(-aspectDifference.x, aspectDifference.y)];
    } else if (dOrientation == UIDeviceOrientationLandscapeRight) {
      [self rotate90cw:CGSizeMake(frameSize.width, frameSize.height)];
      [self shiftPoints:CGPointMake(aspectDifference.x, -aspectDifference.y)];
    } else {
      [self shiftPoints:CGPointMake(aspectDifference.x, aspectDifference.y)];
    }
  }
}

- (void) rotate90cw:(CGSize)viewSize {
  for (int i = 0; i < 4; ++i) {
    se::common::Point cur = internal->GetPoint(i);
    cur.x = viewSize.height - cur.x;
    internal->SetPoint(i, cur);
  }
}

- (void) rotate90ccw:(CGSize)viewSize {
  for (int i = 0; i < 4; ++i) {
    se::common::Point cur = internal->GetPoint(i);
    cur.y = viewSize.width - cur.y;
    internal->SetPoint(i, cur);
  }
}

- (UIBezierPath *) bezierPath {
  UIBezierPath* path = [UIBezierPath bezierPath];
  const se::common::Point& first = internal->GetPoint(0);
  [path moveToPoint:CGPointMake(first.x, first.y)];
  
  for (int i = 0; i < 4; ++i) {
    const se::common::Point& next = internal->GetPoint((i + 1) % 4);
    [path addLineToPoint:CGPointMake(next.x, next.y)];
  }
  return path;
}
#endif // OBJCSECOMMON_WITHOUT_UIKIT

@end
