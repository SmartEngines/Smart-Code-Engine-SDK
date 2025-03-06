/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import android.app.Application
import android.util.Log
import com.smartengines.core.engine.EngineLoader
import com.smartengines.core.engine.ImageProcessor
import androidx.compose.material.icons.Icons
import com.smartengines.core.engine.EngineLoadingState
import com.smartengines.kotlin_sample.targets.TargetList
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

private const val TAG = "myapp.App"

// APP ICONS
val AppIcons = Icons.Rounded

class App : Application() {

    @OptIn(DelicateCoroutinesApi::class)
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "onCreate")

        Model.init(this)
    }
}