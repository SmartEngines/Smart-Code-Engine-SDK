/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_string_impl.h>
#import <objcsecommon_impl/se_serialization_impl.h>
#import <objcsecommon_impl/se_common_proxy_impl.h>

#include <memory>

@implementation SECommonByteString {
  std::unique_ptr<se::common::ByteString> internal;  
}

- (instancetype) initFromInternalByteString:(const se::common::ByteString &)bstr {
  if (self = [super init]) {
    internal.reset(new se::common::ByteString(bstr));
  }
  return self;
}

- (const se::common::ByteString &) getInternalByteString {
  return *internal;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(new se::common::ByteString);
  }
  return self;
}

- (int) getLength {
  return internal->GetLength();
}

- (int) getRequiredBase64BufferLength {
  return internal->GetRequiredBase64BufferLength();
}

- (NSString *) getBase64String {
  return [NSString stringWithUTF8String:internal->GetBase64String().GetCStr()];
}

- (int) getRequiredHexBufferLength {
  return internal->GetRequiredHexBufferLength();
}

- (NSString *) getHexString {
  return [NSString stringWithUTF8String:internal->GetHexString().GetCStr()];
}

@end
