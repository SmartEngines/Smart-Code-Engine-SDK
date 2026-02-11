/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_serialization_impl.h>
#import <objcsecommon_impl/se_strings_iterator_impl.h>
#import <objcsecommon_impl/se_common_proxy_impl.h>

#include <secommon/se_exception.h>
#include <secommon/se_serialization.h>

#include <memory>

@implementation SECommonSerializationParameters {
  std::unique_ptr<se::common::SerializationParameters> internal;  
}

- (instancetype) initFromInternalSerializationParameters:(const se::common::SerializationParameters &)params {
  if (self = [super init]) {
    internal.reset(new se::common::SerializationParameters(params));
  }
  return self;
}

- (const se::common::SerializationParameters &) getInternalSerializationParameters {
  return *internal;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(new se::common::SerializationParameters);
  }
  return self;
}

- (instancetype) initWithOther:(SECommonSerializationParameters *)other {
  if (self = [super init]) {
    internal.reset(new se::common::SerializationParameters([other getInternalSerializationParameters]));
  }
  return self;
}


- (BOOL) hasIgnoredObjectType:(NSString *)object_type {
  return internal->HasIgnoredObjectType([object_type UTF8String])? YES : NO;
}

- (void) addIgnoredObjectType:(NSString *)object_type {
  internal->AddIgnoredObjectType([object_type UTF8String]);
}

- (void) removeIgnoredObjectType:(NSString *)object_type {
  try {
    internal->RemoveIgnoredObjectType([object_type UTF8String]);
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
}

- (SECommonStringsSetIterator *) ignoredObjectTypesBegin {
  return [[SECommonStringsSetIterator alloc] initFromInternalStringsSetIterator:internal->IgnoredObjectTypesBegin()];
}

- (SECommonStringsSetIterator *) ignoredObjectTypesEnd {
  return [[SECommonStringsSetIterator alloc] initFromInternalStringsSetIterator:internal->IgnoredObjectTypesEnd()];
}


- (BOOL) hasIgnoredKey:(NSString *)key {
  return internal->HasIgnoredKey([key UTF8String])? YES : NO;
}

- (void) addIgnoredKey:(NSString *)key {
  internal->AddIgnoredKey([key UTF8String]);
}

- (void) removeIgnoredKey:(NSString *)key {
  try {
    internal->RemoveIgnoredKey([key UTF8String]);
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
}

- (SECommonStringsSetIterator *) ignoredKeysBegin {
  return [[SECommonStringsSetIterator alloc] initFromInternalStringsSetIterator:internal->IgnoredKeysBegin()];
}

- (SECommonStringsSetIterator *) ignoredKeysEnd {
  return [[SECommonStringsSetIterator alloc] initFromInternalStringsSetIterator:internal->IgnoredKeysEnd()];
}


@end
