/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCCODEENGINE_IMPL_CODE_ENGINE_PROXY_H_INCLUDED
#define OBJCCODEENGINE_IMPL_CODE_ENGINE_PROXY_H_INCLUDED

#import <objccodeengine_impl/code_engine_feedback_impl.h>
#import <objccodeengine_impl/code_engine_result_impl.h>

#include <codeengine/code_engine_feedback.h>

class ProxyWorkflowReporter : public se::code::CodeEngineWorkflowFeedback {
public:
  ProxyWorkflowReporter(id<SECodeEngineWorkflowFeedback> workflow_feedback_reporter);

  void setReporter(id<SECodeEngineWorkflowFeedback> workflow_feedback_reporter);

  virtual void ResultReceived(const se::code::CodeEngineResult& result) override final;

  virtual void SessionEnded() override final;

private:
  void recalculateCache();

  id<SECodeEngineWorkflowFeedback> workflowFeedbackReporter_; // should be weak, no refcounts

  bool responds_to_results = false;
  bool responds_to_session_ended = false;
};

class ProxyVisualizationReporter : public se::code::CodeEngineVisualizationFeedback {
public:
  ProxyVisualizationReporter(id<SECodeEngineVisualizationFeedback> visualization_feedback_reporter);

  void setReporter(id<SECodeEngineVisualizationFeedback> visualization_feedback_reporter);

  virtual void FeedbackReceived(
      const se::code::CodeEngineFeedbackContainer& feedback_container) override final;

private:
  void recalculateCache();

  id<SECodeEngineVisualizationFeedback> visualizationFeedbackReporter_; // should be weak, no refcounts

  bool responds_to_feedback_received = false;
};

#endif // OBJCCODEENGINE_IMPL_CODE_ENGINE_PROXY_H_INCLUDED
