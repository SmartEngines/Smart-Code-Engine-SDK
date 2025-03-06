/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.nfc

// JMRTD library
import org.jmrtd.lds.icao.MRZInfo
import org.jmrtd.lds.iso19794.FaceInfo

data class PassportData(
    // Passport data fields
    val mrzInfo     : MRZInfo,         // from DG1File
    val faceInfos   : List<FaceInfo>,  // from DG2File
    // Checks
    val chipAuth    : AuthResult?,
    val dataAuth    : AuthResult?
)