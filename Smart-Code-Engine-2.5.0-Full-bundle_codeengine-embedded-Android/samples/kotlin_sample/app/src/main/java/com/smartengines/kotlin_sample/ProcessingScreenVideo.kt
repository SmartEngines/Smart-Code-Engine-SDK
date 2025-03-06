/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import com.smartengines.core.engine.Frame
import com.smartengines.core.engine.ImageProcessingState
import com.smartengines.kotlin_sample.targets.AppTarget

@Composable
fun ProcessingScreenVideo(
    videoProcessingState: ImageProcessingState.VIDEO_PROCESSING,
    addFrame : (Frame)->Unit,
    stopProcessing : ()->Unit
){
    val (target, visualization) = videoProcessingState

    Column(Modifier.fillMaxSize()){
        // Title
        Text("Video mode", Modifier.fillMaxWidth(), textAlign = TextAlign.Center)

        // Body
        Box(Modifier.weight(1f)){
            // CAMERA
            CameraScreen(
                onVideoFrame = addFrame,
                onPhotoTaken = null,
                cropImage = (target as AppTarget).cropImage
            )

            // VISUALIZATION or STARTING
            visualization?.let {
                // Engine is processing
                VisualizationScreen(visualization = it)
            }?:run{
                // Engine is starting (creating the session)
                EngineIsStarting()
            }
        }

        // Bottom toolbar
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceAround) {
            OutlinedButton(
                onClick = stopProcessing,
                enabled = visualization!=null
            ) {
                Text("stop processing & show achieved result")
            }
        }
    }
}
