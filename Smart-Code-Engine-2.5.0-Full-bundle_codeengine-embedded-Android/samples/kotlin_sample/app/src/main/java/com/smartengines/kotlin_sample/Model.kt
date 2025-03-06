package com.smartengines.kotlin_sample

import android.content.Context
import android.nfc.tech.IsoDep
import android.util.Log
import com.smartengines.core.engine.Engine
import com.smartengines.core.engine.EngineLoader
import com.smartengines.core.engine.EngineLoadingState
import com.smartengines.core.engine.ImageProcessor
import com.smartengines.kotlin_sample.targets.TargetList
import com.smartengines.nfc.PassportKey
import com.smartengines.nfc.PassportReader
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers

/**
 * The sample application specific Model
 */
object Model {
    private const val TAG = "myapp.Model"
    // --------------------------------- DATA ------------------------------------------------------
    // 1. ENGINE LOADER
    val engineLoader = EngineLoader(
        engine  = AppFactory.createEngineWrapper(
            "INSERT SIGNATURE FROM README.html\"
        )
    )

    // Engine access
    val engine: Engine
        get() = (engineLoader.loadingState.value as EngineLoadingState.Loaded).engine


    // 2. TARGET LIST
    val targetList = TargetList()

    // 3. IMAGE PROCESSOR (with selected target)
    val imageProcessor = ImageProcessor()

    // 4. NFC/RFID PASSPORT READER
    val passportReader = PassportReader()
    private var passportKey : PassportKey? = null
        private set

    fun setPassportKey(newPassportKey : PassportKey?){
        passportReader.reset()
        passportKey = newPassportKey
    }

    fun onPassportTagDetected(isoDep: IsoDep, context: Context) {
        passportKey?.let {
            passportReader.readPassportData(
                context = context,
                scope = CoroutineScope(Dispatchers.IO),
                isoDep = isoDep,
                passportKey = it,
                checkChip = false,
                checkData = false
            )
        }?:run{ Log.e(TAG, "passportKey is null")}
    }

    // ---------------------------------------------------------------------------------------
    fun init(context: Context){
        // Start engine loading immediately
        engineLoader.load(
            context,
            jniLibrary = AppFactory.jniLibrary,
            bundle     = AppFactory.bundle,
        ){
            // Load target list
            targetList.targets.emit(
                AppFactory.loadTargetList(it)
            )
        }
    }
}