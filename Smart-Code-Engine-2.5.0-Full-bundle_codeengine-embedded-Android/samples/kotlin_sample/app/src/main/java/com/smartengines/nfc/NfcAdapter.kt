/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.nfc

import android.app.PendingIntent
import android.app.Activity
import android.content.Intent
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.util.Log

private const val TAG = "myapp.NfcActivity"

object NfcAdapter {

    // ENABLE/DISABLE NFC INTENT RECEIVING
    // instead of intent filter in manifest
    // returns false if NFC is not supported by device!
    fun enableNfcReceiving(activity: Activity, enable:Boolean) : Boolean {
        NfcAdapter.getDefaultAdapter(activity)?.let { adapter ->
            if (enable) {
                Log.d(TAG, "enableNfcReceiving")
                val intent = Intent(activity.applicationContext, activity.javaClass)
                intent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
                val pendingIntent =
                    PendingIntent.getActivity(activity, 0, intent, PendingIntent.FLAG_MUTABLE)
                val filter = arrayOf(arrayOf("android.nfc.tech.IsoDep"))
                adapter.enableForegroundDispatch(activity, pendingIntent, null, filter)
            } else {
                Log.d(TAG, "disableNfcReceiving")
                adapter.disableForegroundDispatch(activity)
            }
            return true
        }
        return false
    }

    fun getPassportTag(intent: Intent):Tag? {
        Log.w(TAG, "getPassportTag $intent")
        if (NfcAdapter.ACTION_TECH_DISCOVERED == intent.action) {
            val tag: Tag? = intent.extras?.getParcelable(NfcAdapter.EXTRA_TAG)
            if (tag?.techList?.contains("android.nfc.tech.IsoDep") == true) {
                return tag
            }
        }
        return null
    }
}