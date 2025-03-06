/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine.code

import android.graphics.Bitmap
import com.smartengines.code.CodeEngineResult
import com.smartengines.code.CodeField
import com.smartengines.code.CodeObject
import android.util.Base64
import android.graphics.BitmapFactory
import com.smartengines.nfc.PassportKey

/**
 * PARSE CodeEngineResult => CodeResultData
 */

fun CodeEngineResult.parse(): CodeResultData {
    val objects = ArrayList<CodeObjectData>().apply {
        val iterator = ObjectsBegin()
        val end      = ObjectsEnd()
        while (!iterator.Equals(end)){
            add(iterator.GetValue().parse())
            iterator.Advance()
        }
    }
    return  CodeResultData(
        objects = objects,
        passportKey = calculatePassportKey(objects)
    )
}

private fun calculatePassportKey(objects : List<CodeObjectData>): PassportKey?{
    try {
        objects.forEach { codeObject->
            codeObject.fields.find { it.name == "full_mrz" }?.let {
                return PassportKey.fromMRZ(it.value)
            }
        }
    }catch (_:Exception){}
    return null
}

fun CodeObject.parse(): CodeObjectData {
    return CodeObjectData(
        type   = GetTypeStr(),
        fields = parseFields(),
        image  = parseImage()
    )
}

fun CodeObject.parseFields():List<CodeObjectField> {
    return ArrayList<CodeObjectField>().apply {
        val iterator = FieldsBegin()
        val end = FieldsEnd()
        while (!iterator.Equals(end)) {
            add( iterator.GetValue().parse() )
            iterator.Advance()
        }
    }
}

fun CodeField.parse(): CodeObjectField {
    return CodeObjectField(
        name = Name(),
        value = if (HasOcrStringRepresentation())
            GetOcrString().GetFirstString().GetCStr()
        else
            GetBinaryRepresentation().GetBase64String().GetCStr(),
        isAccepted = IsAccepted()
    )
}

fun CodeObject.parseImage(): Bitmap? {
    if(!HasImage()) return null
    val base64String = GetImage().GetBase64String().GetCStr()
    val base64Buf = Base64.decode(base64String, Base64.DEFAULT)
    return BitmapFactory.decodeByteArray(base64Buf, 0, base64Buf.size)
}