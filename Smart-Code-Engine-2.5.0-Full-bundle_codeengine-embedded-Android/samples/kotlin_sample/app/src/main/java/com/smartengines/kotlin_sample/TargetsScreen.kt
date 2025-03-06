/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.smartengines.core.engine.Engine
import com.smartengines.core.engine.SessionTarget
import com.smartengines.kotlin_sample.targets.AppTarget
import com.smartengines.kotlin_sample.ui.theme.Kotlin_sampleTheme

@Composable
fun TargetsScreen(
    targets : List<AppTarget>,
    onFinish:(AppTarget)->Unit,
    onBack:()->Unit
) {
    BackHandler { onBack() }

    Column(Modifier.fillMaxSize()) {
        AppTitle(step = 2, title = "Target Selecting", onClose = onBack)
        LazyColumn(modifier = Modifier
            .fillMaxWidth()
            .weight(1f)) {
            this.items(targets.size) { index ->
                val target = targets[index]
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(2.dp)
                        .clickable { onFinish(target) }
                ) {
                    Column(modifier = Modifier.padding(vertical = 4.dp, horizontal = 5.dp)) {
                        Text(text = target.name, fontWeight = FontWeight.Bold)
                        target.description?.let {
                            Text(text = it, style = MaterialTheme.typography.bodySmall)
                        }
                    }
                }
            }
        }
    }
}
//--------------------------------------------------------------------------------------------------
@Preview(showBackground = true)
@Composable
private fun Loading_Preview() {
    Kotlin_sampleTheme(darkTheme = true) {
        TargetsScreen(targets = listOf(
            MockTarget("target 1", "descr 1"),
            MockTarget("target 2", "descr 2"),
            MockTarget("target 3", "descr 3"),
            MockTarget("target 4", null),
            MockTarget("target 5", null),
        ), onFinish = {}, onBack = {})
    }
}
