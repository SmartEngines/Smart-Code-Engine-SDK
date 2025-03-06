/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.nfc

import android.graphics.Bitmap

sealed interface FaceImageBitmap {
    data class Success(val bitmap: Bitmap) : FaceImageBitmap
    data class Error  (val error : String) : FaceImageBitmap
}