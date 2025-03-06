/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.rounded.Clear
import androidx.compose.material3.Card
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.smartengines.kotlin_sample.ui.theme.Kotlin_sampleTheme

@Composable
fun AppTitle(step:Int, title:String, onClose:(()->Unit)?){
    Row(
        Modifier
            .fillMaxWidth()
            .background(color = MaterialTheme.colorScheme.primaryContainer)
            .padding(horizontal = 5.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(
            Modifier
                .fillMaxWidth()
                .weight(1f),
        ) {
            // Step
            Text(
                text = "step #$step",
                style = MaterialTheme.typography.bodySmall
            )
            // Title
            Text(
                text = title,
                style = MaterialTheme.typography.headlineSmall,
                color = MaterialTheme.colorScheme.onPrimaryContainer,
            )
        }
        // Close button
        onClose?.let {
            OutlinedButton(onClick = it) {
                Icon(AppIcons.Clear, contentDescription = null)
            }
        }
    }
}

@Composable
fun TargetTitle(target:String){
    // Target
    Row (
        Modifier
            .fillMaxWidth()
            .background(color = MaterialTheme.colorScheme.primaryContainer)
            .padding(horizontal = 5.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = "target:",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onPrimaryContainer,
        )
        Text(
            modifier = Modifier.weight(1f),
            text = target,
            textAlign = TextAlign.Center,
            color = MaterialTheme.colorScheme.onPrimaryContainer,
        )
    }
}

@Composable
fun EngineIsStarting(){
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Card {
            Text(
                text = "The engine is starting...",
                modifier = Modifier.padding(20.dp)
            )
        }
    }
}

//--------------------------------------------------------------------------------------------------
// PREVIEW
@Preview(showBackground = true)
@Composable
private fun AppTitle_Preview() {
    Kotlin_sampleTheme {
        Column {
           AppTitle(
                step = 1,
                title = "The App Title",
                onClose = {}
            )
            TargetTitle(target = "the.target.name")
        }
    }
}
@Preview(showBackground = true)
@Composable
private fun Starting_Preview() {
    Kotlin_sampleTheme {
        EngineIsStarting()
    }
}
