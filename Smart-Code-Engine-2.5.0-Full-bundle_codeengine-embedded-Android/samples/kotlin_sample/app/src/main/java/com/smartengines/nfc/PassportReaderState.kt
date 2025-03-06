/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.nfc

sealed interface PassportReaderState{
    data object Disabled                    : PassportReaderState
    data object Waiting                     : PassportReaderState // waiting for nfc-tag detection
    data object Reading                     : PassportReaderState // reading data from the nfc tag
    data class  Data (val data: PassportData): PassportReaderState
    data class  Error(val message:String)   : PassportReaderState
    data object NotSupported                :
        PassportReaderState // the device hasn't got nfc-adapter
}
