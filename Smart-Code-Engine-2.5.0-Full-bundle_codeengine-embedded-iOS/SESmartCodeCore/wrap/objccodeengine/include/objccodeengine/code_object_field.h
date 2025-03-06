/*
  Copyright (c) 2016-2024, Smart Engines Service LLC.
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_CODE_OBJECT_FIELD_H_INCLUDED
#define OBJCCODEENGINE_CODE_OBJECT_FIELD_H_INCLUDED

#import <Foundation/Foundation.h>

#import <objcsecommon/se_common.h>

@class SECodeField;

@interface SECodeFieldRef : NSObject

- (BOOL) isMutable;

- (nonnull SECodeField *) clone;

- (nonnull NSString *) name;
- (void) setNameTo:(nonnull NSString *)name;

- (BOOL) isAccepted;
- (void) setisAcceptedTo:(BOOL)is_accepted;

- (double) getConfidence;
- (void) setConfidenceTo:(float)confidence;

- (BOOL) isTerminal;
- (void) setIsTerminalTo:(BOOL)is_terminal;

- (BOOL) hasBinaryRepresentation;
- (nonnull SECommonByteString *) getBinaryRepresentation;
- (void) setBinaryRepresentationTo:(nonnull SECommonByteString *)byte_string;

- (BOOL) hasOcrStringRepresentation;
- (nonnull SECommonOcrString *) getOcrString;
- (void) setOcrStringRepresentationTo:(nonnull SECommonOcrString *)ocr_string;

@end

@interface SECodeField : NSObject

- (nonnull instancetype) init;

- (nonnull instancetype) initFromByteString:(nonnull NSString *)name
                             withByteString:(nonnull SECommonByteString *)byte_string;

- (nonnull instancetype) initFromOcrString:(nonnull NSString *)name
                             withOcrString:(nonnull SECommonOcrString *)ocr_string;

- (nonnull SECodeFieldRef *) getRef;
- (nonnull SECodeFieldRef *) getMutableRef; 

@end

@interface SECodeFieldsMapIterator : NSObject

- (nonnull instancetype) initWithOther:(nonnull SECodeFieldsMapIterator *)other;
- (BOOL) isEqualToIter:(nonnull SECodeFieldsMapIterator *)other;

- (nonnull NSString *) getKey;
- (nonnull SECodeFieldRef *) getValue;
- (void) advance;

@end

#endif // OBJCCODEENGINE_CODE_OBJECT_FIELD_H_INCLUDED
