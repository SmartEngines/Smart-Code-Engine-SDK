/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_CODE_ENGINE_SESSION_SETTINGS_IMPL_H
#define OBJCCODEENGINE_CODE_ENGINE_SESSION_SETTINGS_IMPL_H

#import <objccodeengine/code_engine_session_settings.h>

#include <codeengine/code_engine_session_settings.h>

@interface SECodeEngineSessionSettings (Internal)

- (instancetype) initFromInternalSessionSettings:(const se::code::CodeEngineSessionSettings &)settings;
- (instancetype) initFromCreatedSessionSettings:(se::code::CodeEngineSessionSettings *)settings_ptr;
- (const se::code::CodeEngineSessionSettings &) getInternalSessionSettings;

@end

#endif // OBJCCODEENGINE_CODE_ENGINE_SESSION_SETTINGS_IMPL_H
