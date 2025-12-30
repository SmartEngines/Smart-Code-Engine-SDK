/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objccodeengine_impl/code_object_field_impl.h>

#import <objcsecommon_impl/se_string_impl.h>
#import <objcsecommon_impl/se_common_proxy_impl.h>

#include <memory>

@implementation SECodeFieldRef {
  se::code::CodeField* ptr;
  bool is_mutable;
}

- (instancetype) initFromInternalCodeFieldPointer:(se::code::CodeField *)fieldptr
                               withMutabilityFlag:(BOOL)mutabilityFlag {
  if (self = [super init]) {
    ptr = fieldptr;
    is_mutable = (YES == mutabilityFlag);
  }
  return self;
}

- (se::code::CodeField *) getInternalCodeFieldPointer {
  return ptr;
}

- (BOOL) isMutable {
  return is_mutable? YES : NO;
}

- (SECodeField *) clone {
  return [[SECodeField alloc] initFromInternalCodeField:(*ptr)];
}

- (NSString *) name {
  return [NSString stringWithUTF8String:ptr->Name()];
}

- (void) setNameTo:(nonnull NSString *)name {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetName([name UTF8String]);
  }
}

- (BOOL) isAccepted {
  return ptr->IsAccepted()? YES : NO;
}

- (void) setisAcceptedTo:(BOOL)is_accepted {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetIsAccepted(YES == is_accepted);
  }
}

- (double) getConfidence {
  return ptr->GetConfidence();
}

- (void) setConfidenceTo:(float)confidence {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetConfidence(confidence);
  }
}

- (BOOL) isTerminal {
  return ptr->IsTerminal()? YES : NO;
}

- (void) setIsTerminalTo:(BOOL)is_terminal {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetIsTerminal(YES == is_terminal);
  }
}

- (BOOL) hasBinaryRepresentation {
  return ptr->HasBinaryRepresentation()? YES : NO;
}

- (SECommonByteString *) getBinaryRepresentation {
  return [[SECommonByteString alloc] 
      initFromInternalByteString:ptr->GetBinaryRepresentation()];
}

- (void) setBinaryRepresentationTo:(nonnull SECommonByteString *)byte_string {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetBinaryRepresentation([byte_string getInternalByteString]);
  }
}

- (BOOL) hasOcrStringRepresentation {
  return ptr->HasOcrStringRepresentation()? YES : NO;
}

- (SECommonOcrString *) getOcrString {
  return [[SECommonOcrString alloc] 
      initFromInternalOcrString:ptr->GetOcrString()];
}

- (void) setOcrStringRepresentationTo:(nonnull SECommonOcrString *)ocr_string {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetOcrStringRepresentation([ocr_string getInternalOcrString]);
  }
}

@end


@implementation SECodeField {
  std::unique_ptr<se::code::CodeField> internal;
}

- (instancetype) initFromInternalCodeField:(const se::code::CodeField &)field {
  if (self = [super init]) {
    internal.reset(new se::code::CodeField(field));
  }
  return self;
}

- (const se::code::CodeField &) getInternalCodeField {
  return *internal;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(new se::code::CodeField);
  }
  return self;
}

- (instancetype) initFromByteString:(NSString *)name
                     withByteString:(SECommonByteString *)byte_string {
  if (self = [super init]) {
    try {
      internal.reset(new se::code::CodeField(
          [name UTF8String],
          [byte_string getInternalByteString]));
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
      return nil;
    }
  }
  return self;
}

- (instancetype) initFromOcrString:(NSString *)name
                     withOcrString:(SECommonOcrString *)ocr_string {
  if (self = [super init]) {
    try {
      internal.reset(new se::code::CodeField(
          [name UTF8String],
          [ocr_string getInternalOcrString]));
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
      return nil;
    }
  }
  return self;
}

- (SECodeFieldRef *) getRef {
  return [[SECodeFieldRef alloc] 
      initFromInternalCodeFieldPointer:internal.get()
                    withMutabilityFlag:NO];
}

- (SECodeFieldRef *) getMutableRef {
  return [[SECodeFieldRef alloc] 
      initFromInternalCodeFieldPointer:internal.get()
                    withMutabilityFlag:YES];
}

@end


@implementation SECodeFieldsMapIterator {
  std::unique_ptr<se::code::CodeFieldsMapIterator> internal;
}

- (instancetype) initFromInternalCodeFieldsMapIterator:(const se::code::CodeFieldsMapIterator &)iter {
  if (self = [super init]) {
    internal.reset(new se::code::CodeFieldsMapIterator(iter));
  }
  return self;
}

- (const se::code::CodeFieldsMapIterator &) getInternalCodeFieldsMapIterator {
  return *internal;
}

- (instancetype) initWithOther:(SECodeFieldsMapIterator *)other {
  if (self = [super init]) {
    internal.reset(new se::code::CodeFieldsMapIterator([other getInternalCodeFieldsMapIterator]));
  }
  return self;
}

- (BOOL) isEqualToIter:(SECodeFieldsMapIterator *)other {
  return internal->Equals([other getInternalCodeFieldsMapIterator])? YES : NO;
}

- (NSString *) getKey {
  return [NSString stringWithUTF8String:internal->GetKey()];
}

- (SECodeFieldRef *) getValue {
  return [[SECodeFieldRef alloc] 
      initFromInternalCodeFieldPointer:const_cast<se::code::CodeField*>(&internal->GetValue())
                    withMutabilityFlag:NO];
}

- (void) advance {
  internal->Advance();
}

@end
