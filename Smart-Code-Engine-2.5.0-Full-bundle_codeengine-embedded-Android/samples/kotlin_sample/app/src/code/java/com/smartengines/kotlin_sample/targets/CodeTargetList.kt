/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample.targets

import android.util.Log
import com.smartengines.code.CodeEngineSessionSettings
import com.smartengines.core.engine.Engine
import com.smartengines.core.engine.code.CodeEngineWrapper

object CodeTargetList {
    private val TAG = "myapp.CodeTargetList"
    fun load(engine: Engine) : List<AppTarget> {
        val codeEngine = (engine as CodeEngineWrapper).codeEngine

        val engines = HashSet<String>()
        val sessionSettings = codeEngine.GetDefaultSessionSettings()

        val skipList = setOf("global")

        // SETTINGS LOOP
        val setting    = sessionSettings.SettingsBegin()
        val settingEnd = sessionSettings.SettingsEnd()
        while (!setting.Equals(settingEnd)){
            //Log.w(TAG,"   ---   ${setting.GetKey()}")
            val key = setting.GetKey()
            val subkeys = key.split(".")
            if(subkeys.size == 3) {
                //Log.w(TAG, "subkeys: $subkeys")
                val first  = subkeys.get(0) // get "type" from "type.smth.enabled" key
                if (!skipList.contains(first)) {
                    engines.add(first)
                }
            }
            // MRZ - special case
            if(key=="mrz.enabled"){
                engines.add("mrz")
            }

            // NEXT SETTING
            setting.Advance()
        }
        return ArrayList<AppTarget>().apply {
            engines.forEach {
                add(
                    CodeTarget(
                        internalEngine = it,
                        supportedTypes = sessionSettings.parseSupportedTypes(it)
                    )
                )
            }
        }
    }
}

private fun CodeEngineSessionSettings.parseSupportedTypes(engine:String):Set<String>{
    return HashSet<String>().also { hashSet ->
        val iterator = SettingsBegin()
        while(!iterator.Equals(SettingsEnd())){
            val subKeys = iterator.GetKey().split(".")
            // Search settings like "barcode.QR_CODE.enabled"
            if(subKeys.size==3 && subKeys[0]==engine && subKeys[2]=="enabled"){
                //Log.e(TAG,"   ===   $subKeys ${iterator.GetValue()}")
                hashSet.add(subKeys[1])
            }
            iterator.Advance()
        }
    }
}
