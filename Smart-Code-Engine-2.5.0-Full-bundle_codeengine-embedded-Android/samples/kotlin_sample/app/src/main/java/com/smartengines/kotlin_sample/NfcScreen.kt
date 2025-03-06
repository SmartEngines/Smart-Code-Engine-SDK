/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import android.app.Activity
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.requiredHeightIn
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.smartengines.kotlin_sample.ui.theme.Kotlin_sampleTheme
import com.smartengines.nfc.NfcAdapter
import com.smartengines.nfc.PassportKey
import com.smartengines.nfc.PassportReaderState

@Composable
fun NfcScreen(){
    val state by Model.passportReader.stateFlow.collectAsState()
    NfcScreen(state)
}

@Composable
fun NfcScreen(state: PassportReaderState) {
    val context = LocalContext.current
    Card{
        Text(
            text = "RFID tag",
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 10.dp),
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.primary,
            textAlign = TextAlign.Center,
        )

        Box(
        Modifier.fillMaxWidth().requiredHeightIn(min = 130.dp),
        contentAlignment = Alignment.Center
    ){
        Column(
            Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            when (state) {

                // DISABLED (initial)
                PassportReaderState.Disabled -> {
                    OutlinedButton(onClick = {
                        NfcAdapter.enableNfcReceiving(context as Activity, true)
                        Model.passportReader.activate()
                    }) {
                        Text("Read the RFID tag")
                    }
                }

                // WAITING for the TAG
                PassportReaderState.Waiting -> {
                    Text("Move your device to the passport tag")
                    OutlinedButton(onClick = {
                        Model.passportReader.reset()
                    }) { Text("Cancel") }
                }

                // LOADING
                PassportReaderState.Reading -> {
                    Text("Reading data...")
                }

                // FATAL ERROR
                PassportReaderState.NotSupported -> {
                    Text(
                        "NFC is not supported by your device",
                        color = MaterialTheme.colorScheme.error
                    )
                }

                // READING ERROR
                is PassportReaderState.Error -> {
                    Text(
                        state.message,
                        color = MaterialTheme.colorScheme.error
                    )
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceAround) {
                        OutlinedButton(onClick = {
                            Model.passportReader.activate()
                        }) { Text("Retry") }

                        OutlinedButton(onClick = {
                            Model.passportReader.reset()
                        }) { Text("Cancel") }
                    }
                }

                // DATA
                is PassportReaderState.Data -> {
                    NfcDataScreen(state.data)
                }
            }
        }
    }}
}

//--------------------------------------------------------------------------------------------------
// PREVIEW
@Preview(showBackground = true)
@Composable
private fun Disabled_Preview() {
    Kotlin_sampleTheme(darkTheme = true) {
        NfcScreen(PassportReaderState.Disabled)
    }
}
@Preview(showBackground = true)
@Composable
private fun Waiting_Preview() {
    Kotlin_sampleTheme(darkTheme = true) {
        NfcScreen(PassportReaderState.Waiting)
    }
}
@Preview(showBackground = true)
@Composable
private fun Reading_Preview() {
    Kotlin_sampleTheme(darkTheme = true) {
        NfcScreen(PassportReaderState.Reading)
    }
}
@Preview(showBackground = true)
@Composable
private fun NotSupported_Preview() {
    Kotlin_sampleTheme(darkTheme = true) {
        NfcScreen(PassportReaderState.NotSupported)
    }
}
@Preview(showBackground = true)
@Composable
private fun Error_Preview() {
    Kotlin_sampleTheme(darkTheme = true) {
        NfcScreen(PassportReaderState.Error("Data reading error"))
    }
}
