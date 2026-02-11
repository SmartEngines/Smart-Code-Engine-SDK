/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Rect;
import android.os.Bundle;
import android.util.Log;
import android.util.Rational;
import android.util.Size;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.AspectRatio;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.Preview;
import androidx.camera.core.UseCaseGroup;
import androidx.camera.core.ViewPort;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.camera.core.resolutionselector.ResolutionStrategy;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.databinding.DataBindingUtil;

import com.google.common.util.concurrent.ListenableFuture;
import com.smartengines.code.CodeEngineFeedbackContainer;
import com.smartengines.code.CodeEngineResult;
import com.smartengines.common.Image;
import com.smartengines.common.Rectangle;
import com.smartengines.common.YUVDimensions;
import com.smartengines.common.YUVType;
import com.smartengines.databinding.ActivityCameraBinding;

import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

/**
 * Main sample activity for documents recognition with Smart ID Engine Android SDK
 */
public class CameraActivity extends AppCompatActivity implements CodeCallback, VisualizationCallback{

    private final int REQUEST_CAMERA_PERMISSION = 1;
    private boolean init_once = true;
    private int imageRotationDegrees = 0;
    private final CodeSession CodeSession = new CodeSession();
    private Button button;
    public static boolean pauseAnalysis = true;

    private CodeDraw draw;

    // Best image frame section
    public static final boolean isBestImageFrameEnabled = true;
    public static @NonNull String bestImageFrame = "";
    public static Map<String, Double> frameImageTemplatesInfo = new HashMap<>();

    private ListenableFuture<ProcessCameraProvider> cameraProviderFuture;
    PreviewView cameraView;
    Executor executor;
    ActivityCameraBinding binding;
    RelativeLayout drawing;
    Context mContext;
    static int height;
    static int width;
    static Rectangle crop_rect;
    static int rotationTimes = 0;
    private double startTime;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = DataBindingUtil.setContentView(this, R.layout.activity_camera);
        cameraView = binding.cameraView;

        // Bind to UI DRAW class
        draw = new CodeDraw(this.getBaseContext());
        drawing = binding.drawing;
        drawing.addView(draw);

        // Disable Viewport by default
        binding.viewport.setVisibility(View.INVISIBLE);

        mContext = this.getBaseContext();

        button = binding.start;
        button.setVisibility(View.INVISIBLE);
        button.setEnabled(false);

        // Bind label object to xml
        binding.setLabel(Label.getInstance());

        button.setOnClickListener(v -> {
            if (pauseAnalysis) {
                started();
                pauseAnalysis = false;
            } else {
                stopped();
                pauseAnalysis = true;
            }
        });

        CodeSession.initSession(this, this, this);

        if (permission(Manifest.permission.CAMERA))
            request(Manifest.permission.CAMERA, REQUEST_CAMERA_PERMISSION);

        executor = Executors.newSingleThreadExecutor();

