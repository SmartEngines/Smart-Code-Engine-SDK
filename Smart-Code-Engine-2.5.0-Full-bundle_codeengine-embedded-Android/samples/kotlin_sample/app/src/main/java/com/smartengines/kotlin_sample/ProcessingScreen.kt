/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.smartengines.core.engine.Engine
import com.smartengines.core.engine.ImageProcessingState
import com.smartengines.core.engine.ImageProcessingState.*
import com.smartengines.kotlin_sample.targets.AppTarget
import com.smartengines.kotlin_sample.ui.theme.Kotlin_sampleTheme

@Composable
fun ProcessingScreen(
    // Data
    engine: Engine,
    target: AppTarget,
) {
    val imageProcessingState by Model.imageProcessor.state.collectAsState()
    fun onFinish(){
        if(imageProcessingState is READY)
            Model.targetList.selectedTarget.value = null
        else
            Model.imageProcessor.finish()
    }

    BackHandler {
        onFinish()
    }

    Column(Modifier.fillMaxSize()) {
        AppTitle(step = 3, title = "Image Processing", onClose = ::onFinish)
        TargetTitle(target = target.name)
        // Body
        Box(modifier = Modifier
            .fillMaxWidth()
            .weight(1f), contentAlignment = Alignment.Center
        ) {
            when (val state = imageProcessingState) {
                is READY -> ProcessingScreenReady( engine, target, Model.imageProcessor::startProcessing )
                is VIDEO_PROCESSING -> ProcessingScreenVideo(state, Model.imageProcessor::addFrame, Model.imageProcessor::stopProcessing)
                is PHOTO_PROCESSING -> ProcessingScreenPhoto(state)
                is SELFIE_CHECKING -> {}
                is FINISHED -> ProcessingResultScreen(state)
                is ERROR -> ProcessingScreenError(state)
            }
        }
    }
}

//--------------------------------------------------------------------------------------------------
// PREVIEW
@Preview(showBackground = true)
@Composable
private fun ProcessingScreenReady_Preview() {
    Kotlin_sampleTheme {
        ProcessingScreen(
            MockEngine(isVideoModeAllowed = true),
            MockTarget()
        )
    }
}
@Preview(showBackground = true)
@Composable
private fun ProcessingScreenError_Preview() {
    Kotlin_sampleTheme {
        ProcessingScreen(
            MockEngine(isVideoModeAllowed = true),
            MockTarget()
        )
    }
}
