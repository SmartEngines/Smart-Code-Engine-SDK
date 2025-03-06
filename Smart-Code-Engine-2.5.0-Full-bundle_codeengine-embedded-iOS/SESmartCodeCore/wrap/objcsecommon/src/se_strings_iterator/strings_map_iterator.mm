/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_strings_iterator_impl.h>

#include <memory>

@implementation SECommonStringsMapIterator {
  std::unique_ptr<se::common::StringsMapIterator> internal;
}

- (instancetype) initFromInternalStringsMapIterator:(const se::common::StringsMapIterator &)iter {
  if (self = [super init]) {
    internal.reset(new se::common::StringsMapIterator(iter));
  }
  return self;
}

- (const se::common::StringsMapIterator &) getInternalStringsMapIterator {
  return *internal;
}

- (instancetype) initWithOther:(SECommonStringsMapIterator *)other {
  if (self = [super init]) {
    internal.reset(new se::common::StringsMapIterator([other getInternalStringsMapIterator]));
  }
  return self;
}

- (BOOL) isEqualToIter:(SECommonStringsMapIterator *)other {
  return internal->Equals([other getInternalStringsMapIterator]);
}

- (NSString *) getKey {
  return [NSString stringWithUTF8String:internal->GetKey()];
}

- (NSString *) getValue {
  return [NSString stringWithUTF8String:internal->GetValue()];
}

- (void) advance {
  internal->Advance();
}

@end
