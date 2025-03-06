/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <objccodeengine_impl/code_engine_session_settings_impl.h>

#import <objcsecommon_impl/se_strings_iterator_impl.h>
#import <objcsecommon_impl/se_common_proxy_impl.h>

#include <codeengine/code_engine_session_settings.h>
#include <secommon/se_exception.h>

#import <memory>

@implementation SECodeEngineSessionSettings {
  std::unique_ptr<se::code::CodeEngineSessionSettings> internal;
}

- (instancetype) initFromInternalSessionSettings:(const se::code::CodeEngineSessionSettings &)settings {
  if (self = [super init]) {
    internal.reset(settings.Clone());
  }
  return self;
}

- (instancetype) initFromCreatedSessionSettings:(se::code::CodeEngineSessionSettings *)settings_ptr {
  if (self = [super init]) {
    internal.reset(settings_ptr);
  }
  return self;
}

- (const se::code::CodeEngineSessionSettings &) getInternalSessionSettings {
  return *internal;
}

- (instancetype) initFromOther:(SECodeEngineSessionSettings *)other {
  if (self = [super init]) {
    internal.reset([other getInternalSessionSettings].Clone());
  }
  return self;
}

- (NSString *) getOptionWithName:(NSString *)name {
  try {
    return [NSString stringWithUTF8String:internal->GetOption([name UTF8String])];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (BOOL) hasOptionWithName:(NSString *)name {
  return internal->HasOption([name UTF8String])? YES : NO;
}

- (void) setOptionWithName:(NSString *)name
                        to:(NSString *)value {
  internal->SetOption([name UTF8String], [value UTF8String]);
}

- (SECommonStringsMapIterator *) settingsBegin {
  return [[SECommonStringsMapIterator alloc] 
      initFromInternalStringsMapIterator:internal->SettingsBegin()];
}

- (SECommonStringsMapIterator *) settingsEnd {
  return [[SECommonStringsMapIterator alloc] 
      initFromInternalStringsMapIterator:internal->SettingsEnd()];
}

@end
