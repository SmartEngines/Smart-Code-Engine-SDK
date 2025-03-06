/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample.targets

import com.smartengines.core.engine.SessionTarget
import kotlinx.coroutines.flow.MutableStateFlow

class TargetList {
    val targets         = MutableStateFlow<List<AppTarget>>(emptyList())
    val selectedTarget  = MutableStateFlow<AppTarget?>(null)
}