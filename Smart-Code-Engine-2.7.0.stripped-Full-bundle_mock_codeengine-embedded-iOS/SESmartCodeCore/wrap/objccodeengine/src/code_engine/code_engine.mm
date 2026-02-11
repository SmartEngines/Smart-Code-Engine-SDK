/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objccodeengine_impl/code_engine_impl.h>

#import <objccodeengine_impl/code_engine_session_impl.h>
#import <objccodeengine_impl/code_engine_feedback_impl.h>
#import <objccodeengine_impl/code_engine_proxy_impl.h>
#import <objccodeengine_impl/code_engine_session_settings_impl.h>

#import <objcsecommon_impl/se_common_proxy_impl.h>

#include <codeengine/code_engine.h>

#include <memory>

se::code::CodeEngineType et_e2i(SECodeEngineType et) {
  switch(et) {
    case SECodeEngine_Barcode:
      return se::code::CodeEngine_Barcode;
    case SECodeEngine_CodeTextLine:
      return se::code::CodeEngine_CodeTextLine;
    case SECodeEngine_MRZ:
      return se::code::CodeEngine_MRZ;
    case SECodeEngine_BankCard:
      return se::code::CodeEngine_BankCard;
  }
  return se::code::CodeEngine_Barcode;
}

SECodeEngineType et_i2e(se::code::CodeEngineType et) {
  switch(et) {
    case se::code::CodeEngine_Barcode:
      return SECodeEngine_Barcode;
    case se::code::CodeEngine_CodeTextLine:
      return SECodeEngine_CodeTextLine;
    case se::code::CodeEngine_MRZ:
      return SECodeEngine_MRZ;
    case se::code::CodeEngine_BankCard:
      return SECodeEngine_BankCard;
  }
  return SECodeEngine_Barcode;
}

se::code::EngineSettingsGroup sg_e2i(SE_EngineSettingsGroup sg) {
  switch(sg) {
    case SE_Global:
      return se::code::EngineSettingsGroup::Global;
    case SE_Barcode:
      return se::code::EngineSettingsGroup::Barcode;
    case SE_Card:
      return se::code::EngineSettingsGroup::Card;
    case SE_CodeTextLine:
      return se::code::EngineSettingsGroup::CodeTextLine;
    case SE_Mrz:
      return se::code::EngineSettingsGroup::Mrz;
  }
  return se::code::EngineSettingsGroup::Global;
}

SE_EngineSettingsGroup sg_i2e(se::code::EngineSettingsGroup sg) {
  switch(sg) {
    case se::code::EngineSettingsGroup::Global:
      return SE_Global;
    case se::code::EngineSettingsGroup::Barcode:
      return SE_Barcode;
    case se::code::EngineSettingsGroup::Card:
      return SE_Card;
    case se::code::EngineSettingsGroup::CodeTextLine:
      return SE_CodeTextLine;
    case se::code::EngineSettingsGroup::Mrz:
      return SE_Mrz;
  }
  return SE_Global;
}

se::code::BarcodePreset bp_e2i(SE_BarcodePreset bp) {
  switch(bp) {
    case SE_GS1:
      return se::code::BarcodePreset::GS1;
    case SE_AAMVA:
      return se::code::BarcodePreset::AAMVA;
    case SE_URL:
      return se::code::BarcodePreset::URL;
    case SE_VCARD:
      return se::code::BarcodePreset::VCARD;
    case SE_EMAIL:
      return se::code::BarcodePreset::EMAIL;
    case SE_ICALENDAR:
      return se::code::BarcodePreset::ICALENDAR;
    case SE_PHONE:
      return se::code::BarcodePreset::PHONE;
    case SE_SMS:
      return se::code::BarcodePreset::SMS;
    case SE_ISBN:
      return se::code::BarcodePreset::ISBN;
    case SE_WIFI:
      return se::code::BarcodePreset::WIFI;
    case SE_GEO:
      return se::code::BarcodePreset::GEO;
    case SE_NONE:
      return se::code::BarcodePreset::NONE;
  }
  return se::code::BarcodePreset::NONE;
}

