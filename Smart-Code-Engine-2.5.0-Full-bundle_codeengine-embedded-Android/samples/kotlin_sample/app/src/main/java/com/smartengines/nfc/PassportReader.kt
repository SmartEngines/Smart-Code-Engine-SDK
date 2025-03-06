/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.nfc

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.nfc.tech.IsoDep
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.jmrtd.BACKey

private const val TAG = "myapp.PassportReader"

/**
 * PASSPORT READING PROCESS IMPLEMENTATION
 */
class PassportReader(
    var readingEngine: ReadingEngine = ReadingEngineScuba()
){

    // STATE
    private  val _stateFlow : MutableStateFlow<PassportReaderState> = MutableStateFlow(
        PassportReaderState.Disabled
    )
    val  stateFlow : StateFlow<PassportReaderState>
        get()  = _stateFlow

    val nfcEnabled : Boolean
        get() = stateFlow.value in setOf(PassportReaderState.Waiting, PassportReaderState.Reading)

    fun changeReadingEngine(newReadingEngine: ReadingEngine){
        Log.w(TAG,"changeReadingEngine $newReadingEngine")
        readingEngine = newReadingEngine
    }

    fun setNotSupported() {
        _stateFlow.value = PassportReaderState.NotSupported
    }
    fun activate(){
        Log.d(TAG,"activate")
        if(!nfcEnabled)
            _stateFlow.value = PassportReaderState.Waiting
    }
    fun reset(){
        Log.d(TAG,"reset")
        _stateFlow.value = PassportReaderState.Disabled
    }

    fun readPassportData(
        context     : Context,
        scope       : CoroutineScope,
        isoDep      : IsoDep,
        passportKey : PassportKey,
        checkChip   : Boolean,
        checkData   : Boolean
    ){
        scope.launch {
            withContext(Dispatchers.IO){
                try {
                    // Update state
                    _stateFlow.emit(PassportReaderState.Reading)
                    // Open the engine
                    val bacKey = with(passportKey){BACKey(passportNumber, birthDate, expirationDate)}
                    readingEngine.open(
                        isoDep      = isoDep,
                    )
                    var data = readingEngine.readPassportData(
                        bacKey  = bacKey,
                        context = context)
                    // Do chip verification
                    if(checkChip)
                        data = data.copy(chipAuth = readingEngine.doChipAuth())
                    // Do "passive" data verification
                    if(checkData)
                        data = data.copy(dataAuth = readingEngine.doDataAuth(context))

                    // Update state
                    Log.w(TAG,"Success")
                    _stateFlow.emit(PassportReaderState.Data(data))
                }catch (e:Exception){
                    Log.e(TAG,"readPassportData",e)
                    // Set error state
                    _stateFlow.emit(PassportReaderState.Error(e.toString()))
                }
                readingEngine.close()
            }
        }
    }
}

//--------------------------------------------------------------------------------------------------
// INTEGRATION WITH NfcAdapter and Activity
fun PassportReader.onResumeActivity(activity:Activity) {
    Log.d(TAG, "onResumeActivity nfcEnabled:$nfcEnabled")
    // Check not supported state
    if(stateFlow.value is PassportReaderState.NotSupported) return // nothing to do
    // ENABLE/DISABLE NFC INTENT RECEIVING
    if (!NfcAdapter.enableNfcReceiving(activity, nfcEnabled))
        setNotSupported()
}
fun PassportReader.onNewIntent(intent: Intent) : IsoDep?{
    Log.d(TAG, "onNewIntent intent:$intent")
    if (nfcEnabled) {
        NfcAdapter.getPassportTag(intent)?.let { tag ->
            return IsoDep.get(tag)
        }
    }
    return null
}