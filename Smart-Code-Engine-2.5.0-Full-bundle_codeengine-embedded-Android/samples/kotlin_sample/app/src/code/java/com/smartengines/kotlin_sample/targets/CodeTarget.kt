/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample.targets

import com.smartengines.code.CodeEngineSessionSettings

data class CodeTarget(
    val internalEngine : String,
    val supportedTypes : Set<String>
) : AppTarget {
    override val name: String
        get() = internalEngine
    override val description: String?
        get() = if(supportedTypes.isEmpty()) null else supportedTypes.toString()
    override val cropImage: Boolean
        get() = internalEngine=="text_line"

    override fun fillSessionSettings(sessionSettings : Any){
        with(sessionSettings as CodeEngineSessionSettings) {
            // Set common options
            SetOption("global.sessionTimeout", "15.0")

            // Enable the engine
            SetOption("$internalEngine.enabled", "true")

            // Engine-dependent settings
            when (internalEngine) {
                "bank_card" -> {
                    SetOption("bank_card.extractBankCardImages.enabled", "true")
                }

                "barcode" -> {
                    SetOption("barcode.roiDetectionMode", "anywhere")
                    SetOption("_vizRoiDetections", "true")
                    SetOption("barcode.maxAllowedCodes", "3")
                    SetOption("barcode.feedMode", "single")
                }

                else -> {}
            }

            // Enable supported types (disabled by default)
            supportedTypes.forEach {
                //SetOption("$engine.$it.enabled","true")
                SetOption("$internalEngine.$it.enabled","true")
            }
        }
    }
}