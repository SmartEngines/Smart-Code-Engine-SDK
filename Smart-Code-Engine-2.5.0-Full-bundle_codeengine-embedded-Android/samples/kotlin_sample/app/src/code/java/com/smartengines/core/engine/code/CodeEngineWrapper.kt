/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine.code

import com.smartengines.code.CodeEngine
import com.smartengines.core.engine.Engine
import com.smartengines.core.engine.Session
import com.smartengines.core.engine.SessionTarget
import com.smartengines.core.engine.SessionType

class CodeEngineWrapper(
    private val signature : String
): Engine {
    lateinit var codeEngine: CodeEngine
    override val isVideoModeAllowed = true

    override fun createEngine(bundle: ByteArray?) {
        // Create SDK engine
        codeEngine = if(bundle!=null) CodeEngine.Create(bundle, true)
                                else  CodeEngine.CreateFromEmbeddedBundle(true)
    }

    override fun createSession(target: SessionTarget, sessionType: SessionType): Session {
        val sessionSettings = codeEngine.GetDefaultSessionSettings()
        target.fillSessionSettings(sessionSettings)

        return CodeEngineSession(codeEngine, sessionSettings, signature)
    }
}
