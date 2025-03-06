/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.nfc

import android.content.Context
import android.nfc.tech.IsoDep
import org.jmrtd.BACKey

/**
 * The interface which implementation should do the main passport reading logic
 */

interface ReadingEngine {

    /**
     * Init the engine
     * Must be called before other actions
     */
    fun open(isoDep : IsoDep )

    /**
     * Free resources
     * Must be run after all
     * Must not throw any exception in any case
     */
    fun close()

    /**
     * Read data without any checks
     */
    fun readPassportData(bacKey : BACKey, context : Context ) : PassportData

    /**
     * Check the chip (is not replaced)
     */
    fun doChipAuth() : AuthResult

    /**
     * Check the data (is not changed)
     */
    fun doDataAuth(context: Context) : AuthResult
}