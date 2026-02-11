package com.codeengineexample;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.ImageDecoder;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.MediaStore;
import android.util.Log;
import android.util.Pair;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.databinding.DataBindingUtil;

import com.smartengines.CameraActivity;
import com.smartengines.R;
import com.smartengines.ResultStore;
import com.smartengines.SettingsStore;
import com.smartengines.code.CodeEngine;
import com.smartengines.databinding.ActivityExampleBinding;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class ExampleActivity extends AppCompatActivity {

    Context context;
    public TextView resultTextField;
    ExampleUpload exampleUpload = new ExampleUpload();

    ListView listView;
    ExampleResultAdapter adapter;
    ActivityExampleBinding binding;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = DataBindingUtil.setContentView(this, R.layout.activity_example);
        context = getBaseContext();

        listView = binding.list;
        resultTextField = binding.resultInfo;
        ImageButton selector = binding.selector;
        Button selectUpload = binding.gallery;
        Button selectCamera = binding.buttonCamera;
        TextView version = binding.version;

        // ListView
        adapter = new ExampleResultAdapter(context);
        listView.setAdapter(adapter);

        CodeEngine engine = com.smartengines.CodeEngine.getInstance(context);
        version.setText("Version: " + engine.GetVersion());

        selectCamera.setOnClickListener(v -> openCamera());
        selector.setOnClickListener(v -> openSelector());
        selectUpload.setOnClickListener(v -> mUploadActivity.launch("image/*"));
        initSESettings();
    }

    private void initSESettings() {
        String signature = "INSERT_SIGNATURE_HERE from doc\README.html\";
        SettingsStore.SetSignature(signature);

        // mask
        String[] mask = {"barcode"};
        ArrayList<String> strList = new ArrayList<>(Arrays.asList(mask));
        SettingsStore.SetMask(strList);

        // options
        Map<String, String> options = new HashMap();
        options.put("global.enableMultiThreading", "true");

        SettingsStore.SetOptions(options);
    }

    ActivityResultLauncher<String> mUploadActivity = registerForActivityResult(new ActivityResultContracts.GetContent(),
            uri -> {
                adapter.clear();
                if (uri == null) {
                    return;
                }

                try {
                    // Get bitmap from file
                    Bitmap gallery_file;

                    if (Build.VERSION.SDK_INT >=29 ) {
                        gallery_file = ImageDecoder.decodeBitmap(ImageDecoder.createSource(context.getContentResolver(), uri), (imageDecoder, imageInfo, source1) -> imageDecoder.setMutableRequired(true));

                    } else {
                        gallery_file = MediaStore.Images.Media.getBitmap(context.getContentResolver(), uri);
                    }

                    try {
                        resultTextField.setText("Recognizing...");

                        ExecutorService executor = Executors.newSingleThreadExecutor();
                        Handler handler = new Handler(Looper.getMainLooper());

                        executor.execute(() -> {
                            try {
                                exampleUpload.getResultFromGallery(context, gallery_file);
                            } catch (Exception e) {
                                Log.e("SMARTENGINES", e.getMessage());
                                handler.post(() -> {
                                    String err = (e.getMessage().length() >= 800) ? e.getMessage().substring(0, 800) : e.getMessage();
                                    Toast t = Toast.makeText(getApplicationContext(), err, Toast.LENGTH_LONG);
                                    t.show();
                                    Log.e("SMARTENGINES", err);
                                    resultTextField.setText("Exception");
                                });
                            }

                            handler.post(this::renderResult);
                        });
                    } catch (Exception e) {
                        Log.d("SMARTENGINES", e.getMessage());
                    }
                } catch (IOException e) {
                    resultTextField.setText(e.getMessage());
                    e.printStackTrace();
                }
            });

    private void openCamera() {

        // reset state of UI
        resultTextField.setText("");
        // Reset items in result adapter
        if (adapter != null) {
            adapter.clear();
        }

        Intent intent;
        intent = new Intent(getApplicationContext(), CameraActivity.class);
        mStartCameraActivity.launch(intent);
    }
    // Document camera activity
    ActivityResultLauncher<Intent> mStartCameraActivity = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            result -> {
                if (result.getResultCode() == Activity.RESULT_OK) {
                    renderResult();
                }
            });

    public void renderResult() {
        // Get data from store
        Map<String, Map<String, ResultStore.FieldInfo>> codeObjects = ResultStore.instance.getFields();

        // Get docType
        String docType = ResultStore.instance.getType();

        // Check if document found
        if (docType.isEmpty()) {
            docType = "Document not found";
            resultTextField.setText(docType);
            return;
        }

        // Add first section to result view
        adapter = new ExampleResultAdapter(context);

        for (Map.Entry<String, Map<String, ResultStore.FieldInfo>> object : codeObjects.entrySet()) {
            adapter.addItem(object.getKey(), "section");
            // Put fields ti result
            for (Map.Entry<String, ResultStore.FieldInfo> set : object.getValue().entrySet()) {
                Pair<String, ResultStore.FieldInfo> tempMap = new Pair(set.getKey(), set.getValue());
                adapter.addItem(tempMap, "field");
            }

        }


        listView.setAdapter(adapter);

        resultTextField.setText(docType);
    }
    // Select document type
    private void openSelector() {
        final String[] documents = com.smartengines.CodeEngine.getDocumentsList(context);

        AlertDialog.Builder builder = new AlertDialog.Builder(ExampleActivity.this);
        builder.setTitle("Select type");
        builder.setItems(documents, (dialog, item) -> {

            String doctype = documents[item];
            resultTextField.setText(doctype);
            ArrayList<String> mask_from_menu = new ArrayList<>(Arrays.asList(doctype));
            SettingsStore.SetMask(mask_from_menu);
        });

        builder.setCancelable(true);
        AlertDialog alert = builder.create();
        alert.show();
    }


}