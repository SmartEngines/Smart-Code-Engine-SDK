/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.nfc

sealed interface AuthResult {
    data object Passed                   : AuthResult
    data class  Failed(val error:String) : AuthResult
}