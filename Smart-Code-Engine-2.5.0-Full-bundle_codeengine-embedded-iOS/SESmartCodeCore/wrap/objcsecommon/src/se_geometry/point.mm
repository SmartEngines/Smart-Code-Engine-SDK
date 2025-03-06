/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_geometry_impl.h>
#import <objcsecommon_impl/se_serialization_impl.h>

#include <memory>

@implementation SECommonPoint {
  std::unique_ptr<se::common::Point> internal;
}

- (void) setX:(double)x {
  internal->x = x;
}

- (double) x {
  return internal->x;
}

- (void) setY:(double)y {
  internal->y = y;
}

- (double) y {
  return internal->y;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(new se::common::Point);
  }
  return self;
}

- (instancetype) initWithX:(double)x
                 withY:(double)y {
  if (self = [super init]) {
    internal.reset(new se::common::Point(x, y));
  }
  return self;
}

- (instancetype) initFromInternalPoint:(const se::common::Point &)point {
  if (self = [super init]) {
    internal.reset(new se::common::Point(point));
  }
  return self;
}

- (const se::common::Point &) getInternalPoint {
  return *internal;
}

- (void) serialize:(SECommonSerializer *)serializer {
  internal->Serialize([serializer getInternalSerializer]);
}

@end
