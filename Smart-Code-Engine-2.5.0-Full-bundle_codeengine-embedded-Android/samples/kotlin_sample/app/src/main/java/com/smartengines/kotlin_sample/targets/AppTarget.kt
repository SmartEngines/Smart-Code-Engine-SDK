/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample.targets

import com.smartengines.core.engine.SessionTarget

/**
 * The target interface required in this sample application
 * as extension of the base SessionTarget interface
 */
interface AppTarget : SessionTarget {
    val name        : String
    val description : String?
    val cropImage   : Boolean // some targets required cropped image
}