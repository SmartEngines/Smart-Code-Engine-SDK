/*
  Copyright (c) 2016-2024, Smart Engines Service LLC.
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_CODE_ENGINE_RESULT_H_INCLUDED
#define OBJCCODEENGINE_CODE_ENGINE_RESULT_H_INCLUDED

#import <Foundation/Foundation.h>

#import <objccodeengine/code_object.h>

@class SECodeEngineResult;

@interface SECodeEngineResultRef : NSObject

- (BOOL) isMutable;

- (nonnull SECodeEngineResult *) clone;

- (int) getObjectCount;
- (BOOL) hasObjectWithName:(nonnull NSString *)object_name;
- (nonnull SECodeObjectRef *) getCodeObjectWithName:(nonnull NSString *)object_name;
- (void) setCodeObjectWithName:(nonnull NSString *)object_name
                            to:(nonnull SECodeObjectRef *)code_object;
- (nonnull SECodeObjectsMapIterator *) objectsBegin;
- (nonnull SECodeObjectsMapIterator *) objectsEnd;

- (BOOL) isTerminal;
- (void) setTerminal;

@end


@interface SECodeEngineResult : NSObject

- (nonnull instancetype) init;
- (nonnull instancetype) initWithIsTerminal:(BOOL)is_terminal;

- (nonnull SECodeEngineResultRef *) getRef;
- (nonnull SECodeEngineResultRef *) getMutableRef;

@end

#endif // OBJCCODEENGINE_CODE_ENGINE_RESULT_H_INCLUDED
