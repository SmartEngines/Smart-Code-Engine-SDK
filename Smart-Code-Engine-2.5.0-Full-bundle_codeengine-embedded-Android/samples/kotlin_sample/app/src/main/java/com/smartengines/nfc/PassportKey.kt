/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.nfc

import org.jmrtd.lds.icao.MRZInfo

/**
 * More convenient copy of BACKey
 */
data class PassportKey(
    val passportNumber : String,
    val expirationDate : String,
    val birthDate      : String
){
    companion object{
        fun fromMRZ(mrz:String): PassportKey {
            try {
                val mrzInfo = MRZInfo(mrz)
                return PassportKey(
                    mrzInfo.documentNumber,
                    mrzInfo.dateOfExpiry,
                    mrzInfo.dateOfBirth
                )
            }catch (e:Exception){
                throw Exception("Can't parse MRZ string: $e")
            }
        }
    }
}