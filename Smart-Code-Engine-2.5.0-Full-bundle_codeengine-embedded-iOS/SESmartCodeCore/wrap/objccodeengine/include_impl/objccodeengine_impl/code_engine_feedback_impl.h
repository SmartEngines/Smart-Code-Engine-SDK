/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_IMPL_CODE_ENGINE_FEEDBACK_H_INCLUDED
#define OBJCCODEENGINE_IMPL_CODE_ENGINE_FEEDBACK_H_INCLUDED

#import <objccodeengine/code_engine_feedback.h>

#include <codeengine/code_engine_feedback.h>

@interface SECodeEngineFeedbackContainerRef (Internal)

- (instancetype) initFromInternalFeedbackContainerPointer:(se::code::CodeEngineFeedbackContainer *)feedbackptr
                                       withMutabilityFlag:(BOOL)mutabilityFlag;
- (se::code::CodeEngineFeedbackContainer *) getInternalFeedbackContainerPointer;

@end


@interface SECodeEngineFeedbackContainer (Internal)

- (instancetype) initFromInternalFeedbackContainer:(const se::code::CodeEngineFeedbackContainer &)feedback;
- (const se::code::CodeEngineFeedbackContainer &) getInternalFeedbackContainer;

@end

#endif // OBJCCODEENGINE_IMPL_CODE_ENGINE_FEEDBACK_H_INCLUDED