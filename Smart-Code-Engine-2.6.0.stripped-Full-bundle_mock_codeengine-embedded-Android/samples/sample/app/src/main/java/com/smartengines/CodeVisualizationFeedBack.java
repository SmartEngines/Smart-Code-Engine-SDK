package com.smartengines;

import com.smartengines.code.CodeEngineFeedbackContainer;
import com.smartengines.code.CodeEngineVisualizationFeedback;

public class CodeVisualizationFeedBack extends CodeEngineVisualizationFeedback {
    VisualizationCallback visualizationCallback;

    public CodeVisualizationFeedBack(VisualizationCallback visualizationCallback_) {
        visualizationCallback = visualizationCallback_;
    }

    public void FeedbackReceived(CodeEngineFeedbackContainer feedback_container) {
        System.out.println("[Feedback called]: Feedback received\n");
        visualizationCallback.visualizationReceived(feedback_container);
    }

}
