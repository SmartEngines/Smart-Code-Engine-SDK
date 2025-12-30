package com.smartengines;

import com.smartengines.code.CodeEngineResult;
import com.smartengines.code.CodeEngineWorkflowFeedback;

public class CodeWorkflowFeedBack extends CodeEngineWorkflowFeedback {
    VisualizationCallback visualizationCallback;
    public CodeWorkflowFeedBack(VisualizationCallback visualizationCallback_) {
        visualizationCallback = visualizationCallback_;
    }


    public void ResultReceived(CodeEngineResult result) {
        System.out.println("[Feedback called]: Result received, Obj count: " + result.GetObjectCount());
        visualizationCallback.frameUpdated();
    }

    public void SessionEnded() {
        System.out.println("[Optional callback called]: Session ended");
    }
}
