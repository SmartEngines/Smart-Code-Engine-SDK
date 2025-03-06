/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_geometry_impl.h>
#import <objcsecommon_impl/se_serialization_impl.h>

#include <memory>

@implementation SECommonSize {
  std::unique_ptr<se::common::Size> internal;
}

- (instancetype) initFromInternalSize:(const se::common::Size &)size {
  if (self = [super init]) {
    internal.reset(new se::common::Size(size));
  }
  return self;
}

- (const se::common::Size &) getInternalSize {
  return *internal;
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
    internal.reset(new se::common::Size);
  }
  return self;
}

- (instancetype) initWithWidth:(int)width
                    withHeight:(int)height {
  if (self = [super init]) {
    internal.reset(new se::common::Size(width, height));
  }
  return self;
}

- (void) serialize:(SECommonSerializer *)serializer {
  internal->Serialize([serializer getInternalSerializer]);
}

@end
