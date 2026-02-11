/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_geometry_impl.h>

#include <memory>

@implementation SECommonQuadranglesMapIterator {
  std::unique_ptr<se::common::QuadranglesMapIterator> internal;
}

- (instancetype) initFromInternalQuadranglesMapIterator:(const se::common::QuadranglesMapIterator &)iter {
  if (self = [super init]) {
    internal.reset(new se::common::QuadranglesMapIterator(iter));
  }
  return self;
}

- (const se::common::QuadranglesMapIterator &) getInternalQuadranglesMapIterator {
  return *internal;
}

- (instancetype) initWithOther:(SECommonQuadranglesMapIterator *)other {
  if (self = [super init]) {
    internal.reset(new se::common::QuadranglesMapIterator([other getInternalQuadranglesMapIterator]));
  }
  return self;
}

- (BOOL) isEqualToIter:(SECommonQuadranglesMapIterator *)other {
  return internal->Equals([other getInternalQuadranglesMapIterator])? YES : NO;
}

- (NSString *) getKey {
  return [NSString stringWithUTF8String:internal->GetKey()];
}

- (SECommonQuadrangle *) getValue {
  return [[SECommonQuadrangle alloc] initFromInternalQuadrangle:internal->GetValue()];
}

- (void) advance {
  internal->Advance();
}

@end
