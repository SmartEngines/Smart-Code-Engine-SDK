/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_IMPLS_CODE_ENGINE_IMPL_H_INCLUDED
#define OBJCCODEENGINE_IMPLS_CODE_ENGINE_IMPL_H_INCLUDED

#import <objccodeengine/code_engine.h>

#include <codeengine/code_engine.h>

@interface SECodeEngine (Internal)
  
- (se::code::CodeEngine &) getInternalEngine;

@end

#endif // OBJCCODEENGINE_IMPLS_CODE_ENGINE_IMPL_H_INCLUDED
