/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef CODEENGINE_IMPLS_CODE_OBJECT_IMPL_H_INCLUDED
#define CODEENGINE_IMPLS_CODE_OBJECT_IMPL_H_INCLUDED

#import <objccodeengine/code_object.h>

#include <codeengine/code_object.h>

@interface SECodeObjectRef (Internal)

- (instancetype) initFromInternalCodeObjectPointer:(se::code::CodeObject *)objptr
                               withMutabilityFlag:(BOOL)mutabilityFlag;
- (se::code::CodeObject *) getInternalCodeObjectPointer;

@end


@interface SECodeObject (Internal)

- (instancetype) initFromInternalCodeObject:(const se::code::CodeObject &)obj;
- (const se::code::CodeObject &) getInternalCodeObject;

@end


@interface SECodeObjectsMapIterator (Internal)

- (instancetype) initFromInternalCodeObjectsMapIterator:(const se::code::CodeObjectsMapIterator &)iter;
- (const se::code::CodeObjectsMapIterator &) getInternalCodeObjectsMapIterator;

@end

#endif // CODEENGINE_IMPLS_CODE_OBJECT_IMPL_H_INCLUDED
