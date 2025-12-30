/*
  Copyright (c) 2016-2025, Smart Engines Service LLC.
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_CODE_ENGINE_FEEDBACK_H_INCLUDED
#define OBJCCODEENGINE_CODE_ENGINE_FEEDBACK_H_INCLUDED

#import <Foundation/Foundation.h>

#import <objccodeengine/code_engine_result.h>

#import <objcsecommon/se_geometry.h>

@class SECodeEngineFeedbackContainer;

@interface SECodeEngineFeedbackContainerRef : NSObject 

- (BOOL) isMutable;

- (nonnull SECodeEngineFeedbackContainer *) clone;

- (int) getQuadranglesCount;
- (BOOL) hasQuadrangleWithName:(nonnull NSString *)name;
- (nonnull SECommonQuadrangle *) getQuadrangleWithName:(nonnull NSString *)name;
- (void) setQuadrangleWithName:(nonnull NSString *)name
                            to:(nonnull SECommonQuadrangle *)quad;
- (void) removeQuadrangleWithName:(nonnull NSString *)name;

- (nonnull SECommonQuadranglesMapIterator *) quadranglesBegin;
- (nonnull SECommonQuadranglesMapIterator *) quadranglesEnd;

@end


@interface SECodeEngineFeedbackContainer : NSObject

- (nonnull instancetype) init;

- (nonnull SECodeEngineFeedbackContainerRef *) getRef;
- (nonnull SECodeEngineFeedbackContainerRef *) getMutableRef;

@end


@protocol SECodeEngineVisualizationFeedback <NSObject>

@optional

- (void) feedbackReceived:(nonnull SECodeEngineFeedbackContainerRef *)feedback;

@end


@protocol SECodeEngineWorkflowFeedback <NSObject>

@optional

- (void) resultReceived:(nonnull SECodeEngineResultRef *)result;
- (void) sessionEnded;

@end

#endif // OBJCCODEENGINE_CODE_ENGINE_FEEDBACK_H_INCLUDED
