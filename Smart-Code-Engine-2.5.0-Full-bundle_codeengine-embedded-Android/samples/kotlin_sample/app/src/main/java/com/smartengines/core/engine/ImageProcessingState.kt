/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine

import android.graphics.Bitmap

/**
 * ImageProcessor state machine
 * The main recognition process steps.
 */
sealed interface ImageProcessingState {

    data object READY : ImageProcessingState

    data class  VIDEO_PROCESSING(
        val target          : SessionTarget,
        val visualization   : Visualization?, // null means the engine is not ready
    ) : ImageProcessingState

    data class  PHOTO_PROCESSING(
        val target          : SessionTarget,
        val visualization   : Visualization?, // null means the engine is not ready
        val photo           : Bitmap
    ) : ImageProcessingState

    data class  SELFIE_CHECKING(
        val session : Session // session object to make selfie compare
    ) : ImageProcessingState

    data class  FINISHED(
        val session : Session // session object for result screens
    ) : ImageProcessingState

    data class  ERROR(
        val error: Exception
    ) : ImageProcessingState
}