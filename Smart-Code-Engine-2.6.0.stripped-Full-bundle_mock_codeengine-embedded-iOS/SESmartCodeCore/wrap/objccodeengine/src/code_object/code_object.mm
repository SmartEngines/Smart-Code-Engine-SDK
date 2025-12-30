/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objccodeengine_impl/code_object_impl.h>
#import <objccodeengine_impl/code_object_field_impl.h>

#import <objcsecommon_impl/se_string_impl.h>
#import <objcsecommon_impl/se_strings_iterator_impl.h>
#import <objcsecommon_impl/se_geometry_impl.h>
#import <objcsecommon_impl/se_common_proxy_impl.h>
#import <objcsecommon_impl/se_image_impl.h>

#import <memory>

se::code::CodeObjectType ot_e2i(SECodeObjectType ot) {
  switch(ot) {
    case SECodeObject_LinearBarcode:
      return se::code::CodeObject_LinearBarcode;
    case SECodeObject_MatrixBarcode:
      return se::code::CodeObject_MatrixBarcode;
    case SECodeObject_CodeTextLine:
      return se::code::CodeObject_CodeTextLine;
    case SECodeObject_MRZ:
      return se::code::CodeObject_MRZ;
    case SECodeObject_BankCard:
      return se::code::CodeObject_BankCard;
    case SECodeObject_PaymentDetails:
      return se::code::CodeObject_PaymentDetails;
    case SECodeObject_Face:
      return se::code::CodeObject_Face;
    case SECodeObject_Container:
      return se::code::CodeObject_Container;
      break;
  }
}

SECodeObjectType ot_i2e(se::code::CodeObjectType ot) {
  switch(ot) {
    case se::code::CodeObject_LinearBarcode:
      return SECodeObject_LinearBarcode;
    case se::code::CodeObject_MatrixBarcode:
      return SECodeObject_MatrixBarcode;
    case se::code::CodeObject_CodeTextLine:
      return SECodeObject_CodeTextLine;
    case se::code::CodeObject_MRZ:
      return SECodeObject_MRZ;
    case se::code::CodeObject_BankCard:
      return SECodeObject_BankCard;
    case se::code::CodeObject_PaymentDetails:
      return SECodeObject_PaymentDetails;
    case se::code::CodeObject_Face:
      return SECodeObject_Face;
    case se::code::CodeObject_Container:
      return SECodeObject_Container;
      break;
  }
}

@implementation SECodeObjectRef {
  se::code::CodeObject* ptr;
  bool is_mutable;
}

- (instancetype) initFromInternalCodeObjectPointer:(se::code::CodeObject *)fieldptr
                                withMutabilityFlag:(BOOL)mutabilityFlag {
  if (self = [super init]) {
    ptr = fieldptr;
    is_mutable = (YES == mutabilityFlag);
  }
  return self;
}

- (se::code::CodeObject *) getInternalCodeObjectPointer {
  return ptr;
}

- (BOOL) isMutable {
  return is_mutable? YES : NO;
}

- (SECodeObject *) clone {
  return [[SECodeObject alloc] initFromInternalCodeObject:(*ptr)];
}

- (int) getID {
  return ptr->GetID();
}

- (SECodeObjectType) getType {
  return ot_i2e(ptr->GetType());
}

- (NSString *) getTypeStr {
  return [NSString stringWithUTF8String:ptr->GetTypeStr()];
}

- (NSString *) getName {
  return [NSString stringWithUTF8String:ptr->GetName()];
}

- (BOOL) isAccepted {
  return ptr->IsAccepted()? YES : NO;
}

- (BOOL) isValidated {
  return ptr->IsValidated()? YES : NO;
}

- (float) getConfidence {
  return ptr->GetConfidence();
}

- (void) setFirstDetectedFrameTo:(int)frame_number {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetFirstDetectedFrame(frame_number);
  }
}

- (void) setLastUpdatedFrameTo:(int)frame_number {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetLastUpdatedFrame(frame_number);
  }
}

- (int) getFirstDetectedFrame {
  return ptr->GetFirstDetectedFrame();
}

- (int) getLastUpdatedFrame {
  return ptr->GetLastUpdatedFrame();
}

- (BOOL) getIsTerminal {
  return ptr->GetIsTerminal()? YES : NO;
}

- (void) setIsTerminalTo:(BOOL)is_terminal {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetIsTerminal(YES == is_terminal);
  }
}

- (BOOL) hasQuadrangle {
  return ptr->HasQuadrangle()? YES : NO;
}

- (SECommonQuadrangle *) getQuadrangle {
  return [[SECommonQuadrangle alloc] 
      initFromInternalQuadrangle:ptr->GetQuadrangle()];
}

- (void) setQuadrangleTo:(SECommonQuadrangle *)quad {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetQuadrangle([quad getInternalQuadrangle]);
  }
}

- (BOOL) hasImage {
  return ptr->HasImage()? YES : NO;
}

- (SECommonImageRef *) getImage {
  return [[SECommonImageRef alloc] 
      initFromInternalImagePointer:const_cast<se::common::Image*>(&ptr->GetImage())
                withMutabilityFlag:NO];
}

- (void) setImageTo:(nonnull SECommonImageRef *)img {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetImage(*[img getInternalImagePointer]);
  }
}

- (void) removeImage {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->RemoveImage();
  }
}

- (int) getComponentsCount {
  return ptr->GetComponentsCount();
}

- (SECommonQuadrangle *) getComponentWithName:(NSString *)comp_name {
  try {
    return [[SECommonQuadrangle alloc]
        initFromInternalQuadrangle:ptr->GetComponent([comp_name UTF8String])];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) setComponentWithName:(nonnull NSString *)comp_name
                           to:(nonnull SECommonQuadrangle *)comp {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetComponent([comp_name UTF8String], [comp getInternalQuadrangle]);
  }
}                      

