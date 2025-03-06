/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.net.Uri
import android.util.Log
import androidx.camera.core.ImageProxy
import com.smartengines.core.engine.common.Utils

object ImageFactory {
    private const val TAG = "myapp.ImageFactory"

    fun bitmapFromFile(context: Context, uri: Uri):Bitmap{
        Log.d(TAG, "bitmapFromFile  uri: $uri")
        val bytes: ByteArray = Utils.loadFile(context, uri)
        return BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
    }

    // https://developer.android.com/media/camera/camerax/orientation-rotation
    // https://developer.android.com/reference/androidx/camera/core/ImageInfo#getSensorToBufferTransformMatrix()
    fun bitmapFromCameraImage(imageProxy: ImageProxy, isFrontCamera:Boolean):Bitmap{
        val sensorRotation = imageProxy.imageInfo.rotationDegrees.toFloat()

        // Make bitmap
        val bitmap: Bitmap = imageProxy.toBitmap()

        // Rotate matrix
        val matrix = Matrix()
//      matrix.postRotate(imageProxy.imageInfo.rotationDegrees.toFloat()) // The default behaviour: rotate image depending on the device orientation
        imageProxy.imageInfo.sensorToBufferTransformMatrix.invert(matrix) // restore sensor original image
        matrix.postRotate(sensorRotation) // rotate from sensor to natural (portrait) orientation
        if (isFrontCamera)
            matrix.postScale(1f, -1f) // Fix the front camera Mirror effect


        // Apply image size limit TODO apply
//        val maxSide = app.settings.imageSizeLimit
//        if(maxSide>0) {
//            val s = minOf(  maxSide.toFloat() / bitmap.width,
//                            maxSide.toFloat() / bitmap.height )
//            if (s < 1f) matrix.postScale(s, s)
//        }

        // Crop & Rotate
        val crop = imageProxy.cropRect
        return Bitmap.createBitmap(bitmap,
            crop.left,crop.top, crop.width(),crop.height(),
            matrix, false)
    }
}