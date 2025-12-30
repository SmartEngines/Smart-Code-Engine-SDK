/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_strings_iterator_impl.h>

#include <memory>

@implementation SECommonStringsSetIterator {
  std::unique_ptr<se::common::StringsSetIterator> internal;
}

- (instancetype) initFromInternalStringsSetIterator:(const se::common::StringsSetIterator &)iter {
  if (self = [super init]) {
    internal.reset(new se::common::StringsSetIterator(iter));
  }
  return self;
}

- (const se::common::StringsSetIterator &) getInternalStringsSetIterator {
  return *internal;
}

- (instancetype) initWithOther:(SECommonStringsSetIterator *)other {
  if (self = [super init]) {
    internal.reset(new se::common::StringsSetIterator([other getInternalStringsSetIterator]));
  }
  return self;
}

- (BOOL) isEqualToIter:(SECommonStringsSetIterator *)other {
  return internal->Equals([other getInternalStringsSetIterator]);
}

- (NSString *) getValue {
  return [NSString stringWithUTF8String:internal->GetValue()];
}

- (void) advance {
  internal->Advance();
}

@end
