/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine

/**
 * Engine bundle loading variants
 */
sealed interface EngineBundle {
    data class  File(val filePath:String) : EngineBundle // Load from known file
    data class  FirstFound(val dirToSearch:String, val fileExtension:String) : EngineBundle // Load from first file found in the directory
    data object Embedded : EngineBundle // Load from embedded bundle
}