/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCSECOMMON_IMPL_SE_STRINGS_ITERATOR_H_INCLUDED
#define OBJCSECOMMON_IMPL_SE_STRINGS_ITERATOR_H_INCLUDED

#import <objcsecommon/se_strings_iterator.h>

#include <secommon/se_strings_iterator.h>

@interface SECommonStringsMapIterator (Internal)

- (instancetype) initFromInternalStringsMapIterator:(const se::common::StringsMapIterator &)iter;
- (const se::common::StringsMapIterator &) getInternalStringsMapIterator;

@end


@interface SECommonStringsSetIterator (Internal)

- (instancetype) initFromInternalStringsSetIterator:(const se::common::StringsSetIterator &)iter;
- (const se::common::StringsSetIterator &) getInternalStringsSetIterator;

@end


@interface SECommonStringsVectorIterator (Internal)

- (instancetype) initFromInternalStringsVectorIterator:(const se::common::StringsVectorIterator &)iter;
- (const se::common::StringsVectorIterator &) getInternalStringsVectorIterator;

@end

#endif // OBJCSECOMMON_IMPL_SE_STRINGS_ITERATOR_H_INCLUDED