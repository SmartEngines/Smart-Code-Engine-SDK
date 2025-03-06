/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine

import android.util.Size

data class QuadFrame (
    val quads       : Set<Quad>,
    val imageSize   : Size,
    val timestamp   : Long = System.currentTimeMillis()
)