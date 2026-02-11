/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objccodeengine_impl/code_engine_session_impl.h>

#import <objccodeengine_impl/code_engine_result_impl.h>
#import <objccodeengine_impl/code_engine_feedback_impl.h>
#import <objccodeengine_impl/code_engine_proxy_impl.h>

#import <objcsecommon_impl/se_image_impl.h>
#import <objcsecommon_impl/se_common_proxy_impl.h>

#include <codeengine/code_engine_session.h>
#include <codeengine/code_engine_feedback.h>

#include <memory>

@implementation SECodeEngineSession {
  std::unique_ptr<se::code::CodeEngineSession> internal;
  std::unique_ptr<ProxyWorkflowReporter> proxyWorkflowReporter;
  std::unique_ptr<ProxyVisualizationReporter> proxyVisualizationReporter;
}

- (instancetype) initFromCreatedSession:(se::code::CodeEngineSession *)session_ptr
       withCreatedProxyWorkflowReporter:(ProxyWorkflowReporter *)proxy_workflow_reporter
  withCreatedProxyVisualizationReporter:(ProxyVisualizationReporter *)proxy_visualization_reporter {

  if (self = [super init]) {
    internal.reset(session_ptr);
    proxyWorkflowReporter.reset(proxy_workflow_reporter);
    proxyVisualizationReporter.reset(proxy_visualization_reporter);
  }
  return self;
}

- (se::code::CodeEngineSession &) getInternalSession {
  return *internal;
}

- (NSString *) getActivationRequest {
  try {
    return [NSString stringWithUTF8String:internal->GetActivationRequest()];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) activate:(NSString *)activation_response {
  try {
    internal->Activate([activation_response UTF8String]);
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
}

- (BOOL) isActivated {
  try {
    return internal->IsActivated()? YES : NO;
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return false;
}



- (SECodeEngineResultRef *) process:(SECommonImageRef *)image {
  try {
    return [[SECodeEngineResultRef alloc] 
        initFromInternalResultPointer:const_cast<se::code::CodeEngineResult*>(&internal->Process(*[image getInternalImagePointer]))
                   withMutabilityFlag:NO];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (SECodeEngineResultRef *) getCurrentResult {
  try {
    return [[SECodeEngineResultRef alloc] 
        initFromInternalResultPointer:const_cast<se::code::CodeEngineResult*>(&internal->GetCurrentResult())
                   withMutabilityFlag:NO];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil; 
}

- (BOOL) isResultTerminal {
  return internal->IsResultTerminal()? YES : NO;
}

- (void) reset {
  try {
    internal->Reset();    
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
}

@end
