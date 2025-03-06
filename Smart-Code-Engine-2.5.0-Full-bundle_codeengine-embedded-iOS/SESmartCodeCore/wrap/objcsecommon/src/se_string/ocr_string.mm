/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_string_impl.h>
#import <objcsecommon_impl/se_serialization_impl.h>
#import <objcsecommon_impl/se_common_proxy_impl.h>

#include <secommon/se_exception.h>

#include <memory>
#include <vector>

@implementation SECommonOcrString {
  std::unique_ptr<se::common::OcrString> internal;  
}

- (instancetype) initFromInternalOcrString:(const se::common::OcrString &)ostr {
  if (self = [super init]) {
    internal.reset(new se::common::OcrString(ostr));
  }
  return self;
}

- (const se::common::OcrString &) getInternalOcrString {
  return *internal;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(new se::common::OcrString);
  }
  return self;
}

- (instancetype) initWithString:(NSString *)string {
  if (self = [super init]) {
    internal.reset(new se::common::OcrString([string UTF8String]));
  }
  return self;
}

- (instancetype) initWithChars:(NSArray *)chars {
  if (self = [super init]) {
    std::vector<se::common::OcrChar> internal_chars;
    for (int i = 0; i < static_cast<int>([chars count]); ++i) {
      SECommonOcrChar* oc = [chars objectAtIndex:i];
      if (![oc isKindOfClass:[SECommonOcrChar class]]) {
        NSException* exc = [NSException
            exceptionWithName:@"InvalidArgumentException"
            reason:@"OcrString must contain ocr chars"
            userInfo:nil];
        @throw exc;
        return nil;
      }
      internal_chars.push_back([oc getInternalOcrChar]);
    }
    internal.reset(new se::common::OcrString(
        internal_chars.data(), static_cast<int>(internal_chars.size())));
  }
  return self;
}

- (int) getCharsCount {
  return internal->GetCharsCount();
}

- (SECommonOcrChar *) getCharAt:(int)index {
  try {
    return [[SECommonOcrChar alloc] initFromInternalOcrChar:internal->GetChar(index)];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) setCharAt:(int)index
                to:(SECommonOcrChar *)ocrchar {
  try {
    return internal->SetChar(index, [ocrchar getInternalOcrChar]);
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
}

- (void) unpackChars {
  internal->UnpackChars();
}

- (void) repackChars {
  internal->RepackChars();
}

- (void) appendChar:(SECommonOcrChar *)ocrchar {
  internal->AppendChar([ocrchar getInternalOcrChar]);
}

- (void) appendString:(SECommonOcrString *)string {
  internal->AppendString([string getInternalOcrString]);
}

- (void) resize:(int)size {
  try {
    internal->Resize(size);
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
}

- (void) sortVariants {
  internal->SortVariants();
}

- (NSString *) getFirstString {
  return [NSString stringWithUTF8String:internal->GetFirstString().GetCStr()];
}

- (void) serialize:(SECommonSerializer *)serializer {
  internal->Serialize([serializer getInternalSerializer]);
}

@end
