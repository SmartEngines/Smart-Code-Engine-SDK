/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCSECOMMON_SE_SERIALIZATION_H_INCLUDED
#define OBJCSECOMMON_SE_SERIALIZATION_H_INCLUDED

#import <Foundation/Foundation.h>

#import <objcsecommon/se_strings_iterator.h>

@interface SECommonSerializationParameters : NSObject

- (nonnull instancetype) init;
- (nonnull instancetype) initWithOther:(nonnull SECommonSerializationParameters *)other;

- (BOOL) hasIgnoredObjectType:(nonnull NSString *)object_type;
- (void) addIgnoredObjectType:(nonnull NSString *)object_type;
- (void) removeIgnoredObjectType:(nonnull NSString *)object_type;

- (nonnull SECommonStringsSetIterator *) ignoredObjectTypesBegin;
- (nonnull SECommonStringsSetIterator *) ignoredObjectTypesEnd;

- (BOOL) hasIgnoredKey:(nonnull NSString *)key;
- (void) addIgnoredKey:(nonnull NSString *)key;
- (void) removeIgnoredKey:(nonnull NSString *)key;

- (nonnull SECommonStringsSetIterator *) ignoredKeysBegin;
- (nonnull SECommonStringsSetIterator *) ignoredKeysEnd;

@end


@interface SECommonSerializer : NSObject 

- (nonnull instancetype) initJSONSerializerWithParams:(nonnull SECommonSerializationParameters *)params;

- (void) reset;

- (nonnull NSString *) getString;
- (nonnull NSString *) serializerType;

- (nonnull const char *) getStringAsUTF8String;

@end

#endif // OBJCSECOMMON_SE_SERIALIZATION_H_INCLUDED