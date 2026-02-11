/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_CODE_ENGINE_SESSION_SETTINGS_H_INCLUDE
#define OBJCCODEENGINE_CODE_ENGINE_SESSION_SETTINGS_H_INCLUDE

#import <Foundation/Foundation.h>

#import <objcsecommon/se_strings_iterator.h>

@interface SECodeEngineSessionSettings : NSObject

- (nonnull instancetype) initFromOther:(nonnull SECodeEngineSessionSettings *)other;

- (nonnull NSString *) getOptionWithName:(nonnull NSString *)name;

- (nonnull SECommonStringsMapIterator *) settingsBegin;
- (nonnull SECommonStringsMapIterator *) settingsEnd;

- (BOOL) hasOptionWithName:(nonnull NSString *)name;

- (void) setOptionWithName:(nonnull NSString *)name
                        to:(nonnull NSString *)value;

@end

#endif // OBJCCODEENGINE_CODE_ENGINE_SESSION_SETTINGS_H_INCLUDE
