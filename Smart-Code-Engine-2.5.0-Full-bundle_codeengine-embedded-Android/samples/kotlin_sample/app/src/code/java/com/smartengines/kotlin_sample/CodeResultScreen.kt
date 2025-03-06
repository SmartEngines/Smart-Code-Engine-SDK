/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import android.graphics.BitmapFactory
import android.hardware.camera2.params.BlackLevelPattern
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.border
import androidx.compose.foundation.focusable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.smartengines.core.engine.code.CodeEngineSession
import com.smartengines.core.engine.code.CodeObjectData
import com.smartengines.core.engine.code.CodeObjectField
import com.smartengines.core.engine.code.CodeResultData
import com.smartengines.core.engine.Session
import com.smartengines.core.engine.code.parse
import com.smartengines.kotlin_sample.ui.theme.Kotlin_sampleTheme
import com.smartengines.nfc.PassportKey

/**
 * TAKE THE SESSION => GET AND SHOW THE CURRENT RESULT
 */

@Composable
fun CodeResultScreen(session: Session) {
    val codeResultData = remember{
        // READ CURRENT RESULT
        (session as CodeEngineSession).codeSession
            .GetCurrentResult()
            .parse()
            .also {
                // Side effect
                Model.setPassportKey( it.passportKey )
            }
    }

    // Screen
    if(codeResultData.isEmpty){
        NoResult()
    }else{
        CodeResultScreen(resultData = codeResultData)
    }
}

@Composable
private fun NoResult() {
    Text("Document not found")
}

@Composable
private fun CodeResultScreen(resultData: CodeResultData) {
    Box(modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.TopStart
    ) {
        Column(
            modifier = Modifier
                .verticalScroll(rememberScrollState())
                .fillMaxWidth()
                .padding(horizontal = 10.dp),
            verticalArrangement = Arrangement.Top
        ) {
            // NFC
            resultData.passportKey?.let {
                NfcScreen()
            }
            // CODE DATA
            resultData.objects.forEach {
                CodeObjectScreen(it)
            }
        }
    }
}
@Composable
fun CodeObjectScreen(codeObject: CodeObjectData){
    val focusedColor = MaterialTheme.colorScheme.surfaceVariant
    val unfocusedColor = focusedColor.copy(alpha = 0.5f)
    var color by remember { mutableStateOf(unfocusedColor) }
    with(codeObject) {
        Card(modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 10.dp)
            .onFocusChanged {
                color = if (it.isFocused) focusedColor else unfocusedColor
            }
            .focusable(),
            shape = RoundedCornerShape(10.dp),
            //border = BorderStroke(width = 2.dp, color = Color.Gray),
            colors = CardDefaults.cardColors().copy(containerColor = color)
        ) {
        Column(modifier = Modifier
            .fillMaxWidth()
            .padding(10.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ){
            // TYPE
            Text(text = type,
                Modifier
                    .padding(bottom = 0.dp)
                    .fillMaxWidth(),
                textAlign = TextAlign.Center,
                style = MaterialTheme.typography.titleMedium,
            )
            // FIELDS
            fields.forEach {
                FieldRow(field = it)
            }
            // IMAGE
            image?.let {
               Image(
                    bitmap = it.asImageBitmap(), contentDescription = null,
                    modifier = Modifier.fillMaxWidth(0.3f).padding(bottom = 3.dp),
                    contentScale = ContentScale.FillWidth
                )
            }

        }
        }
    }
}
@Composable
private fun FieldRow(field: CodeObjectField) {
    with(field) {
        Column(
            Modifier
                .fillMaxWidth()
                .padding(vertical = 1.dp)) {
            // name + isAccepted
            Row(Modifier.fillMaxWidth()) {
                Text(text = name,
                    modifier = Modifier.weight(1f))
                Text(text = isAccepted.toString())
            }
            // Value
            Text(text = value, fontWeight = FontWeight.Bold)
        }
        //Spacer(modifier = Modifier.height(2.dp))
    }
}

//--------------------------------------------------------------------------------------------------
// PREVIEW
@Preview(showBackground = true, showSystemUi = false)
@Composable
private fun CodeResultScreen_Preview() {
    val context = LocalContext.current
    Kotlin_sampleTheme(darkTheme = true) {
        Surface {
            CodeResultScreen(
                CodeResultData(
                    objects = listOf(
                        CodeObjectData(
                            type = "MRZ",
                            fields = listOf(
                                CodeObjectField("full_mrz","P<RUSMAYACHENKOV<<IGOR<<<<<<<<<<<<<<<<<<<<<<7114238741RUS7110276M2007221<<<<<<<<<<<<<<06", true)
                            ),
                            image = null
                        ),
                        CodeObjectData(
                            type = "MatrixBarcode",
                            fields = listOf(
                                CodeObjectField("field name 1", "field value 1", true),
                                CodeObjectField("field name 2", "field value 2", false),
                            ),
                            image = BitmapFactory.decodeResource(
                                context.resources,
                                R.drawable.ic_launcher_background
                            )
                        ),
                        CodeObjectData(
                            type = "LinearBarcode",
                            fields = emptyList(),
                            image = null
                        ),
                    ),
                    passportKey = PassportKey("","","")
                )
            )
        }
    }
}
