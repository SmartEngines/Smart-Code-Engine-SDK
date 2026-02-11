/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCSECOMMON_IMPL_SE_STRING_H_INCLUDED
#define OBJCSECOMMON_IMPL_SE_STRING_H_INCLUDED

#import <objcsecommon/se_string.h>

#include <secommon/se_string.h>

@interface SECommonOcrChar (Internal)

- (instancetype) initFromInternalOcrChar:(const se::common::OcrChar &)ocrchar;
- (const se::common::OcrChar &) getInternalOcrChar;

@end


@interface SECommonOcrCharVariant (Internal)

- (instancetype) initFromInternalOcrCharVariant:(const se::common::OcrCharVariant &)var;
- (const se::common::OcrCharVariant &) getInternalOcrCharVariant;

@end


@interface SECommonOcrString (Internal)

- (instancetype) initFromInternalOcrString:(const se::common::OcrString &)ostr;
- (const se::common::OcrString &) getInternalOcrString;

@end


@interface SECommonByteString (Internal)

- (instancetype) initFromInternalByteString:(const se::common::ByteString &)bstr;
- (const se::common::ByteString &) getInternalByteString;

@end

#endif // OBJCSECOMMON_IMPL_SE_STRING_H_INCLUDED