/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.smartengines.code.CodeEngineSessionSettings;
import com.smartengines.code.EngineSettingsGroup;
import com.smartengines.code.jnicodeengine;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class CodeSession {
    public static CodeEngineSessionSettings sessionSettings;
    public static com.smartengines.code.CodeEngineSession session;

    public static CodeWorkflowFeedBack workflowFeedBack;
    public static CodeVisualizationFeedBack visualizationFeedBack;

    public boolean isRoi;
    public static long startTime;

    private static final Set<String> codeTextLineArray = new HashSet<String>(){{
        add("iban");
        add("inn");
        add("kpp");
        add("phone_number");
        add("card_number");
        add("rcbic");
        add("rus_bank_account");
    }};

    public void initSession(Context context, CodeCallback callback, VisualizationCallback visualizationCallback) {

        ExecutorService SessionExecutor = Executors.newSingleThreadExecutor();
        Handler handler = new Handler(Looper.getMainLooper());

        SessionExecutor.execute(() -> {
            try {
                Label.getInstance().message.set("Wait...");

                // Benchmark
                startTime = System.nanoTime();

                // 1. Get engine instance
                com.smartengines.code.CodeEngine engine = CodeEngine.getInstance(context);
                // 2. Create new session settings object
                sessionSettings = engine.GetDefaultSessionSettings();

                // 2.1 Set document mask
                ArrayList<String> docArray = SettingsStore.currentMask;
                isRoi = false;

                for (String name : docArray) {

                    String global_name = jnicodeengine.toString(EngineSettingsGroup.Global);
                    // Setting option to forcely terminate when 5 seconds pass
                    sessionSettings.SetOption(global_name + ".sessionTimeout", "5.0");
                    if (name.equals("bank_card")) {
                        String engine_name = jnicodeengine.toString(EngineSettingsGroup.Card);
                        // Setting option to enable bank card recognition
                        sessionSettings.SetOption(engine_name  + ".enabled", "true");
                        // Setting option to enable concrete bank card recognition: embossed, indent, freeform
                        // more information in README
                        sessionSettings.SetOption(engine_name + ".embossed.enabled", "true");
                    }
                    if (name.equals("barcode")) {
                        String engine_name = jnicodeengine.toString(EngineSettingsGroup.Barcode);
                        // Setting option to enable barcode recognition
                        sessionSettings.SetOption(engine_name + ".enabled", "true");
                        // Setting option to enable all barcode symbologies recognition
                        // more information in README
                        sessionSettings.SetOption(engine_name + ".COMMON.enabled", "true");
                        // Setting option to receive no more than 5 objects
                        sessionSettings.SetOption(engine_name + ".maxAllowedCodes", "5");
                        // Setting option to terminate after first frame with recognized barcode
                        sessionSettings.SetOption(engine_name + ".feedMode", "single");
                        // Setting option of scenarios for barcode recognition
                        // more information in README
                        sessionSettings.SetOption(engine_name + ".roiDetectionMode", "focused");
                    }
                    if (name.equals("barcode_session")) {
                        String engine_name = jnicodeengine.toString(EngineSettingsGroup.Barcode);
                        // Setting option to enable barcode recognition
                        sessionSettings.SetOption(engine_name + ".enabled", "true");
                        // Setting option to enable all barcode symbologies recognition
                        // more information in README
                        sessionSettings.SetOption(engine_name + ".COMMON.enabled", "true");
                        // Setting option to receive no more than 50 objects
                        sessionSettings.SetOption(engine_name + ".maxAllowedCodes", "50");
                        // Setting option to not terminate after first frame with recognized barcode
                        sessionSettings.SetOption(engine_name + ".feedMode", "sequence");
                        // Setting option of scenarios for barcode recognition
                        // more information in README
                        sessionSettings.SetOption(engine_name + ".roiDetectionMode", "focused");
                        // Setting option to ignore timeout, stop recognition occurs only by pressing the button
                        sessionSettings.SetOption(global_name + ".sessionTimeout", "0.0");

                    }
                    if (codeTextLineArray.contains(name)) {
                        String engine_name = jnicodeengine.toString(EngineSettingsGroup.CodeTextLine);
                        // Setting option to enable code text line recognition
                        sessionSettings.SetOption(engine_name + ".enabled", "true");
                        // Setting option to enable one of codeTextLineArray type recognition
                        sessionSettings.SetOption(engine_name + "." + name + ".enabled", "true");
                        // Setting option to enable one of codeTextLineArray type recognition
                        isRoi = true;
                    }
                    if (name.equals("mrz")) {
                        String engine_name = jnicodeengine.toString(EngineSettingsGroup.Mrz);
                        // Setting option to enable mrz recognition
                        sessionSettings.SetOption(engine_name + ".enabled", "true");
                    }

                    if (name.equals("payment_details")) {
                        String engine_name = jnicodeengine.toString(EngineSettingsGroup.PaymentDetails);
                        // Setting option to enable payment_details recognition
                        sessionSettings.SetOption(engine_name + ".enabled", "true");
                        sessionSettings.SetOption(engine_name + ".inn.enabled", "true");
                    }
                }
                // 2.2 Set custom options
                Map<String, String> map = SettingsStore.options;
                for (Map.Entry<String, String> entry : map.entrySet()) {
                    String key = entry.getKey();
                    String value = entry.getValue();
                    sessionSettings.SetOption(key, value);
                }

                // 2.3 Create feedbacks
                workflowFeedBack = new CodeWorkflowFeedBack(visualizationCallback);
                visualizationFeedBack = new CodeVisualizationFeedBack(visualizationCallback);

                // 3. Spawn recognition session
                session = engine.SpawnSession(sessionSettings, SettingsStore.signature, workflowFeedBack, visualizationFeedBack);

                handler.post(() -> {
                    callback.initialized(true);
                    Log.d("SMARTENGINES", "SESSION INITIALIZED...");
                });

            } catch (Exception e) {
                Label.getInstance().message.set("Exception");
                handler.post(() -> callback.error("SpawnSession: "+ e.getMessage()));
            }
        });
    }
}
