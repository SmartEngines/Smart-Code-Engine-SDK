/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCSECOMMON_SE_STRINGS_ITERATOR_H_INCLUDED
#define OBJCSECOMMON_SE_STRINGS_ITERATOR_H_INCLUDED

#import <Foundation/Foundation.h>

@interface SECommonStringsVectorIterator : NSObject

- (nonnull instancetype) initWithOther:(nonnull SECommonStringsVectorIterator *)other;
- (BOOL) isEqualToIter:(nonnull SECommonStringsVectorIterator *)other;

- (nonnull NSString *) getValue;
- (void) advance;

@end


@interface SECommonStringsSetIterator : NSObject

- (nonnull instancetype) initWithOther:(nonnull SECommonStringsSetIterator *)other;
- (BOOL) isEqualToIter:(nonnull SECommonStringsSetIterator *)other;

- (nonnull NSString *) getValue;
- (void) advance;

@end


@interface SECommonStringsMapIterator : NSObject

- (nonnull instancetype) initWithOther:(nonnull SECommonStringsMapIterator *)other;
- (BOOL) isEqualToIter:(nonnull SECommonStringsMapIterator *)other;

- (nonnull NSString *) getKey;
- (nonnull NSString *) getValue;

- (void) advance;

@end

#endif // OBJCSECOMMON_SE_STRINGS_ITERATOR_H_INCLUDED