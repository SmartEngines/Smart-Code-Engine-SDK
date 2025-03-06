/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_IMPLS_CODE_ENGINE_SESSION_IMPL_H_INCLUDED
#define OBJCCODEENGINE_IMPLS_CODE_ENGINE_SESSION_IMPL_H_INCLUDED

#import <objccodeengine/code_engine_session.h>

#import <objccodeengine/code_engine_feedback.h>
#import <objccodeengine_impl/code_engine_proxy_impl.h>

#include <codeengine/code_engine_session.h>

@interface SECodeEngineSession (Internal)
  
- (instancetype) initFromCreatedSession:(se::code::CodeEngineSession *)session_ptr
       withCreatedProxyWorkflowReporter:(ProxyWorkflowReporter *)proxy_workflow_reporter
  withCreatedProxyVisualizationReporter:(ProxyVisualizationReporter *)proxy_visualization_reporter;

- (se::code::CodeEngineSession &) getInternalSession;

@end

#endif // OBJCCODEENGINE_IMPLS_CODE_ENGINE_SESSION_IMPL_H_INCLUDED
