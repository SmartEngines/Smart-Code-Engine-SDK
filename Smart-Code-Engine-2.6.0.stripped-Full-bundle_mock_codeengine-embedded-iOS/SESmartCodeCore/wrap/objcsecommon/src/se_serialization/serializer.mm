/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_serialization_impl.h>

#include <secommon/se_serialization.h>

#include <memory>

@implementation SECommonSerializer {
  std::unique_ptr<se::common::Serializer> internal;  
}

- (instancetype) initFromCreatedInternalPointer:(se::common::Serializer *)serializer {
  if (self = [super init]) {
    internal.reset(serializer);
  }
  return self;
}

- (se::common::Serializer &) getInternalSerializer {
  return *internal;
}

- (instancetype) initJSONSerializerWithParams:(SECommonSerializationParameters *)params {
  if (self = [super init]) {
    internal.reset(se::common::Serializer::CreateJSONSerializer(
        [params getInternalSerializationParameters]));
  }
  return self;
}

- (void) reset {
  internal->Reset();
}

- (NSString *) getString {
  return [NSString stringWithUTF8String:internal->GetCStr()];
}

- (const char *) getStringAsUTF8String {
  return internal->GetCStr();
}

- (NSString *) serializerType {
  return [NSString stringWithUTF8String:internal->SerializerType()];
}

@end
