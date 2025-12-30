/*
  Copyright (c) 2016-2025, Smart Engines Service LLC.
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_CODE_ENGINE_SESSION_H_INCLUDED
#define OBJCCODEENGINE_CODE_ENGINE_SESSION_H_INCLUDED

#import <Foundation/Foundation.h>

#import <objccodeengine/code_engine_result.h>
#import <objccodeengine/code_object.h>

@interface SECodeEngineSession : NSObject

- (nonnull NSString *) getActivationRequest;
- (void) activate:(nonnull NSString *)activation_response;

- (BOOL) isActivated;

- (nonnull SECodeEngineResultRef *) process:(nonnull SECommonImageRef *)image;
- (nonnull SECodeEngineResultRef *) getCurrentResult;

- (BOOL) isResultTerminal;

- (void) reset;

@end

#endif // OBJCCODEENGINE_CODE_ENGINE_SESSION_H_INCLUDED
