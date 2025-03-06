/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine

import android.graphics.Bitmap
import androidx.camera.core.ImageProxy

data class Frame(
    val bitmap    : Bitmap, // the image source
    val imageProxy: ImageProxy? // to close after process
){
    fun close(){
        imageProxy?.close()
    }
}