- (BOOL) hasComponentWithName:(NSString *)comp_name {
  return ptr->HasComponent([comp_name UTF8String])? YES : NO;
}

- (SECommonQuadranglesMapIterator *) componentsBegin {
  return [[SECommonQuadranglesMapIterator alloc]
      initFromInternalQuadranglesMapIterator:ptr->ComponentsBegin()];
}

- (SECommonQuadranglesMapIterator *) componentsEnd {
  return [[SECommonQuadranglesMapIterator alloc]
      initFromInternalQuadranglesMapIterator:ptr->ComponentsEnd()];
}

- (int) getFieldsCount {
  return ptr->GetFieldsCount();
}

- (SECodeFieldRef *) getFieldWithName:(NSString *)field_name {
  try {
    return [[SECodeFieldRef alloc]
        initFromInternalCodeFieldPointer:const_cast<se::code::CodeField*>(&ptr->GetField([field_name UTF8String]))
        withMutabilityFlag:NO];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) setFieldWithName:(NSString *)field_name
                       to:(SECodeFieldRef *)code_field {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetField([field_name UTF8String], *[code_field getInternalCodeFieldPointer]);
  }
}

- (BOOL) hasFieldWithName:(NSString *)field_name {
  return ptr->HasField([field_name UTF8String])? YES : NO;
}

- (void) removeFieldWithName:(nonnull NSString *)field_name {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->RemoveField([field_name UTF8String]);
  }
}

- (SECodeFieldsMapIterator *) fieldsBegin {
  return [[SECodeFieldsMapIterator alloc]
      initFromInternalCodeFieldsMapIterator:ptr->FieldsBegin()];
}

- (SECodeFieldsMapIterator *) fieldsEnd {
  return [[SECodeFieldsMapIterator alloc]
      initFromInternalCodeFieldsMapIterator:ptr->FieldsEnd()];
}

- (int) getAttributesCount {
  return ptr->GetAttributesCount();
}

- (NSString *) getAttributeWithName:(NSString *)attr_name {
  return [NSString stringWithUTF8String:ptr->GetAttribute([attr_name UTF8String])];
}

- (BOOL) hasAttributeWithName:(NSString *)attr_name {
  return ptr->HasAttribute([attr_name UTF8String])? YES : NO;
}

- (void) setAttributeWithName:(NSString *)attr_name
                           to:(NSString *)attr_value {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetAttribute([attr_name UTF8String], [attr_value UTF8String]);
  }
}

- (SECommonStringsMapIterator *) attributesBegin {
  return [[SECommonStringsMapIterator alloc]
      initFromInternalStringsMapIterator:ptr->AttributesBegin()];
}

- (SECommonStringsMapIterator *) attributesEnd {
  return [[SECommonStringsMapIterator alloc]
      initFromInternalStringsMapIterator:ptr->AttributesEnd()];
}

@end


@implementation SECodeObject {
  std::unique_ptr<se::code::CodeObject> internal;
}

- (instancetype) initFromInternalCodeObject:(const se::code::CodeObject &)obj {
  if (self = [super init]) {
    internal.reset(new se::code::CodeObject(obj));
  }
  return self;
}

- (const se::code::CodeObject &) getInternalCodeObject {
  return *internal;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(new se::code::CodeObject);
  }
  return self;
}

- (instancetype) initWithName:(NSString *)name
           withCodeObjectType:(SECodeObjectType)object_type
               withConfidence:(float)confidence
               withIsAccepted:(BOOL)is_accepted {
  if (self = [super init]) {
    try {
      internal.reset(new se::code::CodeObject(
          [name UTF8String],
          ot_e2i(object_type),
          is_accepted == true,
          confidence));
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
      return nil;
    }
  }
  return self;
}

- (SECodeObjectRef *) getRef {
  return [[SECodeObjectRef alloc] 
      initFromInternalCodeObjectPointer:internal.get()
                     withMutabilityFlag:NO];
}

- (SECodeObjectRef *) getMutableRef {
  return [[SECodeObjectRef alloc] 
      initFromInternalCodeObjectPointer:internal.get()
                     withMutabilityFlag:YES];
}

@end


@implementation SECodeObjectsMapIterator {
  std::unique_ptr<se::code::CodeObjectsMapIterator> internal;
}

- (instancetype) initFromInternalCodeObjectsMapIterator:(const se::code::CodeObjectsMapIterator &)iter {
  if (self = [super init]) {
    internal.reset(new se::code::CodeObjectsMapIterator(iter));
  }
  return self;
}

- (const se::code::CodeObjectsMapIterator &) getInternalCodeObjectsMapIterator {
  return *internal;
}

- (instancetype) initWithOther:(SECodeObjectsMapIterator *)other {
  if (self = [super init]) {
    internal.reset(new se::code::CodeObjectsMapIterator([other getInternalCodeObjectsMapIterator]));
  }
  return self;
}


- (BOOL) isEqualToIter:(SECodeObjectsMapIterator *)other {
  return internal->Equals([other getInternalCodeObjectsMapIterator])? YES : NO;
}

- (NSString *) getKey {
  return [NSString stringWithUTF8String:internal->GetKey()];
}

- (SECodeObjectRef *) getValue {
  return [[SECodeObjectRef alloc] 
      initFromInternalCodeObjectPointer:const_cast<se::code::CodeObject*>(&internal->GetValue())
                     withMutabilityFlag:NO];
}

- (void) advance {
  internal->Advance();
}

@end
