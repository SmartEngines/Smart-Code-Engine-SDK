/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <objccodeengine_impl/code_engine_proxy_impl.h>

ProxyWorkflowReporter::ProxyWorkflowReporter(id<SECodeEngineWorkflowFeedback> workflow_feedback_reporter) {
  workflowFeedbackReporter_ = workflow_feedback_reporter;
  recalculateCache();
}

void ProxyWorkflowReporter::setReporter(id<SECodeEngineWorkflowFeedback> workflow_feedback_reporter) {
  workflowFeedbackReporter_ = workflow_feedback_reporter;
  recalculateCache();
}

void ProxyWorkflowReporter::recalculateCache() {
  responds_to_results = 
      [workflowFeedbackReporter_ respondsToSelector:@selector(resultReceived:)];
  responds_to_session_ended = 
      [workflowFeedbackReporter_ respondsToSelector:@selector(sessionEnded)];
}

void ProxyWorkflowReporter::ResultReceived(const se::code::CodeEngineResult& result) {
  if (workflowFeedbackReporter_ && responds_to_results) {
    [workflowFeedbackReporter_ resultReceived:[[SECodeEngineResultRef alloc]
        initFromInternalResultPointer:const_cast<se::code::CodeEngineResult*>(&result)
                   withMutabilityFlag:NO]];
  }
}

void ProxyWorkflowReporter::SessionEnded() {
  if (workflowFeedbackReporter_ && responds_to_session_ended) {
    [workflowFeedbackReporter_ sessionEnded];
  }
}


ProxyVisualizationReporter::ProxyVisualizationReporter(id<SECodeEngineVisualizationFeedback> visualization_feedback_reporter) {
  visualizationFeedbackReporter_ = visualization_feedback_reporter;
  recalculateCache();
}

void ProxyVisualizationReporter::setReporter(id<SECodeEngineVisualizationFeedback> visualization_feedback_reporter) {
  visualizationFeedbackReporter_ = visualization_feedback_reporter;
  recalculateCache();
}

void ProxyVisualizationReporter::recalculateCache() {
  responds_to_feedback_received = 
      [visualizationFeedbackReporter_ respondsToSelector:@selector(feedbackReceived:)];
}

void ProxyVisualizationReporter::FeedbackReceived(
    const se::code::CodeEngineFeedbackContainer& feedback_container) {
  if (visualizationFeedbackReporter_ && responds_to_feedback_received) {
    [visualizationFeedbackReporter_ feedbackReceived:[[SECodeEngineFeedbackContainerRef alloc] 
        initFromInternalFeedbackContainerPointer:const_cast<se::code::CodeEngineFeedbackContainer*>(&feedback_container)
                              withMutabilityFlag:NO]];
  }
}