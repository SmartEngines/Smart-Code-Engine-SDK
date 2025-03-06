/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine.code

// SDK library
import com.smartengines.code.CodeEngineFeedbackContainer
import com.smartengines.code.CodeEngineVisualizationFeedback

import android.util.Log
import com.smartengines.core.engine.Quad
import com.smartengines.core.engine.common.toQuad
import kotlinx.coroutines.flow.MutableStateFlow

private const val TAG = "myapp.CodeCallback"

class CodeCallback : CodeEngineVisualizationFeedback() {

    val quadsPrimary   = MutableStateFlow<Set<Quad>>(emptySet())
    val quadsRoi       = MutableStateFlow<Set<Quad>>(emptySet())

    override fun FeedbackReceived(feedbackContainer: CodeEngineFeedbackContainer) {
        Log.d(TAG, "===> FeedbackReceived")
        // EXTRACT QUADS
        val quads   : MutableSet<Quad> = HashSet()
        val roi     : MutableSet<Quad> = HashSet()
        try {
            val iterator = feedbackContainer.QuadranglesBegin()
            while (!iterator.Equals(feedbackContainer.QuadranglesEnd())) {
                // Check key
                val key = iterator.GetKey()
                // Extract value
                if (key.startsWith("roi"))
                    roi.add(iterator.GetValue().toQuad())
                else
                    quads   .add(iterator.GetValue().toQuad())
                // Next
                iterator.Advance()
            }
        } catch (e: Exception) {
            Log.e(TAG, "quads calculation error " + e.message)
            e.printStackTrace()
        }

        // Call back (in the same thread)
        quadsPrimary.value   = quads
        quadsRoi.value       = roi
    }
}