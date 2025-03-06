/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import android.content.Context
import android.util.Log
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageProxy
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.view.CameraController
import androidx.camera.view.LifecycleCameraController
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.core.content.ContextCompat
import com.google.accompanist.permissions.ExperimentalPermissionsApi
import com.google.accompanist.permissions.PermissionState
import com.google.accompanist.permissions.isGranted
import java.util.concurrent.Executor

private const val TAG = "myapp.CameraStaff"

@Composable
fun rememberCameraController(
    context: Context,
    cameraSelector:CameraSelector = CameraSelector.DEFAULT_BACK_CAMERA,
    analyzerExecutor: Executor ?= null,
    onVideoFrame:((ImageProxy)->Unit) ?= null
): LifecycleCameraController {
    return remember {
        Log.w(TAG, "init camera")
        val controller = LifecycleCameraController(context)
        if(analyzerExecutor!=null && onVideoFrame!=null)
            controller.setImageAnalysisAnalyzer(analyzerExecutor, onVideoFrame)
        controller.setEnabledUseCases(0)
        // Set camera
        controller.cameraSelector =  cameraSelector
        // Set resolution
        val resolutionSelector = ResolutionSelector.Builder()
            .setResolutionStrategy(ResolutionStrategy.HIGHEST_AVAILABLE_STRATEGY)
//        .setAllowedResolutionMode(ResolutionSelector.PREFER_HIGHER_RESOLUTION_OVER_CAPTURE_RATE)
//        .setResolutionStrategy(
//            ResolutionStrategy(
//                Size(1000, 1000),
//                ResolutionStrategy.FALLBACK_RULE_CLOSEST_LOWER
//            )
//        )
            .build()
        controller.imageAnalysisResolutionSelector = resolutionSelector
        controller.imageCaptureResolutionSelector  = resolutionSelector

        controller
    }
}

@Composable
fun StartStopCameraEffect(
    isCameraEnabled:Boolean,
    cameraController: LifecycleCameraController,
){
    val lifecycleOwner = LocalLifecycleOwner.current
    SideEffect {
        if (isCameraEnabled) {
            if (cameraController.cameraInfo == null) {
                Log.e(TAG, "start the camera")
                cameraController.bindToLifecycle(lifecycleOwner)
            }
        } else {
            if (cameraController.cameraInfo != null) {
                Log.e(TAG, "stop the camera")
                cameraController.unbind()
            }
        }
    }
}

fun switchCamera(controller:CameraController){
    controller.cameraSelector =
        if(controller.cameraSelector== CameraSelector.DEFAULT_BACK_CAMERA)
            CameraSelector.DEFAULT_FRONT_CAMERA
        else
            CameraSelector.DEFAULT_BACK_CAMERA
}

fun takePhoto(
    context: Context,
    cameraController: LifecycleCameraController,
    onPhotoTaken:(ImageProxy, isFrontCamera:Boolean)->Unit
){
    cameraController.takePicture(ContextCompat.getMainExecutor(context), object : ImageCapture.OnImageCapturedCallback() {
        override fun onCaptureSuccess(image: ImageProxy) {
            Log.w(TAG, "onCaptureSuccess image size:${image.width}x${image.height} ")
            onPhotoTaken(image,
                cameraController.cameraSelector==CameraSelector.DEFAULT_FRONT_CAMERA)
        }
    })
}

@OptIn(ExperimentalPermissionsApi::class)
@Composable
fun AutoRequestCameraPermission(permissionState: PermissionState){
    CameraPermissionRequestEffectLauncher(permissionState.status.isGranted, permissionState)
}
@OptIn(ExperimentalPermissionsApi::class)
@Composable
private fun CameraPermissionRequestEffectLauncher(isGranted:Boolean, permissionState: PermissionState){
    SideEffect {
        if(!isGranted) permissionState.launchPermissionRequest()
    }
}
