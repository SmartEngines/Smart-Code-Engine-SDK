/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine

import kotlinx.coroutines.flow.Flow

/**
 * Data source of some session parameters used for the recognition process visualization
 */
data class Visualization(
    val quadsPrimary  : Flow<List<QuadFrame>>?,
    val quadsSecondary: Flow<List<QuadFrame>>?,
    val instruction   : Flow<String?>?
)