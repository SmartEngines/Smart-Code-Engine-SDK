/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCSECOMMON_IMPL_SE_SERIALIZATION_H_INCLUDED
#define OBJCSECOMMON_IMPL_SE_SERIALIZATION_H_INCLUDED

#import <objcsecommon/se_serialization.h>

#include <secommon/se_serialization.h>

#include <memory>

@interface SECommonSerializationParameters (Internal)

- (instancetype) initFromInternalSerializationParameters:(const se::common::SerializationParameters &)params;
- (const se::common::SerializationParameters &) getInternalSerializationParameters;

@end


@interface SECommonSerializer (Internal)

- (instancetype) initFromCreatedInternalPointer:(se::common::Serializer *)serializer;
- (se::common::Serializer &) getInternalSerializer;

@end

#endif // OBJCSECOMMON_IMPL_SE_SERIALIZATION_H_INCLUDED