/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine

/**
 * EngineLoader state machine
 * The main steps of engine loading process
 */
sealed interface EngineLoadingState {
    data object Unloaded                    : EngineLoadingState
    data object Loading                     : EngineLoadingState
    data class  Loaded(
        val engine: Engine,
        val loadingTime:Long
    ): EngineLoadingState
    data class  Error(val error:Throwable)  : EngineLoadingState
}