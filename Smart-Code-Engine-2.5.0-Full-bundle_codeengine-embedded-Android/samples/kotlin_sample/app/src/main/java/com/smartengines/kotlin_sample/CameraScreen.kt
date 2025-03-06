/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import android.Manifest
import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.camera.core.ImageProxy
import androidx.camera.view.CameraController
import androidx.camera.view.PreviewView
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.google.accompanist.permissions.ExperimentalPermissionsApi
import com.google.accompanist.permissions.PermissionState
import com.google.accompanist.permissions.isGranted
import com.google.accompanist.permissions.rememberPermissionState
import com.google.accompanist.permissions.shouldShowRationale
import com.smartengines.core.engine.Frame
import com.smartengines.kotlin_sample.targets.applyTargetCrop
import java.util.concurrent.Executors

private const val TAG = "myapp.CameraScreen"

@OptIn(ExperimentalPermissionsApi::class)
@Composable
fun CameraScreen(
    onVideoFrame:((Frame)->Unit)?, // enables video mode
    onPhotoTaken:((Bitmap)->Unit)?, // enables photo mode
    cropImage:Boolean,
    startVideoImmediately : Boolean=false
){
    // Permissions state
    val cameraPermissionState: PermissionState = rememberPermissionState(Manifest.permission.CAMERA)
    AutoRequestCameraPermission(cameraPermissionState)

    // Camera state
    val isCameraEnabled =
        cameraPermissionState.status.isGranted// && state !is CameraViewModel.BasicState.FINISHED
    Log.d(TAG, "isCameraEnabled: $isCameraEnabled")

    // INIT CAMERA (Camera controller)
    val analyzerExecutor = remember { Executors.newSingleThreadExecutor() }
    fun onVideoFrameHandler(imageProxy:ImageProxy){
        Log.d(TAG," --- video frame, onVideoFrame=$onVideoFrame")
        // Load bitmap
        var bitmap = ImageFactory.bitmapFromCameraImage(imageProxy,isFrontCamera = false)
        // crop if need
        if(cropImage)
            bitmap = bitmap.applyTargetCrop()
        // Call back
        onVideoFrame?.invoke(
            Frame(
                imageProxy = imageProxy,
                bitmap = bitmap
            )
        )
    }
    val context: Context = LocalContext.current
    val cameraController = rememberCameraController(
        context = context,
        analyzerExecutor = analyzerExecutor,
        onVideoFrame = ::onVideoFrameHandler
    )

    // Capturing state (photo or video)
    var capturingStarted by remember { mutableStateOf(false) }
    fun startImageAnalysis(){
        capturingStarted = true
        cameraController.setImageAnalysisAnalyzer(analyzerExecutor, ::onVideoFrameHandler)// reset handler
        cameraController.setEnabledUseCases(CameraController.IMAGE_ANALYSIS)
    }
    if(startVideoImmediately) startImageAnalysis()

    // START/STOP THE CAMERA
    StartStopCameraEffect(
        isCameraEnabled = isCameraEnabled,
        cameraController = cameraController
    )

    //----------------------------------------------------------------------------------------------
    // THE SCREEN
    Box(
        Modifier
            .fillMaxSize()
            .background(Color.Black),
        contentAlignment = Alignment.BottomCenter
    ) {
        if (cameraPermissionState.status.isGranted) {
            // CAMERA PREVIEW
            AndroidView(modifier = Modifier
                .fillMaxSize(),
                factory = { context ->
                    PreviewView(context).apply {
                        layoutParams = LinearLayout.LayoutParams(
                            ViewGroup.LayoutParams.MATCH_PARENT,
                            ViewGroup.LayoutParams.MATCH_PARENT
                        )
                        setBackgroundColor(android.graphics.Color.BLACK)
                        implementationMode = PreviewView.ImplementationMode.COMPATIBLE
                        scaleType = PreviewView.ScaleType.FILL_START
                    }.also { previewView ->
                        previewView.controller = cameraController
                    }
                }
            )
            // CROP FRAME OVER THE CAMERA
            if(cropImage){
                CropFrameScreen()
            }


            // CAMERA TOOLBAR ("Start video" / "Take photo" buttons)
            Box(modifier = Modifier.padding(bottom = 40.dp),) {
                onVideoFrame?.let {
                    if(!capturingStarted) {
                        Button(
                            onClick = ::startImageAnalysis
                        ) {
                            Icon(
                                painter = painterResource(id = R.drawable.ic_videocam),
                                modifier = Modifier.padding(end = 10.dp),
                                contentDescription = null
                            )
                            Text("start video")
                        }
                    }
                }
                onPhotoTaken?.let { onPhotoTaken ->
                    Button(
                        enabled = !capturingStarted,
                        onClick = {
                            capturingStarted = true
                            cameraController.setEnabledUseCases(CameraController.IMAGE_CAPTURE)
                            takePhoto(
                                context = context,
                                cameraController = cameraController,
                                onPhotoTaken = { imageProxy, isFrontCamera ->
                                    // Get bitmap from image proxy
                                    var bitmap : Bitmap = ImageFactory.bitmapFromCameraImage(imageProxy,isFrontCamera = false)
                                    imageProxy.close()
                                    // Apply target crop if need
                                    if(cropImage)
                                        bitmap = bitmap.applyTargetCrop()
                                    // Call back
                                    onPhotoTaken( bitmap )
                                }
                            )
                        }
                    ) {
                        Icon(painter = painterResource(id = R.drawable.ic_photo), modifier = Modifier.padding(end=10.dp), contentDescription = null)
                        Text("take photo")
                    }
                }
            }
        } else {
            // No Permissions view
            NoPermissions(cameraPermissionState)
        }
    }
}

@OptIn(ExperimentalPermissionsApi::class)
@Composable
fun NoPermissions(permissionState: PermissionState){
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(text = "The camera permissions are not granted")
        if(permissionState.status.shouldShowRationale) {
            Spacer(modifier = Modifier.height(50.dp))
            Button(onClick = permissionState::launchPermissionRequest) {
                Text(text = "Grant the permissions")
            }
        }
    }
}
