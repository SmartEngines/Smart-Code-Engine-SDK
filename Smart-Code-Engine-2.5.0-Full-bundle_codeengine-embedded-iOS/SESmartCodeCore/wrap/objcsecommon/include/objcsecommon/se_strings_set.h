/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCSECOMMON_SE_STRINGS_SET_H_INCLUDED
#define OBJCSECOMMON_SE_STRINGS_SET_H_INCLUDED

#import <Foundation/Foundation.h>

#import <objcsecommon/se_strings_iterator.h>

@interface SECommonStringsSetRef : NSObject

- (BOOL) isMutable;

- (int) getStringsCount;
- (BOOL) hasString:(nonnull NSString *)string;

- (nonnull SECommonStringsSetIterator *) stringsBegin;
- (nonnull SECommonStringsSetIterator *) stringsEnd;

@end

#endif // OBJCSECOMMON_SE_STRINGS_SET_H_INCLUDED