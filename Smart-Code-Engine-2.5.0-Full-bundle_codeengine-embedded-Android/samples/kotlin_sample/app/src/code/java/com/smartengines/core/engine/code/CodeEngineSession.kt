/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine.code

import android.graphics.Bitmap
import android.util.Log
import com.smartengines.core.engine.Session
import com.smartengines.common.Image
import com.smartengines.code.CodeEngine
import com.smartengines.code.CodeEngineSessionSettings
import com.smartengines.core.engine.common.Utils

private const val TAG = "myapp.CodeEngineSession"

class CodeEngineSession(
    codeEngine  : CodeEngine,
    sessionSettings : CodeEngineSessionSettings,
    signature   : String
) : Session {

    val codeSession : com.smartengines.code.CodeEngineSession

    private val callback = CodeCallback() // can't be a local variable (to avoid clearing by gabbage collector)

    override var isEnded        = false
    override var isTerminal: Boolean = false
    override val isSelfieCheckRequired: Boolean = false
    override val quadsPrimary   = callback.quadsPrimary
    override val quadsSecondary = callback.quadsRoi
    override val instruction    = null

    init {

        // Create session
        codeSession = codeEngine.SpawnSession(
            sessionSettings,
            signature,
            null,//CodeEngineWorkflowFeedback
            callback
        )
        Log.d(TAG,"Session created")
    }

    override fun processImage(bitmap:Bitmap) {
        val image: Image = Utils.imageFromBitmap(bitmap)
        val result = codeSession.Process(image)
        isTerminal = result.IsTerminal()
    }


}