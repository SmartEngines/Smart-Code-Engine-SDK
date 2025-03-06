/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.smartengines.core.engine.EngineLoadingState
import com.smartengines.kotlin_sample.ui.theme.Kotlin_sampleTheme
import com.smartengines.nfc.onNewIntent
import com.smartengines.nfc.onResumeActivity

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            Kotlin_sampleTheme {
                Scaffold( modifier = Modifier.fillMaxSize() ) {innerPadding->
                    Surface(Modifier.padding(innerPadding)) {

                        val engineLoadingState by Model.engineLoader.loadingState.collectAsState()
                        var loadingStepFinished by rememberSaveable {mutableStateOf(false)}
                        if(!(engineLoadingState is EngineLoadingState.Loaded && loadingStepFinished)) {

                            // STEP 1: Engine Loading
                            LoadingScreen(
                                loadingState = engineLoadingState,
                                onFinish = { loadingStepFinished = true })

                        }else{
                            val selectedTarget by Model.targetList.selectedTarget.collectAsState()
                            if(selectedTarget==null){
                                // STEP 2: Target selecting
                                val targets by Model.targetList.targets.collectAsState()
                                TargetsScreen(
                                    targets  = targets,
                                    onFinish = {Model.targetList.selectedTarget.value = it},
                                    onBack   = {loadingStepFinished=false}
                                )
                            }else{
                                // STEP 3: Image processing
                                ProcessingScreen(
                                    // Data
                                    engine = Model.engine,
                                    target = selectedTarget!!
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        Model.passportReader.onResumeActivity(this)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Model.passportReader.onNewIntent(intent)?.let {
            Model.onPassportTagDetected(it, this)
        }
    }



}

