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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.smartengines.core.engine.ImageProcessingState

@Composable
fun ProcessingResultScreen(
    // Data
    state : ImageProcessingState.FINISHED,
    // Events
){
    val (session) = state

    Column(Modifier.fillMaxSize()) {
        Box(modifier = Modifier
            .fillMaxWidth()
            .weight(1f), contentAlignment = Alignment.Center
        ) {
            // Engine-dependent screen
            AppFactory.ResultScreen(session)
        }
    }
}