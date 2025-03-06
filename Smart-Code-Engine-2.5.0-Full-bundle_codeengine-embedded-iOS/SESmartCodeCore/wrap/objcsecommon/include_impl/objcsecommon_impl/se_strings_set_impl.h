/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCSECOMMON_IMPL_SE_STRINGS_SET_H_INCLUDED
#define OBJCSECOMMON_IMPL_SE_STRINGS_SET_H_INCLUDED

#import <objcsecommon/se_strings_set.h>

#include <secommon/se_strings_set.h>

@interface SECommonStringsSetRef (Internal)

- (instancetype) initFromInternalStringsSetPointer:(se::common::StringsSet *)set
                                withMutabilityFlag:(BOOL)mutabilityFlag;
- (se::common::StringsSet *) getInternalStringsSetPointer;

@end

#endif // OBJCSECOMMON_IMPL_SE_STRINGS_SET_H_INCLUDED