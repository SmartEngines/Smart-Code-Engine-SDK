package com.smartengines;

import com.smartengines.code.CodeEngineFeedbackContainer;

public interface VisualizationCallback {
    void visualizationReceived(CodeEngineFeedbackContainer feedback_container);
    void frameUpdated();
}
