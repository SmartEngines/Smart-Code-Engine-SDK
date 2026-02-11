/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_IMPLS_CODE_OBJECT_FIELD_IMPL_H_INCLUDED
#define OBJCCODEENGINE_IMPLS_CODE_OBJECT_FIELD_IMPL_H_INCLUDED

#import <objccodeengine/code_object_field.h>

#include <codeengine/code_object_field.h>

@interface SECodeFieldRef (Internal)

- (instancetype) initFromInternalCodeFieldPointer:(se::code::CodeField *)fieldptr
                               withMutabilityFlag:(BOOL)mutabilityFlag;
- (se::code::CodeField *) getInternalCodeFieldPointer;

@end


@interface SECodeField (Internal)

- (instancetype) initFromInternalCodeField:(const se::code::CodeField &)field;
- (const se::code::CodeField &) getInternalCodeField;

@end


@interface SECodeFieldsMapIterator (Internal)

- (instancetype) initFromInternalCodeFieldsMapIterator:(const se::code::CodeFieldsMapIterator &)iter;
- (const se::code::CodeFieldsMapIterator &) getInternalCodeFieldsMapIterator;

@end

#endif // OBJCCODEENGINE_IMPLS_CODE_OBJECT_FIELD_IMPL_H_INCLUDED
