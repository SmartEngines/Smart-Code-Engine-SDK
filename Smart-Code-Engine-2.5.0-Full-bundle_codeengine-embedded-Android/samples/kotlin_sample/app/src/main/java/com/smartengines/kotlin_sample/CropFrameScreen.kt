/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.smartengines.kotlin_sample.targets.calculateTargetCropRectangle

@Composable
fun CropFrameScreen() {
    val lineWidth = 3.dp
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center){
        Canvas(modifier = Modifier.fillMaxSize()) {
            val cropRect = calculateTargetCropRectangle(size)
            drawRoundRect(
                topLeft = cropRect.topLeft,
                size = cropRect.size,
                color = Color.Red,
                style = Stroke(lineWidth.toPx()),
                cornerRadius = CornerRadius(50f, 50f),
            )
        }
    }

}

//--------------------------------------------------------------------------------------------------
// PREVIEW
@Preview(showBackground = false, showSystemUi = false)
@Composable
private fun CropFrameScreen_Preview() {
    CropFrameScreen()
}