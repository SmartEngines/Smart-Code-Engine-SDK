/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objccodeengine_impl/code_engine_result_impl.h>
#import <objccodeengine_impl/code_object_impl.h>

#import <objcsecommon_impl/se_common_proxy_impl.h>

#include <secommon/se_exception.h>
#include <codeengine/code_engine_result.h>

#include <memory>

@implementation SECodeEngineResultRef {
  se::code::CodeEngineResult* ptr;
  bool is_mutable;
}

- (instancetype) initFromInternalResultPointer:(se::code::CodeEngineResult *)resptr
                            withMutabilityFlag:(BOOL)mutabilityFlag {
  if (self = [super init]) {
    ptr = resptr;
    is_mutable = (YES == mutabilityFlag);
  }
  return self;
}

- (se::code::CodeEngineResult *) getInternalResultPointer {
  return ptr;
}

- (BOOL) isMutable {
  return is_mutable? YES : NO;
}

- (SECodeEngineResult *) clone {
  return [[SECodeEngineResult alloc] initFromInternalResult:(*ptr)];
}

- (int) getObjectCount {
  return ptr->GetObjectCount();
}

- (BOOL) hasObjectWithName:(NSString *)object_name {
  return ptr->HasObject([object_name UTF8String])? YES : NO;
}

- (SECodeObjectRef *) getCodeObjectWithName:(NSString *)object_name {
  try {
    return [[SECodeObjectRef alloc]
        initFromInternalCodeObjectPointer:const_cast<se::code::CodeObject*>(&ptr->GetCodeObject([object_name UTF8String]))
            withMutabilityFlag:NO];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) setCodeObjectWithName:(NSString *)object_name
                            to:(SECodeObjectRef *)code_object {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetCodeObject([object_name UTF8String], *[code_object getInternalCodeObjectPointer]);
  }
}

- (SECodeObjectsMapIterator *) objectsBegin {
  return [[SECodeObjectsMapIterator alloc]
      initFromInternalCodeObjectsMapIterator:ptr->ObjectsBegin()];
}

- (SECodeObjectsMapIterator *) objectsEnd {
  return [[SECodeObjectsMapIterator alloc]
      initFromInternalCodeObjectsMapIterator:ptr->ObjectsEnd()];
}

- (BOOL) isTerminal {
  return ptr->IsTerminal()? YES : NO;
}

- (void) setTerminal {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetTerminal();
  }
}

@end


@implementation SECodeEngineResult {
  std::unique_ptr<se::code::CodeEngineResult> internal;
}

- (instancetype) initFromInternalResult:(const se::code::CodeEngineResult &)res {
  if (self = [super init]) {
    internal.reset(new se::code::CodeEngineResult(res));
  }
  return self;
}

- (const se::code::CodeEngineResult &) getInternalResult {
  return *internal;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(new se::code::CodeEngineResult);
  }
  return self;
}

- (instancetype) initWithIsTerminal:(BOOL)is_terminal {
  if (self = [super init]) {
    internal.reset(new se::code::CodeEngineResult(YES == is_terminal));
  }
  return self;
}

- (SECodeEngineResultRef *) getRef {
  return [[SECodeEngineResultRef alloc]
      initFromInternalResultPointer:internal.get()
                 withMutabilityFlag:NO];
}

- (SECodeEngineResultRef *) getMutableRef {
  return [[SECodeEngineResultRef alloc]
      initFromInternalResultPointer:internal.get()
                 withMutabilityFlag:YES];
}

@end
