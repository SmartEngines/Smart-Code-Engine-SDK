/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine

/**
 * THE RECOGNITION TARGET DOCUMENT DESCRIPTOR
 * It is just a source to create the recognition session settings
 * so fully depends on the engine type
 */
interface SessionTarget{
    fun fillSessionSettings(sessionSettings:Any)
}
