/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import android.graphics.Bitmap
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextAlign
import com.smartengines.core.engine.ImageProcessingState
import com.smartengines.core.engine.Visualization

@Composable
fun ProcessingScreenPhoto(
    photoProcessingState: ImageProcessingState.PHOTO_PROCESSING
){
    val (target, visualization: Visualization?, photo : Bitmap) = photoProcessingState

    Column(Modifier.fillMaxSize()){
        // Title
        Text("Photo mode", Modifier.fillMaxWidth(), textAlign = TextAlign.Center)

        // BODY
        Box(Modifier.weight(1f)){
            // PHOTO PREVIEW
            Image(
                bitmap =photo.asImageBitmap(),
                modifier = Modifier
                    .fillMaxSize(),
                contentDescription = "image",
                alignment = Alignment.Center,
                contentScale = ContentScale.Fit
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
    }
}
