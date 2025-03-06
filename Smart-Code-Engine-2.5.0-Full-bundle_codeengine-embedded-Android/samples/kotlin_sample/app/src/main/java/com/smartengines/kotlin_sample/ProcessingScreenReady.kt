/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import android.content.Context
import android.graphics.Bitmap
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.smartengines.core.engine.Engine
import com.smartengines.core.engine.SessionTarget
import com.smartengines.core.engine.SessionType
import com.smartengines.kotlin_sample.targets.AppTarget
import com.smartengines.kotlin_sample.ui.theme.Kotlin_sampleTheme

@Composable
fun ProcessingScreenReady(
    engine: Engine,
    target: AppTarget,
    startProcessing:(Engine, SessionTarget, SessionType, photo: Bitmap?)->Unit
){
    var isPhotoTaking by remember { mutableStateOf(false) }

    BackHandler(enabled = isPhotoTaking) {
        if(isPhotoTaking) isPhotoTaking = false
    }


    if(isPhotoTaking) {
        // Show Camera to take photo
        CameraScreen(
            onVideoFrame = null,
            onPhotoTaken = {photo->
                startProcessing(
                    engine,
                    target,
                    SessionType.PHOTO_SESSION,
                    photo
                )
            },
            cropImage = (target as AppTarget).cropImage
        )
    }else {
        Column(
            Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
        ) {
            Text(
                text = "Select image source to recognize by",
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 20.dp),
                textAlign = TextAlign.Center
            )

            // VIDEO
            if(engine.isVideoModeAllowed) {
                MenuButton(
                    R.drawable.ic_videocam,
                    "Video","Camera video stream",
                    {
                        startProcessing(
                            engine,
                            target,
                            SessionType.VIDEO_SESSION,
                            null
                        )
                    }
                )
            }

            // PHOTO
            MenuButton(
                R.drawable.ic_photo,
                "Photo","One image from camera"
            ){
                isPhotoTaking = true
            }

            // GALLERY
            val context: Context = LocalContext.current
            val gallery =
                rememberLauncherForActivityResult(ActivityResultContracts.GetContent()) { uri ->
                    uri?.let {
                        // Load image bitmap
                        val bitmap = ImageFactory.bitmapFromFile(context, uri)
                        // event
                        startProcessing(
                            engine,
                            target,
                            SessionType.PHOTO_SESSION,
                            bitmap
                        )
                    }
                }
            MenuButton(
                R.drawable.ic_gallery,
                "Gallery","One image from gallery"
            ){
                gallery.launch("image/*")
            }
        }
    }
}

@Composable
private fun MenuButton(
    iconId:Int,
    title : String,
    descr : String,
    onClick:()->Unit
){
    Card(modifier = Modifier
        .fillMaxWidth()
        .padding(bottom = 20.dp)
        .clickable(onClick = onClick)
    ) {
        Row(Modifier.padding(10.dp), verticalAlignment = Alignment.CenterVertically) {
            Icon(painterResource(id = iconId),
                modifier = Modifier
                    .padding(end = 10.dp), contentDescription = null)
            Column {
                Text(title, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                Text(descr)
            }
        }
    }

}

//--------------------------------------------------------------------------------------------------
// PREVIEW
@Preview(showBackground = true)
@Composable
private fun ProcessingScreenReady_Preview() {
    Kotlin_sampleTheme {
        ProcessingScreenReady(
            MockEngine(isVideoModeAllowed = true),
            MockTarget(),
            {_,_,_,_->}
        )
    }
}
