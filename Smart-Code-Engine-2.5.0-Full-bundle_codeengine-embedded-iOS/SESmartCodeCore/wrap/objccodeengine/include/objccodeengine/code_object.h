/*
  Copyright (c) 2016-2024, Smart Engines Service LLC.
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_CODE_OBJECT_H_INCLUDED
#define OBJCCODEENGINE_CODE_OBJECT_H_INCLUDED

#import <Foundation/Foundation.h>

#import <objccodeengine/code_object_field.h>

typedef enum { 
  SECodeObject_LinearBarcode,
  SECodeObject_MatrixBarcode,
  SECodeObject_CodeTextLine,
  SECodeObject_MRZ,
  SECodeObject_BankCard,
  SECodeObject_PaymentDetails,
  SECodeObject_Face,
  SECodeObject_Container
} SECodeObjectType;

@class SECodeObject;

@interface SECodeObjectRef : NSObject

- (BOOL) isMutable;

- (nonnull SECodeObject *) clone;

- (int) getID;
- (SECodeObjectType) getType;
- (nonnull NSString *) getTypeStr;
- (nonnull NSString *) getName;

- (BOOL) isAccepted;
- (BOOL) isValidated;
- (float) getConfidence;

- (void) setFirstDetectedFrameTo:(int)frame_number;
- (void) setLastUpdatedFrameTo:(int)frame_number;
- (int) getFirstDetectedFrame;
- (int) getLastUpdatedFrame;

- (BOOL) getIsTerminal;
- (void) setIsTerminalTo:(BOOL)is_terminal;

- (BOOL) hasQuadrangle;
- (nonnull SECommonQuadrangle *) getQuadrangle;
- (void) setQuadrangleTo:(nonnull SECommonQuadrangle *)quad;

- (BOOL) hasImage;
- (nonnull SECommonImageRef *) getImage;
- (void) setImageTo:(nonnull SECommonImageRef *)img;
- (void) removeImage;

- (int) getComponentsCount;
- (nonnull SECommonQuadrangle *) getComponentWithName:(nonnull NSString *)comp_name;
- (void) setComponentWithName:(nonnull NSString *)comp_name
                           to:(nonnull SECommonQuadrangle *)comp;
- (BOOL) hasComponentWithName:(nonnull NSString *)comp_name;
- (nonnull SECommonQuadranglesMapIterator *) componentsBegin;
- (nonnull SECommonQuadranglesMapIterator *) componentsEnd;

- (int) getFieldsCount;
- (nonnull SECodeFieldRef *) getFieldWithName:(nonnull NSString *)field_name;
- (void) setFieldWithName:(nonnull NSString *)field_name
                       to:(nonnull SECodeFieldRef *)code_field;
- (BOOL) hasFieldWithName:(nonnull NSString *)field_name;
- (void) removeFieldWithName:(nonnull NSString *)field_name;
- (nonnull SECodeFieldsMapIterator *) fieldsBegin;
- (nonnull SECodeFieldsMapIterator *) fieldsEnd;

- (int) getAttributesCount;
- (nonnull NSString *) getAttributeWithName:(nonnull NSString *)attr_name;
- (BOOL) hasAttributeWithName:(nonnull NSString *)attr_name;
- (void) setAttributeWithName:(nonnull NSString *)attr_name
                           to:(nonnull NSString *)attr_value;
- (nonnull SECommonStringsMapIterator *) attributesBegin;
- (nonnull SECommonStringsMapIterator *) attributesEnd;

@end


@interface SECodeObject : NSObject

- (nonnull instancetype) init;
- (nonnull instancetype) initWithName:(nonnull NSString *)name
                   withCodeObjectType:(SECodeObjectType)object_type
                       withConfidence:(float)confidence
                       withIsAccepted:(BOOL)is_accepted;

- (nonnull SECodeObjectRef *) getRef;
- (nonnull SECodeObjectRef *) getMutableRef;          

@end


@interface SECodeObjectsMapIterator : NSObject

- (nonnull instancetype) initWithOther:(nonnull SECodeObjectsMapIterator *)other;
- (BOOL) isEqualToIter:(nonnull SECodeObjectsMapIterator *)other;

- (nonnull NSString *) getKey;
- (nonnull SECodeObjectRef *) getValue;
- (void) advance;

@end

#endif // OBJCCODEENGINE_CODE_OBJECT_H_INCLUDED
