/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine

data class QuadPoint(
    val x : Float,
    val y : Float
){
    override fun toString(): String {
        return "${x.toInt()} ${y.toInt()}"
    }
}
