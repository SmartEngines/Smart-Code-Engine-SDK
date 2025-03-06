/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.core.engine

import android.graphics.Bitmap
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

private const val TAG = "engine.ImageProcessor"

/**
 * IMAGE PROCESSOR
 * Implements the document recognition process from a sequence of images (the main business logic)
 * see ImageProcessingState for implementation details
 */
class ImageProcessor() {
    //----------------------------------------------------------------------------------------------
    // DATA

    // State
    private val _state = MutableStateFlow<ImageProcessingState>( ImageProcessingState.READY )
    private fun setState(newState:ImageProcessingState) {
        Log.w(TAG," >>> state: $newState")
        _state.value = newState
    }
    val state = _state.asStateFlow()

    //----------------------------------------------------------------------------------------------
    // EVENTS
    fun startProcessing(engine : Engine, target: SessionTarget, sessionType: SessionType, photo: Bitmap?){
        Log.w(TAG," ---> startProcessing")
        processingJob = scope.launch {
            process(engine, target, sessionType, photo)
        }
    }

    fun addFrame(frame:Frame){
        scope.launch {
            try {
                Log.w(TAG, " ---> onFrame")
                frameChannel!!.send(frame)
            } catch (e: Exception) {
                frame.close()
            }
        }
    }

    fun stopProcessing(){
        Log.w(TAG," ---> stopProcessing")
        processingJob?.cancel()
    }

    fun onFaceCheckFinished(){
        onFaceCheckCancelled()
    }
    fun onFaceCheckCancelled(){
        state.value.let {
            if( it is ImageProcessingState.SELFIE_CHECKING){
                setState( ImageProcessingState.FINISHED(it.session) )
            }
        }
    }

    fun finish(){
        Log.w(TAG," ---> finish")
        setState( ImageProcessingState.READY )
    }

    //----------------------------------------------------------------------------------------------
    // IMPLEMENTATION

    // Processing "thread"
    private val scope : CoroutineScope = CoroutineScope(Dispatchers.IO)
    private var processingJob : Job? = null
    private var frameChannel : Channel<Frame>?=null // link to the processing coroutine


    private suspend fun process(engine : Engine, target: SessionTarget, sessionType: SessionType, photo: Bitmap?){
        Log.w(TAG,"processing thread started:  ${Thread.currentThread().id} ${Thread.currentThread().name}")
        var session:Session?=null
        try {
            // SET PROCESSING STATE
            setState(
                if(photo!=null) ImageProcessingState.PHOTO_PROCESSING(
                    target = target,
                    visualization = null,
                    photo = photo
                )
                else ImageProcessingState.VIDEO_PROCESSING(
                    target = target,
                    visualization = null,
                )
            )

            // CREATE SESSION
            session = engine.createSession(
                target = target, // must be set
                sessionType
            )

            // Session visualization
            var lastFrameSize = android.util.Size(1,1)
            val visualization = Visualization(
                    quadsPrimary = MutableStateFlow<List<QuadFrame>>(emptyList()).apply {
                        // Subscribe to the session data
                        scope.launch {
                            session.quadsPrimary?.collect{
                                //Log.e(TAG,"================== quadsPrimary collector: $it")
                                emit(value + QuadFrame(
                                    quads = it,
                                    imageSize = lastFrameSize
                                ))
                            }
                        }
                    },
                    quadsSecondary = MutableStateFlow<List<QuadFrame>>(emptyList()).apply {
                        // Subscribe to the session data
                        scope.launch {
                            session.quadsSecondary?.collect{
                                //Log.e(TAG,"================== quadsSecondary collector: $it")
                                emit(value + QuadFrame(
                                    quads = it,
                                    imageSize = lastFrameSize
                                ))
                            }
                        }
                    },
                   instruction   = session.instruction
                )


            // PREPARE CHANNEL Image queue (for the "thread")
            frameChannel = Channel<Frame>(capacity = photo?.let { 1 }?: 0).apply {
                // Fill channel immediately for photo mode
                photo?.let { send( Frame(bitmap = photo, imageProxy = null)) }
            }
            val framesLimit = photo?.let { 1 }?: Int.MAX_VALUE
            var framesProcessed = 0

            // SET PROCESSING STATE
            setState(
                if(photo!=null) ImageProcessingState.PHOTO_PROCESSING(target, visualization, photo)
                else            ImageProcessingState.VIDEO_PROCESSING(target, visualization)
            )

            // THE MAIN LOOP
            while (!session.isTerminal && !session.isSelfieCheckRequired && framesProcessed<framesLimit){

                // Receive the next frame
                val frame = frameChannel!!.receive() // BLOCKING CODE!!!
                framesProcessed++
                lastFrameSize = with(frame.bitmap){android.util.Size(width,height)}
                Log.d(TAG,"frame #$framesProcessed $lastFrameSize is processing...")

                // Prepare Image
                //val image = imageFromBitmap(frame.bitmap)
                val image = frame.bitmap

                // DO PROCESS
                val timeStart  = System.currentTimeMillis()
                session.processImage(image)
                val timeFinish = System.currentTimeMillis()

                // Free resources
                frame.close()

                // TODO Update statistics

                delay(1)// allows coroutine cancellation !

            }

            // SET FINISHED STATE
            setState(
                if(session.isSelfieCheckRequired) ImageProcessingState.SELFIE_CHECKING(session)
                else                              ImageProcessingState.FINISHED(session)
            )

        } catch (e: kotlinx.coroutines.CancellationException) {
            setState(
                if(session!=null) ImageProcessingState.FINISHED(session)
                else ImageProcessingState.READY// session is not created yet
            )
        }catch (e:Exception){
            Log.e(TAG,"image processing",e)
            setState(ImageProcessingState.ERROR(e))
        }

        Log.w(TAG,"processing thread finished: ${Thread.currentThread().id} ${Thread.currentThread().name}")
        processingJob = null
        frameChannel = null
    }
}