/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample.targets

import android.graphics.Bitmap
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import kotlin.math.roundToInt

fun calculateTargetCropRectangle(screen: Size): Rect {
    val wScr = screen.width
    val hScr = screen.height
    val width = 0.9f * wScr
    val height = width / 2
    val left = (wScr - width) / 2
    val top = (hScr - height) / 2
    val frame = Rect(left, top, left + width, top + height)
    return frame
}

fun Bitmap.applyTargetCrop(): Bitmap {
    val rect = calculateTargetCropRectangle(Size(width.toFloat(), height.toFloat()))
    return Bitmap.createBitmap(this,
        rect.left.roundToInt(), rect.top.roundToInt(), rect.width.roundToInt(), rect.height.roundToInt()
    )
}