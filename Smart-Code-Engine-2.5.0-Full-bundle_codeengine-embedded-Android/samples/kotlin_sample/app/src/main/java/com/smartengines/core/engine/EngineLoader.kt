/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine

import android.content.Context
import android.content.res.AssetManager
import android.util.Log
import com.smartengines.core.engine.common.Utils
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.io.File
import java.io.InputStream

private const val TAG = "engine.Engine"

/**
 * ENGINE LOADER
 * Implements engine loading process
 * @param engine engine-specific Engine interface implementation
 */
class EngineLoader(
    private val engine : Engine
) {

    // Loading state
    private val _loadingState = MutableStateFlow<EngineLoadingState>(EngineLoadingState.Unloaded)
    val loadingState = _loadingState.asStateFlow()

    // Coroutine scope
    private val scope : CoroutineScope = CoroutineScope(Dispatchers.IO)

    /**
     *  LOAD JNI-LIBRARY + CREATE ENGINE
     *  @param jniLibrary jni-library name
     *  @param bundle bundle to load
     *  @param onLoaded a handler to run after the engine is loaded
     */
    fun load(
        context: Context,
        jniLibrary : String,
        bundle     : EngineBundle,
        onLoaded   : suspend (Engine)->Unit
    ){
        Log.d(TAG,"load, jniLibrary: $jniLibrary  bundle: $bundle")

        scope.launch {
            try {
                _loadingState.emit(EngineLoadingState.Loading)
                val timeStart = System.currentTimeMillis()

                // 1. LOAD LIBRARY
                System.loadLibrary(jniLibrary)

                // 2. LOAD BUNDLE
                var buffer:ByteArray? = when(bundle){

                    is EngineBundle.File -> readAssetsFile(context, bundle.filePath)

                    is EngineBundle.FirstFound ->{
                        // SEARCH THE BUNDLE FILE in assets
                        val file = context.assets.list(bundle.dirToSearch)?.find {
                            it.endsWith(bundle.fileExtension) }
                        if(file==null)
                            throw Exception("bundle file not found, dir: \"assets/${bundle.dirToSearch}\" file extension: \"${bundle.fileExtension}\"")
                        readAssetsFile(context, bundle.dirToSearch + File.separator + file)
                    }

                    EngineBundle.Embedded -> null
                }

                buffer?.let {
                    Log.d(TAG, "bundle data is loaded (size:${it.size / 1_000_000}Mb)")
                }

                // CREATE ENGINE
                engine.createEngine(buffer)
                Log.d(TAG, "engine is created")

                // Do additional initialization
                onLoaded(engine)

                // Update state
                _loadingState.emit(EngineLoadingState.Loaded(
                    engine      = engine,
                    loadingTime = System.currentTimeMillis() - timeStart)
                )
            }catch (error:Throwable){
                Log.e(TAG,"engine loading error",error)
                _loadingState.emit(EngineLoadingState.Error(error))
            }
        }
    }
    private fun readAssetsFile(context: Context, filePath:String):ByteArray{
        val stream: InputStream = context.assets.open(
            filePath,
            AssetManager.ACCESS_STREAMING
        )
        return Utils.readFromStream(stream)
    }
}
