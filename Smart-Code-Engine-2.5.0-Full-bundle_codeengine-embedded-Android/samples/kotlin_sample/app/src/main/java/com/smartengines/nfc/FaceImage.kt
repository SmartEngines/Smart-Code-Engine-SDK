/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.nfc

import org.jmrtd.lds.iso19794.FaceImageInfo

data class FaceImage(
    val info  : FaceImageInfo,
    val bitmap: FaceImageBitmap
)