SE_BarcodePreset bp_i2e(se::code::BarcodePreset bp) {
  switch(bp) {
    case se::code::BarcodePreset::GS1:
      return SE_GS1;
    case se::code::BarcodePreset::AAMVA:
      return SE_AAMVA;
    case se::code::BarcodePreset::URL:
      return SE_URL;
    case se::code::BarcodePreset::VCARD:
      return SE_VCARD;
    case se::code::BarcodePreset::EMAIL:
      return SE_EMAIL;
    case se::code::BarcodePreset::ICALENDAR:
      return SE_ICALENDAR;
    case se::code::BarcodePreset::PHONE:
      return SE_PHONE;
    case se::code::BarcodePreset::SMS:
      return SE_SMS;
    case se::code::BarcodePreset::ISBN:
      return SE_ISBN;
    case se::code::BarcodePreset::WIFI:
      return SE_WIFI;
    case se::code::BarcodePreset::GEO:
      return SE_GEO;
    case se::code::BarcodePreset::NONE:
      return SE_NONE;
  }
  return SE_NONE;
}

@implementation SECodeEngine {
  std::unique_ptr<se::code::CodeEngine> internal;
}

+ (SE_EngineSettingsGroup) engineSettingsGroupFromStringWithGroupName:(NSString *)group_name {
  return sg_i2e(se::code::engineSettingsGroupFromString([group_name UTF8String]));
}

+ (NSString *) toStringFromEngineSettingsGroup:(SE_EngineSettingsGroup)group {
  return [NSString stringWithUTF8String:se::code::toString(sg_e2i(group))];
}

+ (NSString *) presetToStringFromBarcodePreset:(SE_BarcodePreset)preset {
  return [NSString stringWithUTF8String:se::code::presetToString(bp_e2i(preset))];
}

+ (NSString *) getVersion {
  return [NSString stringWithUTF8String:se::code::CodeEngine::GetVersion()];
}

- (se::code::CodeEngine &) getInternalEngine {
  return *internal;
}

- (instancetype) initFromFile:(NSString *)filename
                 withLazyInit:(BOOL)lazy_initialization {
  if (self = [super init]) {
    try {
      internal.reset(se::code::CodeEngine::Create(
          [filename UTF8String], 
          YES == lazy_initialization));
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
      return nil;
    }
  }
  return self;
}

- (instancetype) initFromBuffer:(unsigned char *)buffer
                 withBuffersize:(int)buffer_size
                   withLazyInit:(BOOL)lazy_initialization {
  if (self = [super init]) {
    try {
      internal.reset(se::code::CodeEngine::Create(
          buffer, 
          buffer_size, 
          YES == lazy_initialization));
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
      return nil;
    }
  }
  return self;
}

- (instancetype) initEmbeddedWithLazyInit:(BOOL)lazy_initialization {
  if (self = [super init]) {
    try {
      internal.reset(se::code::CodeEngine::CreateFromEmbeddedBundle(
          YES == lazy_initialization));
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
      return nil;
    }
  }
  return self;
}

- (SECodeEngineSessionSettings *) getDefaultSessionSettings {
  try {
    return [[SECodeEngineSessionSettings alloc]
        initFromCreatedSessionSettings:internal->GetDefaultSessionSettings()];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (SECodeEngineSession *) spawnSessionWithSettings:(SECodeEngineSessionSettings *)settings
                               withSignature:(NSString *)signature
                        withWorkflowFeedback:(id<SECodeEngineWorkflowFeedback>)workflow_reporter
                   withVisualizationFeedback:(id<SECodeEngineVisualizationFeedback>)visualization_reporter {
  try {
    std::unique_ptr<ProxyWorkflowReporter> proxy_workflow_reporter(
        new ProxyWorkflowReporter(workflow_reporter));
    ProxyWorkflowReporter* proxy_workflow_reporter_ptr = proxy_workflow_reporter.get();

    std::unique_ptr<ProxyVisualizationReporter> proxy_visualization_reporter(
        new ProxyVisualizationReporter(visualization_reporter));
    ProxyVisualizationReporter* proxy_visualization_reporter_ptr = proxy_visualization_reporter.get();

    return [[SECodeEngineSession alloc]
        initFromCreatedSession:internal->SpawnSession(
            [settings getInternalSessionSettings],
            [signature UTF8String],
            proxy_workflow_reporter_ptr,
            proxy_visualization_reporter_ptr)
        withCreatedProxyWorkflowReporter:proxy_workflow_reporter.release()
        withCreatedProxyVisualizationReporter:proxy_visualization_reporter.release()];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (BOOL) isEngineAvailableWithCodeEngineType:(SECodeEngineType)engine_type {
  return internal->IsEngineAvailable(et_e2i(engine_type));
}

@end
