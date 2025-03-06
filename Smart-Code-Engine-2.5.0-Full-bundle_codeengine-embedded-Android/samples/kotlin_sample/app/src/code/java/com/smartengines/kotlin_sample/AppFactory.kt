/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import androidx.compose.runtime.Composable
import com.smartengines.core.engine.Engine
import com.smartengines.core.engine.EngineBundle
import com.smartengines.core.engine.Session
import com.smartengines.core.engine.code.CodeEngineWrapper
import com.smartengines.kotlin_sample.targets.AppTarget
import com.smartengines.kotlin_sample.targets.CodeTargetList

object AppFactory {
    val jniLibrary = "jnicodeengine"
    val bundle      = EngineBundle.Embedded

    fun createEngineWrapper(signature:String) : Engine = CodeEngineWrapper(signature)

    val loadTargetList : (engine: Engine)->List<AppTarget> = CodeTargetList::load

    val ResultScreen : @Composable (Session)->Unit = { CodeResultScreen(session = it)}
}