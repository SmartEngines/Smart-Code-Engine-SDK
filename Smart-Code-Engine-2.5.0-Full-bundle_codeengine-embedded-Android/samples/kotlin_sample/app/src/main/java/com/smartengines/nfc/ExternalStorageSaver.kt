/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.nfc

import android.content.ContentResolver
import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.util.Log
import android.provider.MediaStore
import java.io.OutputStream

private const val TAG = "myapp.ExternalStorage"

object ExternalStorageSaver {

    /**
     * directory depends on the mimeType
     * mime-type = type "/" [tree "."] subtype ["+" suffix]* [";" parameter];
     *      allowed directories are:
     *      MediaStore.Images      image : DCIM, Pictures
     *      MediaStore.Downloads     *   : Download
     *      MediaStore.Files         *   : Download, Documents
     */
    enum class ImageDirectories{ DCIM, Pictures }
    enum class FileDirectories { Download, Documents }

    fun saveFile(
        context  : Context,
        buffer   : ByteArray,
        directory: FileDirectories,
        filename : String,
        mimeType : String
    ){
        saveBuffer(
            context  = context,
            buffer   = buffer,
            tableUri = MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL),
            directory = directory.toString(),
            filename = filename,
            mimeType = mimeType
        )
    }

    fun saveImage(
        context  : Context,
        buffer   : ByteArray,
        directory: ImageDirectories,
        filename : String,
        mimeType : String
    ){
        saveBuffer(
            context  = context,
            buffer   = buffer,
            tableUri = if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
                            MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
                       else MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            directory = directory.toString(),
            filename = filename,
            mimeType = mimeType
        )
    }

    //----------------------------------------------------------------------------------------------
    // IMPLEMENTATION
    private fun saveBuffer(
        context  : Context,
        buffer   : ByteArray,
        tableUri : Uri,
        directory: String,
        filename : String,
        mimeType : String
    ){
        Log.w(TAG,"saveBuffer size: ${buffer.size}  filename: $filename")

        val resolver: ContentResolver = context.contentResolver
        // Fill content provider values
        val contentValues = ContentValues()
        contentValues.put(MediaStore.MediaColumns.RELATIVE_PATH, directory)
        contentValues.put(MediaStore.Images.Media.DISPLAY_NAME,  filename)
        contentValues.put(MediaStore.Images.Media.MIME_TYPE,     mimeType)

        // Insert the values to the "table"
        val fileUri:Uri = resolver.insert(tableUri, contentValues)?:throw Exception("insert is failed")
        // Open file
        val stream: OutputStream = resolver.openOutputStream(fileUri)?:throw Exception("can't open file for writing")

        // Write the data
        stream.write(buffer)

        // close the stream
        stream.close()
        Log.d(TAG,"..... file ${filename} is saved")
    }
}