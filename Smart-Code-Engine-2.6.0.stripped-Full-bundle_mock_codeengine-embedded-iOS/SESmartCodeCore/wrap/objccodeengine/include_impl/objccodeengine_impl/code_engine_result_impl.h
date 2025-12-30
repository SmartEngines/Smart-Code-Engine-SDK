/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_IMPLS_CODE_ENGINE_RESULT_IMPL_H_INCLUDED
#define OBJCCODEENGINE_IMPLS_CODE_ENGINE_RESULT_IMPL_H_INCLUDED

#import <objccodeengine/code_engine_result.h>

#include <codeengine/code_engine_result.h>


@interface SECodeEngineResultRef (Internal)

- (instancetype) initFromInternalResultPointer:(se::code::CodeEngineResult *)resptr
                            withMutabilityFlag:(BOOL)mutabilityFlag;
- (se::code::CodeEngineResult *) getInternalResultPointer;

@end


@interface SECodeEngineResult (Internal)

- (instancetype) initFromInternalResult:(const se::code::CodeEngineResult &)res;
- (const se::code::CodeEngineResult &) getInternalResult;

@end

#endif // OBJCCODEENGINE_IMPLS_CODE_ENGINE_RESULT_IMPL_H_INCLUDED
