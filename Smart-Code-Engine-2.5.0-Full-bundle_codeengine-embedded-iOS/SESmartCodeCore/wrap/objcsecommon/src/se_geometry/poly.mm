/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_geometry_impl.h>
#import <objcsecommon_impl/se_serialization_impl.h>
#import <objcsecommon_impl/se_common_proxy_impl.h>

#include <secommon/se_exception.h>

#include <memory>
#include <vector>

@implementation SECommonPolygon {
  std::unique_ptr<se::common::Polygon> internal;
}

- (instancetype) initFromInternalPolygon:(const se::common::Polygon &)poly {
  if (self = [super init]) {
    internal.reset(new se::common::Polygon(poly));
  }
  return self;
}

- (const se::common::Polygon &) getInternalPolygon {
  return *internal;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(new se::common::Polygon);
  }
  return self;
}

- (instancetype) initWithPoints:(NSArray *)points {
  if (self = [super init]) {
    std::vector<se::common::Point> internal_points;
    for (int i = 0; i < static_cast<int>([points count]); ++i) {
      SECommonPoint* pt = [points objectAtIndex:i];
      if (![pt isKindOfClass:[SECommonPoint class]]) {
        NSException* exc = [NSException
            exceptionWithName:@"InvalidArgumentException"
            reason:@"Polygon must contain points"
            userInfo:nil];
        @throw exc;
      }
      internal_points.push_back([pt getInternalPoint]);
    }
    internal.reset(new se::common::Polygon(
        internal_points.data(), static_cast<int>(internal_points.size())));
  }
  return self;
}

- (int) getPointsCount {
  return internal->GetPointsCount();
}

- (SECommonPoint *) getPointAt:(int)index {
  try {
    return [[SECommonPoint alloc] initFromInternalPoint:internal->GetPoint(index)];
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

- (void) resize:(int)size {
  try {
    internal->Resize(size);
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
}

- (SECommonRectangle *) getBoundingRectangle {
  return [[SECommonRectangle alloc] initFromInternalRectangle:internal->GetBoundingRectangle()];
}

- (void) serialize:(SECommonSerializer *)serializer {
  internal->Serialize([serializer getInternalSerializer]);
}

@end
