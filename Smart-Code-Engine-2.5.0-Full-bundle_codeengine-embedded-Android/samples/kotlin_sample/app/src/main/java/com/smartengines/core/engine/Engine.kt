/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine

/**
 * Engine representation to use in ImageProcessor
 * The implementations should include signature as an internal parameter
 */
interface Engine {
    val isVideoModeAllowed:Boolean
    fun createEngine (bundle: ByteArray?) // null means embedded
    fun createSession(target: SessionTarget, sessionType: SessionType): Session
}