/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.smartengines.core.engine.ImageProcessingState

@Composable
fun ProcessingScreenError(state: ImageProcessingState.ERROR){
    val (error: Exception) = state
    Card( Modifier.padding(10.dp) ) {
        Text(text = "Error:\n$error",
            Modifier.padding(10.dp),
            color = Color.Red)
    }
}


