/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_string_impl.h>
#import <objcsecommon_impl/se_serialization_impl.h>

#include <memory>

@implementation SECommonOcrCharVariant {
  std::unique_ptr<se::common::OcrCharVariant> internal;  
}

- (instancetype) initFromInternalOcrCharVariant:(const se::common::OcrCharVariant &)var {
  if (self = [super init]) {
    internal.reset(new se::common::OcrCharVariant(var));
  }
  return self;
}

- (const se::common::OcrCharVariant &) getInternalOcrCharVariant {
  return *internal;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(new se::common::OcrCharVariant);
  }
  return self;
}

- (instancetype) initWithChar:(NSString *)character 
                     withConf:(double)confidence {
  if (self = [super init]) {
    internal.reset(new se::common::OcrCharVariant(
        [character UTF8String], confidence));
  }
  return self;
}

- (NSString *) getCharacter {
  return [NSString stringWithUTF8String:internal->GetCharacter()];
}

- (void) setCharacterTo:(NSString *)character {
  internal->SetCharacter([character UTF8String]);
}

- (double) getConfidence {
  return internal->GetConfidence();
}

- (void) setConfidence:(double)confidence {
  internal->SetConfidence(confidence);
}

- (void) serialize:(SECommonSerializer *)serializer {
  internal->Serialize([serializer getInternalSerializer]);
}

@end
