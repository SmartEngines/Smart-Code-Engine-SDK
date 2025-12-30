/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCSECOMMON_IMPL_SE_GEOMETRY_H_INCLUDED
#define OBJCSECOMMON_IMPL_SE_GEOMETRY_H_INCLUDED

#import <objcsecommon/se_geometry.h>

#include <secommon/se_geometry.h>

@interface SECommonPoint (Internal)

- (instancetype) initFromInternalPoint:(const se::common::Point &)point;
- (const se::common::Point &) getInternalPoint;

@end


@interface SECommonPolygon (Internal)

- (instancetype) initFromInternalPolygon:(const se::common::Polygon &)poly;
- (const se::common::Polygon &) getInternalPolygon;

@end


@interface SECommonProjectiveTransform (Internal)

- (instancetype) initFromInternalProjectiveTransform:(const se::common::ProjectiveTransform &)tr;
- (const se::common::ProjectiveTransform &) getInternalProjectiveTransform;

@end


@interface SECommonQuadrangle (Internal)

- (instancetype) initFromInternalQuadrangle:(const se::common::Quadrangle &)quad;
- (const se::common::Quadrangle &) getInternalQuadrangle;

@end


@interface SECommonQuadranglesMapIterator (Internal)

- (instancetype) initFromInternalQuadranglesMapIterator:(const se::common::QuadranglesMapIterator &)iter;
- (const se::common::QuadranglesMapIterator &) getInternalQuadranglesMapIterator;

@end


@interface SECommonRectangle (Internal)

- (instancetype) initFromInternalRectangle:(const se::common::Rectangle &)rect;
- (const se::common::Rectangle &) getInternalRectangle;

@end


@interface SECommonSize (Internal)

- (instancetype) initFromInternalSize:(const se::common::Size &)size;
- (const se::common::Size &) getInternalSize;

@end

#endif // OBJCSECOMMON_IMPL_SE_GEOMETRY_H_INCLUDED