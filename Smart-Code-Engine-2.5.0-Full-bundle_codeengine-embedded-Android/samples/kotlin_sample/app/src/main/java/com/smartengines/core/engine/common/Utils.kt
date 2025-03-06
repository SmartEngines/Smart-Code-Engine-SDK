/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine.common

// Common SDK library
import com.smartengines.common.Image
import com.smartengines.common.ImagePixelFormat
import com.smartengines.common.Quadrangle

import android.content.Context
import android.content.res.AssetManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Base64
import com.smartengines.core.engine.Quad
import com.smartengines.core.engine.QuadPoint
import java.io.InputStream
import java.nio.ByteBuffer

object Utils {
    fun readFromStream(inputStream: InputStream): ByteArray {
        val size = inputStream.available()
        val bytes = ByteArray(size)
        val result = inputStream.read(bytes)
        inputStream.close()
        if (result != size) throw Exception("stream reading error")
        return bytes
    }
    fun loadFile(context: Context, uri: Uri): ByteArray {
        context.contentResolver.openInputStream(uri)?.let {
            val bytes = readFromStream(it)
            it.close()
            return bytes
        }
        throw Exception("Can't open $uri")
    }
    fun loadBitmapFromAssetFile(context: Context, filePath: String): Bitmap{
        val stream: InputStream = context.assets.open(
            filePath,
            AssetManager.ACCESS_STREAMING
        )
        val buffer = readFromStream(stream)
        val bitmap = BitmapFactory.decodeByteArray(buffer, 0, buffer.size)
        return bitmap
    }

    fun imageFromBitmap(bitmap: Bitmap): Image {
        // Bitmap to byte array
        val byteBuffer = ByteBuffer.allocate(bitmap.byteCount)

        //ByteBuffer byteBuffer = ImageUtil.createDirectByteBuffer(bitmap); doesn't work here!!!
        bitmap.copyPixelsToBuffer(byteBuffer)
        byteBuffer.rewind()
        val bytes = byteBuffer.array()

        val stride = bitmap.rowBytes
        val height = bitmap.height
        val width = bitmap.width

        // Bitmap.getConfig() return ARGB_8888 pixel format. The channel order of ARGB_8888 is RGBA!
        return Image.FromBufferExtended(
            bytes,
            width,
            height,
            stride,
            ImagePixelFormat.IPF_RGBA,
            1
        )
    }
}

fun imageToBitmap(image:Image): Bitmap {
    val base64String = image.GetBase64String().GetCStr()
    val base64Buf = Base64.decode(base64String, Base64.DEFAULT)
    return BitmapFactory.decodeByteArray(base64Buf, 0, base64Buf.size)
}


// COPY FROM Quadrangle
fun Quadrangle.toQuad() : Quad {
    val points = ArrayList<QuadPoint>()
    for (i in 0..3) {
        GetPoint(i).apply {
            points.add(
                QuadPoint(x.toFloat(), y.toFloat())
            )
        }
    }
    //Log.w(TAG," + Quad: ${points}")
    return Quad(points)
}
