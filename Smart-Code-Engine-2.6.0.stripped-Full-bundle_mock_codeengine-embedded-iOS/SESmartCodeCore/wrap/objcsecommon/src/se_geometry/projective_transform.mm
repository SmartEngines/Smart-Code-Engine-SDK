/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_geometry_impl.h>
#import <objcsecommon_impl/se_serialization_impl.h>

#include <memory>

@implementation SECommonProjectiveTransform {
  std::unique_ptr<se::common::ProjectiveTransform> internal;
}

+ (BOOL)canCreateWithSrcQuad:(SECommonQuadrangle *)src_quad
                 withDstQuad:(SECommonQuadrangle *)dst_quad {
  return se::common::ProjectiveTransform::CanCreate(
      [src_quad getInternalQuadrangle], 
      [dst_quad getInternalQuadrangle]);
}

+ (BOOL)canCreateWithSrcQuad:(SECommonQuadrangle *)src_quad
                 withDstSize:(SECommonSize *)dst_size {
  return se::common::ProjectiveTransform::CanCreate(
      [src_quad getInternalQuadrangle], 
      [dst_size getInternalSize]);
} 

- (instancetype) initFromInternalProjectiveTransform:(const se::common::ProjectiveTransform &)tr {
  if (self = [super init]) {
    internal.reset(tr.Clone());
  }
  return self;
}


- (const se::common::ProjectiveTransform &) getInternalProjectiveTransform {
  return *internal;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(se::common::ProjectiveTransform::Create());
  }
  return self;
}

- (instancetype) initWithSrcQuad:(SECommonQuadrangle *)src_quad
                     withDstQuad:(SECommonQuadrangle *)dst_quad {
  if (self = [super init]) {
    internal.reset(se::common::ProjectiveTransform::Create(
        [src_quad getInternalQuadrangle],
        [dst_quad getInternalQuadrangle]));
  }
  return self;
}

- (instancetype) initWithSrcQuad:(SECommonQuadrangle *)src_quad
                     withDstSize:(SECommonSize *)dst_size {
  if (self = [super init]) {
    internal.reset(se::common::ProjectiveTransform::Create(
        [src_quad getInternalQuadrangle],
        [dst_size getInternalSize]));
  }
  return self;
}

- (SECommonPoint *) transformPoint:(SECommonPoint *)point {
  return [[SECommonPoint alloc] initFromInternalPoint:internal->TransformPoint([point getInternalPoint])];
}

- (SECommonQuadrangle *) transformQuadrangle:(SECommonQuadrangle *)quad {
  return [[SECommonQuadrangle alloc] initFromInternalQuadrangle:internal->TransformQuad([quad getInternalQuadrangle])];
}

- (SECommonPolygon *) transformPolygon:(SECommonPolygon *)poly {
  return [[SECommonPolygon alloc] initFromInternalPolygon:internal->TransformPolygon([poly getInternalPolygon])];
}

- (double) getCellAtRow:(int)row
                  atCol:(int)col {
  if (row < 0 || row > 2 || col < 0 || col > 2) {
    NSException* exc = [NSException
        exceptionWithName:@"InvalidArgumentException"
        reason:@"Invalid cell index (row and col must be in range 0..2)"
        userInfo:nil];
    @throw exc;
    return 0.0;
  }
  return internal->GetRawCoeffs()[row][col];
}

- (void) setCellAtRow:(int)row
                atCol:(int)col
              toValue:(double)val {
  if (row < 0 || row > 2 || col < 0 || col > 2) {
    NSException* exc = [NSException
        exceptionWithName:@"InvalidArgumentException"
        reason:@"Invalid cell index (row and col must be in range 0..2)"
        userInfo:nil];
    @throw exc;
  }
  internal->GetMutableRawCoeffs()[row][col] = val;
}

- (BOOL) isInvertable {
  return internal->IsInvertable();
}

- (void) invert {
  internal->Invert();
}

- (void) serialize:(SECommonSerializer *)serializer {
  internal->Serialize([serializer getInternalSerializer]);
}

@end
