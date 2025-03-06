/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.smartengines.core.engine.EngineLoadingState
import com.smartengines.kotlin_sample.ui.theme.Kotlin_sampleTheme

@Composable
fun LoadingScreen(loadingState: EngineLoadingState, onFinish:()->Unit) {
    AppTitle(step = 1, title = "Engine Loading", onClose = null)
    when(loadingState){
        EngineLoadingState.Unloaded  -> {  }

        EngineLoadingState.Loading   -> { LoadingStateScreen() }

        is EngineLoadingState.Loaded -> { LoadedStateScreen(
            loadingTime = loadingState.loadingTime,
            onFinish = onFinish) }

        is EngineLoadingState.Error  -> { ProcessingScreenError(
            error = loadingState.error)}
    }
}

@Composable
private fun LoadingStateScreen(){
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Card( Modifier.padding(20.dp) ) {
            Text(text = "The engine is loading...", Modifier.padding(20.dp))
        }
    }
}

@Composable
private fun ProcessingScreenError(error: Throwable){
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Card( Modifier.padding(10.dp) ) {
            Text(text = "Engine load error:\n$error",
                Modifier.padding(10.dp),
                color = Color.Red)
        }
    }
}

@Composable
private fun LoadedStateScreen(loadingTime:Long, onFinish:()->Unit){
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Card( Modifier.padding(10.dp) ) {
            Column(
                Modifier
                    .fillMaxWidth()
                    .padding(10.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                Text(text = "The engine is loaded")
                Spacer(modifier = Modifier.height(20.dp))
                Text(text = "Loading time $loadingTime ms")
                Spacer(modifier = Modifier.height(20.dp))
                OutlinedButton(onClick = onFinish) {
                    Text(text = "Continue")
                }

            }
        }
    }
}


//--------------------------------------------------------------------------------------------------
@Preview(showBackground = true)
@Composable
private fun Loading_Preview() {
    Kotlin_sampleTheme {
        LoadingStateScreen()
    }
}
@Preview(showBackground = true)
@Composable
private fun Error_Preview() {
    Kotlin_sampleTheme {
        ProcessingScreenError(Throwable("Loading error message"))
    }
}
@Preview(showBackground = true)
@Composable
private fun Loaded_Preview() {
    Kotlin_sampleTheme {
        LoadedStateScreen(1313, {})
    }
}