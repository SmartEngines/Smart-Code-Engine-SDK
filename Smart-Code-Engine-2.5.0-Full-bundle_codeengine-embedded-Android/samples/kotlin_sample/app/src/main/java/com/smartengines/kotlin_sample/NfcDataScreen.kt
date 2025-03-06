/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import android.util.Log
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.smartengines.core.engine.common.imageToBitmap
import com.smartengines.nfc.FaceImageBitmap
import com.smartengines.kotlin_sample.ui.theme.Kotlin_sampleTheme
import com.smartengines.nfc.PassportData
import net.sf.scuba.data.Gender
import org.jmrtd.lds.icao.MRZInfo
import org.jmrtd.lds.iso19794.FaceImageInfo
import java.io.DataInputStream

@Composable
fun NfcDataScreen(data: PassportData){
    Column(Modifier.fillMaxWidth()) {

        Header(text = "MRZ")
        with(data.mrzInfo) {
            DataRow("document code", documentCode)
            DataRow("issuing state", issuingState)
            DataRow("last name", primaryIdentifier)
            DataRow("first name", secondaryIdentifier)
            DataRow("document number", documentNumber)
            DataRow("nationality", nationality)
            DataRow("date of birth", dateOfBirth)
            DataRow("gender", gender.toString())
            DataRow("date of expiry", dateOfExpiry)
            DataRow("personalNumber", personalNumber)
        }

        Header(text = "FACES")
        data.faceInfos.forEach {
            it.faceImageInfos.forEach {
                FaceImageInfoRow(it)
            }
        }
    }

}

@Composable
fun Header(text: String){
    Text(
        text = text,
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 10.dp),
        style = MaterialTheme.typography.titleMedium,
//        color = MaterialTheme.colorScheme.primary,
        textAlign = TextAlign.Center,
    )
}

@Composable
private fun DataRow(label:String, value:String){
    Row(
        Modifier
            .fillMaxWidth()
            .padding(bottom = 10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(modifier = Modifier.weight(1f),
            text = label,  style = MaterialTheme.typography.labelSmall)
        Text(modifier = Modifier.weight(2f),
            text = value,  style = MaterialTheme.typography.bodyMedium)

    }
}
@Composable
private fun FaceImageInfoRow(faceImageInfo: FaceImageInfo) {
    with(faceImageInfo) {
        // IMAGE
        when(val faceImageBitmap = decodeFaceImage(faceImageInfo)){
            is FaceImageBitmap.Success -> {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center) {
                    Image(
                        bitmap = faceImageBitmap.bitmap.asImageBitmap(),
                        contentDescription = null
                    )
                }
            }
            is FaceImageBitmap.Error -> {
                Text(faceImageBitmap.error, color = MaterialTheme.colorScheme.error)
            }
        }

        // TEXT FIELDS
        FaceImageInfoTextRow("image size:","$width x $height")
        FaceImageInfoTextRow("Gender:",         gender.toString())
        FaceImageInfoTextRow("Eye color:",      eyeColor.toString())
        FaceImageInfoTextRow("Hair color:",     hairColor.toString())
        FaceImageInfoTextRow("Expression:",     expression.toString())
        //FaceImageInfoTextRow("Pose angle:",     poseAngle.toString())
        FaceImageInfoTextRow("Face image type:",faceImageType.toString())
        FaceImageInfoTextRow("Source type:",    sourceType.toString())
    }


}
@Composable
private fun FaceImageInfoTextRow(label:String, value:String) {
    Row(Modifier.fillMaxWidth()){
        Text(label, Modifier.weight(1f), style = MaterialTheme.typography.labelSmall)
        Text(value, Modifier.weight(1f))
    }
}

//--------------------------------------------------------------------------------------------------
// Return bitmap or error
fun decodeFaceImage( faceImageInfo: FaceImageInfo ): FaceImageBitmap {
    return try {
        // Read buffer
        val imageLength = faceImageInfo.imageLength
        val dataInputStream = DataInputStream(faceImageInfo.imageInputStream)
        val buffer = ByteArray(imageLength)
        dataInputStream.readFully(buffer, 0, imageLength)

        // Decode by the SDK
        val image = com.smartengines.common.Image
            .FromFileBuffer(buffer)

        // Convert to bitmap
        val bitmap = imageToBitmap(image)

        // Success!
        FaceImageBitmap.Success(bitmap)
    } catch (e: Exception) {
        //Log.e(TAG, "face image decode error", e)
        FaceImageBitmap.Error(e.toString())
    }
}

//--------------------------------------------------------------------------------------------------
// PREVIEW
@Preview(showBackground = true)
@Composable
private fun NfcDataScreen_Preview() {
    val passportData = PassportData(
        mrzInfo = MRZInfo(
            "P",//documentCode
            "RUS",//issuingState
            "KRYUCHKOVA",//primaryIdentifier
            "KSENIA<<<<<<<<<<<<<<<<<<<<<",//secondaryIdentifier
            "715599956",//documentNumber
            "RUS",//nationality
            "971010",//dateOfBirth
            Gender.FEMALE,//gender
            "210802",//dateOfExpiry
            ""//personalNumber
        ),
        faceInfos = emptyList(),
        chipAuth = null,
        dataAuth = null
    )

    Kotlin_sampleTheme(darkTheme = true) {
        Surface{
            NfcDataScreen(passportData)
        }
    }
}
