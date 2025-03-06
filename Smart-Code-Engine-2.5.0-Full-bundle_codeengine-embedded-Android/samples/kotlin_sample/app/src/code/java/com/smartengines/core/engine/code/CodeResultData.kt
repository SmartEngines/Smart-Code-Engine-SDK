/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine.code

import android.graphics.Bitmap
import com.smartengines.nfc.PassportKey

data class CodeResultData(
    val objects : List<CodeObjectData>,
    val passportKey: PassportKey? // RFID passport key
){
    val isEmpty : Boolean  get() = objects.isEmpty()
}

data class CodeObjectData(
    val type   : String,
    val fields : List<CodeObjectField>,
    val image  : Bitmap?
)

data class CodeObjectField(
    val name : String,
    val value: String,
    val isAccepted:Boolean
)
