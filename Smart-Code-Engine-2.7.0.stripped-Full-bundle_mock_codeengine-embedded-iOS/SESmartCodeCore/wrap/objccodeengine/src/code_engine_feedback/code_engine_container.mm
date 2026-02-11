/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objccodeengine_impl/code_engine_feedback_impl.h>

#import <objcsecommon_impl/se_geometry_impl.h>
#import <objcsecommon_impl/se_common_proxy_impl.h>

#include <codeengine/code_engine_feedback.h>

#include <memory>

@implementation SECodeEngineFeedbackContainerRef {
  se::code::CodeEngineFeedbackContainer* ptr;
  bool is_mutable;
}

- (instancetype) initFromInternalFeedbackContainerPointer:(se::code::CodeEngineFeedbackContainer *)feedbackptr
                                       withMutabilityFlag:(BOOL)mutabilityFlag {
  if (self = [super init]) {
    ptr = feedbackptr;
    is_mutable = (YES == mutabilityFlag);
  }
  return self;
}

- (se::code::CodeEngineFeedbackContainer *) getInternalFeedbackContainerPointer {
  return ptr;
}

- (BOOL) isMutable {
  return is_mutable? YES : NO;
}

- (nonnull SECodeEngineFeedbackContainer *) clone {
  return [[SECodeEngineFeedbackContainer alloc] initFromInternalFeedbackContainer:(*ptr)];
}

- (int) getQuadranglesCount {
  return ptr->GetQuadranglesCount();
}

- (BOOL) hasQuadrangleWithName:(NSString *)name {
  return ptr->HasQuadrangle([name UTF8String])? YES : NO;
}

- (SECommonQuadrangle *) getQuadrangleWithName:(NSString *)name {
  try {
    return [[SECommonQuadrangle alloc]
        initFromInternalQuadrangle:ptr->GetQuadrangle([name UTF8String])];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) setQuadrangleWithName:(NSString *)name
                            to:(SECommonQuadrangle *)quad {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->SetQuadrangle([name UTF8String], [quad getInternalQuadrangle]);
  }
}

- (void) removeQuadrangleWithName:(NSString *)name {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    try {
      ptr->RemoveQuadrangle([name UTF8String]);
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
    }
  }
}

- (SECommonQuadranglesMapIterator *) quadranglesBegin {
  return [[SECommonQuadranglesMapIterator alloc]
      initFromInternalQuadranglesMapIterator:ptr->QuadranglesBegin()];
}

- (SECommonQuadranglesMapIterator *) quadranglesEnd {
  return [[SECommonQuadranglesMapIterator alloc]
      initFromInternalQuadranglesMapIterator:ptr->QuadranglesEnd()];
}

@end

@implementation SECodeEngineFeedbackContainer {
  std::unique_ptr<se::code::CodeEngineFeedbackContainer> internal;
}

- (instancetype) initFromInternalFeedbackContainer:(const se::code::CodeEngineFeedbackContainer &)feedback {
  if (self = [super init]) {
    internal.reset(new se::code::CodeEngineFeedbackContainer(feedback));
  }
  return self;
}

- (const se::code::CodeEngineFeedbackContainer &) getInternalFeedbackContainer {
  return *internal;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(new se::code::CodeEngineFeedbackContainer);
  }
  return self; 
}

- (SECodeEngineFeedbackContainerRef *) getRef {
  return [[SECodeEngineFeedbackContainerRef alloc] 
      initFromInternalFeedbackContainerPointer:internal.get()
                            withMutabilityFlag:NO];
}

- (SECodeEngineFeedbackContainerRef *) getMutableRef {
  return [[SECodeEngineFeedbackContainerRef alloc] 
      initFromInternalFeedbackContainerPointer:internal.get()
                            withMutabilityFlag:YES];
}

@end
