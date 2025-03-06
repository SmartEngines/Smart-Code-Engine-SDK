/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_geometry_impl.h>
#import <objcsecommon_impl/se_serialization_impl.h>

#include <memory>

@implementation SECommonRectangle {
  std::unique_ptr<se::common::Rectangle> internal;
}

- (void) setX:(int)x {
  internal->x = x;
}

- (int) x {
  return internal->x;
}

- (void) setY:(int)y {
  internal->y = y;
}

- (int) y {
  return internal->y;
}

- (void) setWidth:(int)width {
  internal->width = width;
}

- (int) width {
  return internal->width;
}

- (void) setHeight:(int)height {
  internal->height = height;
}

- (int) height {
  return internal->height;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(new se::common::Rectangle);
  }
  return self;
}

- (instancetype) initWithX:(int)x
                 withY:(int)y
                 withWidth:(int)width
                 withHeight:(int)height {
  if (self = [super init]) {
    internal.reset(new se::common::Rectangle(
        x, y, width, height));
  }
  return self;
}

- (instancetype) initFromInternalRectangle:(const se::common::Rectangle &)rect {
  if (self = [super init]) {
    internal.reset(new se::common::Rectangle(rect));
  }
  return self;
}

- (const se::common::Rectangle &) getInternalRectangle {
  return *internal;
}

- (void) serialize:(SECommonSerializer *)serializer {
  internal->Serialize([serializer getInternalSerializer]);
}

@end
