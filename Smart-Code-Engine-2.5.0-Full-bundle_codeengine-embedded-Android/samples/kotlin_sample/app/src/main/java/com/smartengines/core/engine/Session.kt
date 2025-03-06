/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine

import android.graphics.Bitmap
import kotlinx.coroutines.flow.Flow

/**
 * Common interface for session object
 * Using by ImageProcessor
 */
interface Session{
    fun processImage(bitmap: Bitmap)
    val isTerminal              : Boolean
    val isSelfieCheckRequired   : Boolean // just for vauth-session only!
    val isEnded                 : Boolean // just for vauth-session only!
    val quadsPrimary  : Flow<Set<Quad>>?
    val quadsSecondary: Flow<Set<Quad>>?
    val instruction   : Flow<String?>?
}
