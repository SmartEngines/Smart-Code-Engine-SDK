/*
  Copyright (c) 2016-2025, Smart Engines Service LLC.
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_CODE_ENGINE_H_INCLUDED
#define OBJCCODEENGINE_CODE_ENGINE_H_INCLUDED

#import <Foundation/Foundation.h>

#import <objccodeengine/code_engine_feedback.h>
#import <objccodeengine/code_engine_session.h>
#import <objccodeengine/code_engine_session_settings.h>

typedef enum { 
  SECodeEngine_Barcode,
  SECodeEngine_CodeTextLine,
  SECodeEngine_MRZ,
  SECodeEngine_BankCard
} SECodeEngineType;

typedef enum { 
  SE_Global,
  SE_Barcode,
  SE_Card,
  SE_CodeTextLine,
  SE_Mrz
} SE_EngineSettingsGroup;

typedef enum { 
  SE_GS1,
  SE_AAMVA,
  SE_URL,
  SE_VCARD,
  SE_EMAIL,
  SE_ICALENDAR,
  SE_PHONE,
  SE_SMS,
  SE_ISBN,
  SE_WIFI,
  SE_GEO,
  SE_NONE,
} SE_BarcodePreset;


@interface SECodeEngine : NSObject

+ (SE_EngineSettingsGroup) engineSettingsGroupFromStringWithGroupName:(nonnull NSString *)group_name;

+ (nonnull NSString *) toStringFromEngineSettingsGroup:(SE_EngineSettingsGroup)group;

+ (nonnull NSString *) presetToStringFromBarcodePreset:(SE_BarcodePreset)preset;

+ (nonnull NSString *) getVersion;

- (nonnull instancetype) initFromFile:(nonnull NSString *)filename
                         withLazyInit:(BOOL)lazy_initialization;

- (nonnull instancetype) initFromBuffer:(nonnull unsigned char *)buffer
                         withBuffersize:(int)buffer_size
                           withLazyInit:(BOOL)lazy_initialization;

- (nonnull instancetype) initEmbeddedWithLazyInit:(BOOL)lazy_initialization;

- (nonnull SECodeEngineSessionSettings *) getDefaultSessionSettings;

- (nonnull SECodeEngineSession *) spawnSessionWithSettings:(nonnull SECodeEngineSessionSettings *)settings
                                     		 withSignature:(nonnull NSString *)signature
                              		  withWorkflowFeedback:(nullable id<SECodeEngineWorkflowFeedback>)workflow_reporter
                         		 withVisualizationFeedback:(nullable id<SECodeEngineVisualizationFeedback>)visualization_reporter;

- (BOOL) isEngineAvailableWithCodeEngineType:(SECodeEngineType)engine_type;

@end

#endif // OBJCCODEENGINE_CODE_ENGINE_H_INCLUDED