        binding.main.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                binding.main.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                initCamera();
            }
        });
    }

    private void initCamera() {
        if (SettingsStore.isRoi) {
            /** ROI - region of interest.
             * 1. Set size of viewport hole
             * 2. Set crop in CameraX below
             * Image size for phone and card numbers must be 2/1 ratio!
              */
            binding.viewport.setVisibility(View.VISIBLE);
            Viewport.setRoiRectSize(cameraView.getWidth());
        }

        cameraProviderFuture = ProcessCameraProvider.getInstance(this);
        cameraProviderFuture.addListener(() -> {
            try {
                ProcessCameraProvider cameraProvider = cameraProviderFuture.get();
                bindPreview(cameraProvider);
            } catch (ExecutionException | InterruptedException e) {
                // No errors need to be handled for this Future.
                // This should never be reached.
            }
        }, ContextCompat.getMainExecutor(this));
    }

    private static byte[] getByteArrayFromByteBuffer(ByteBuffer byteBuffer, int rowStride) {

        /** getBuffer() - The stride after the last row may not be mapped into the buffer.
         *  This is why we always calculate the byteBuffer offset.
         *  https://developer.android.com/reference/android/media/Image.Plane#getBuffer()
         */

        int bufferSize = byteBuffer.remaining();
        // The byte array size is stride * height (the leftover spaces will be filled with 0 bytes)
        byte[] bytesArray = new byte[height * rowStride];
        byteBuffer.get(bytesArray, 0, bufferSize);
        return bytesArray;
    }

    void bindPreview(@NonNull ProcessCameraProvider cameraProvider) {

        // "cameraView.getDisplay().getRotation()" some times null object reference error
        int rotation = this.getWindowManager().getDefaultDisplay().getRotation();

        // Preview
        Preview preview = new Preview.Builder().build();

        // Camera
        CameraSelector cameraSelector = new CameraSelector.Builder()
                .requireLensFacing(CameraSelector.LENS_FACING_BACK)
                .build();

        // Set up the image analysis
        ImageAnalysis imageAnalysis = new ImageAnalysis.Builder()
                .setResolutionSelector(
                        new ResolutionSelector.Builder()
                                .setResolutionStrategy(
                                        new ResolutionStrategy(new Size(1200, 720), ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER)
                                ).build())
                .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_YUV_420_888)
                .setTargetRotation(rotation)
                .build();

        // ViewPort
		ViewPort viewPort = ((PreviewView)findViewById(R.id.cameraView)).getViewPort();

        // Use case
        UseCaseGroup useCaseGroup = new UseCaseGroup.Builder()
                .addUseCase(preview)
                .addUseCase(imageAnalysis)
                .setViewPort(viewPort)
                .build();

        imageAnalysis.setAnalyzer(executor, image -> {
            // If image analysis is in paused state
            if (pauseAnalysis) {
                image.close();
                return;
            }
            //  initialized only once:
            if (init_once) {
                // Get sensor orientation
                imageRotationDegrees = image.getImageInfo().getRotationDegrees();
                // Calculate rotation image counts
                rotationTimes = imageRotationDegrees / 90;
                // Reset BestImageFrame vars
                bestImageFrame = "";
                frameImageTemplatesInfo.clear();
                // Cropping rectangle
                Rect crop = image.getCropRect();

                // Rotate crop rectangle if needed
                if (imageRotationDegrees == 0 || imageRotationDegrees == 180) {
                    // If smartphone in landscape - NOT TESTED

                    // width = image.getWidth(); // ~1280
                    // height = image.getHeight(); // ~960
                    // // Set scale for canvas drawing
                    // int heightPreview = binding.cameraView.getWidth();
                    // IdDraw.scale = (float) heightPreview / (float) height;
                    // // Calculate crop rectangle
                    // crop_rect = new Rectangle(crop.left, crop.top, crop.right - crop.left, crop.bottom);
                } else {
                    width = image.getWidth(); // ~1280
                    height = image.getHeight(); // ~960

                    // Set scale for canvas drawing
                    int heightPreview = cameraView.getHeight();
                    CodeDraw.scale = (float) heightPreview / (float) width;
                    // Reset points offset.
                    CodeDraw.translate_x = 0;
                    CodeDraw.translate_y = 0;

					// Calculate crop rectangle
					int c_height = crop.bottom - crop.top;
					int c_width = crop.right - crop.left;

					/**
					* Rectangle:
					* int x, X-coordinate of the top-left corner
					* int y, Y-coordinate of the top-left corner
					* int width, Width of the rectangle
					* int height, Height of the rectangle
					*/

					crop_rect = new Rectangle(crop.top, crop.left, c_height, c_width);

                    if (SettingsStore.isRoi) {
                        // get crop roi rectangle
                        crop_rect = Viewport.getCropRoiRectangle(width, height, crop_rect.getWidth());
                        // Set points offset
                        CodeDraw.translate_x = Viewport.ViewRoiRect.left;
                        CodeDraw.translate_y = Viewport.ViewRoiRect.top;
                    }
                }
                init_once = false;
            }

            CodeEngineResult result;

            // Try recognition
            try {

                /**
                 * Example for OUTPUT_IMAGE_FORMAT_YUV_420_888
                 * According to our tests RGBA_8888 has ~45ms overhead per frame (tested on Helio G90T)
                 * https://developer.android.com/reference/android/graphics/ImageFormat#YUV_420_888
                 */

                ImageProxy.PlaneProxy planeY = image.getPlanes()[0];
                ImageProxy.PlaneProxy planeU = image.getPlanes()[1];
                ImageProxy.PlaneProxy planeV = image.getPlanes()[2];

                YUVDimensions yuvDimensions = new YUVDimensions(
                        planeY.getPixelStride(), planeY.getRowStride(),
                        planeU.getPixelStride(), planeU.getRowStride(),
                        planeV.getPixelStride(), planeV.getRowStride(),
                        width, height, YUVType.YUVTYPE_420_888);

                Image frame = Image.FromYUV(
                        getByteArrayFromByteBuffer(planeY.getBuffer(), planeY.getRowStride()),
                        getByteArrayFromByteBuffer(planeU.getBuffer(), planeU.getRowStride()),
                        getByteArrayFromByteBuffer(planeV.getBuffer(), planeV.getRowStride()),
                        yuvDimensions);

                /** Example for OUTPUT_IMAGE_FORMAT_RGBA_8888
                 *
                 *  ImageProxy.PlaneProxy planeRGBA = image.getPlanes()[0];
                 *  int stride = planeRGBA.getRowStride();
                 *
                 *  ByteBuffer bufferRGBA = planeRGBA.getBuffer();
                 *  byte[] frame_bytes = new byte[bufferRGBA.remaining()];
                 *  bufferRGBA.get(frame_bytes);
                 *  Image frame = Image.FromBufferExtended(frame_bytes, height, width, stride, ImagePixelFormat.IPF_RGBA, 1);
                 */

                // String base64_test_string = frame.GetBase64String().GetCStr();
                frame.Rotate90(rotationTimes);
                //String base64_test_string2 = frame.GetBase64String().GetCStr();

                /** According to our tests without cropping frame (W=546 H=1088) for image (W=1088 H=1088)
                 * the recognition speed decreases by ~125ms per frame (tested on Helio G90T)
                 */

                frame.Crop(crop_rect);
                // String base64_test_string3 = frame.GetBase64String().GetCStr();
                result = CodeSession.session.Process(frame);


            } catch (Exception e) {
                error(e.getMessage());
                finish();
                return;
            }

            if (result.IsTerminal()) {
                // The result is terminal when the engine decides that the recognition result
                // has had enough information and ready to produce result, or when the session
                // is timed out
                Log.d("SMARTENGINES", "ENGINE TERMINATED...");

                // This will stop data from streaming
                imageAnalysis.clearAnalyzer();

                runOnUiThread(() -> {

                    /* Getting intermediate results during the recognition session:
                     * // For native not implemented
                     *
                     * // for flutter
                     * IdEngineModulePlugin.streamRecognized(result);
                     *
                     * // for react-native
                     * IdEngineReactModule.streamRecognized(result);
                     */

                    recognized(result);
                    CodeSession.session.Reset();
                });
            }
            image.close();
        });

        cameraProvider.unbindAll();
        cameraProvider.bindToLifecycle(this, cameraSelector, useCaseGroup);
        preview.setSurfaceProvider(cameraView.getSurfaceProvider());
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////

    void toast(final String message) {

        runOnUiThread(() -> {
            Toast t = Toast.makeText(getApplicationContext(), message, Toast.LENGTH_LONG);
            t.show();
        });
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////

    public boolean permission(String permission) {
        int result = ContextCompat.checkSelfPermission(this, permission);
        return result != PackageManager.PERMISSION_GRANTED;
    }

    public void request(String permission, int request_code) {
        ActivityCompat.requestPermissions(this, new String[]{permission}, request_code);
    }

    @Override
    public void onRequestPermissionsResult(
            int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case REQUEST_CAMERA_PERMISSION: {
                boolean granted = false;
                for (int grantResult : grantResults) {
                    if (grantResult == PackageManager.PERMISSION_GRANTED) { // Permission is granted
                        granted = true;
                    }
                }
                if (granted) {
                    // view.updatePreview();
                } else {
                    error("Please allow Camera permission");
                }
            }
            default: {
                super.onRequestPermissionsResult(requestCode, permissions, grantResults);
            }
        }
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////

    @Override
    public void onDestroy() {
        super.onDestroy();
        // Terminate all outstanding analyzing jobs (if there is any).
    }

    @Override
    public void initialized(boolean engine_initialized) {
        if (engine_initialized) {
            // enable buttons
            button.setEnabled(true);
            button.setVisibility(View.VISIBLE);


            long elapsedTime = System.nanoTime() - CodeSession.startTime;
            long t = TimeUnit.MILLISECONDS.convert(elapsedTime, TimeUnit.NANOSECONDS);
            Label.getInstance().message.set("Engine Ready: " + t + "ms");
        }
    }

    @Override
    public void recognized(CodeEngineResult result) {
        pauseAnalysis = true;
        double elapsedTime = System.nanoTime() - startTime;
        double t = TimeUnit.MILLISECONDS.convert((long) elapsedTime, TimeUnit.NANOSECONDS);

        toast("Time:" + t);
        Log.i("== se_recognized: ==" , ""+ t +"");


        ResultStore.instance.addResult(result);
        Intent intent = new Intent();

        setResult(RESULT_OK, intent);
        finish();
    }

    @Override
    public void started() {
        startTime = System.nanoTime();
        button.setText("STOP");
    }

    @Override
    public void stopped() {
        CodeEngineResult currentResult = CodeSession.session.GetCurrentResult();
        if (currentResult != null) {
            recognized(currentResult);
        } else {
            finish();
        }
    }

    @Override
    public void error(String message) {
        Log.e("SmartEngines", message);
        toast(message);
    }

    @Override
    public void visualizationReceived(CodeEngineFeedbackContainer feedback_container) {
        draw.showCodeMatching(feedback_container);
        draw.invalidate();
    }

    @Override
    public void frameUpdated() {
        draw.invalidate();
    }

    @Override
    public void onBackPressed() {
        pauseAnalysis = true;
        super.onBackPressed();
    }
}
