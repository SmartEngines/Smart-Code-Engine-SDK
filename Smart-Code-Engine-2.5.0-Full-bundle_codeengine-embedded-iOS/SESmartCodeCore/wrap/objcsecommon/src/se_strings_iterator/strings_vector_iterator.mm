/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_strings_iterator_impl.h>

#include <memory>

@implementation SECommonStringsVectorIterator {
  std::unique_ptr<se::common::StringsVectorIterator> internal;
}

- (instancetype) initFromInternalStringsVectorIterator:(const se::common::StringsVectorIterator &)iter {
  if (self = [super init]) {
    internal.reset(new se::common::StringsVectorIterator(iter));
  }
  return self;
}

- (const se::common::StringsVectorIterator &) getInternalStringsVectorIterator {
  return *internal;
}

- (instancetype) initWithOther:(SECommonStringsVectorIterator *)other {
  if (self = [super init]) {
    internal.reset(new se::common::StringsVectorIterator([other getInternalStringsVectorIterator]));
  }
  return self;
}

- (BOOL) isEqualToIter:(SECommonStringsVectorIterator *)other {
  return internal->Equals([other getInternalStringsVectorIterator]);
}

- (NSString *) getValue {
  return [NSString stringWithUTF8String:internal->GetValue()];
}

- (void) advance {
  internal->Advance();
}

@end
