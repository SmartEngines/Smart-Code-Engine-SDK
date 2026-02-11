package com.codeengineexample;

import android.content.Context;
import android.graphics.Bitmap;

import com.smartengines.CodeEngine;
import com.smartengines.Label;
import com.smartengines.ResultStore;
import com.smartengines.SettingsStore;
import com.smartengines.code.BarcodePreset;
import com.smartengines.code.CodeEngineResult;
import com.smartengines.code.CodeEngineSession;
import com.smartengines.code.CodeEngineSessionSettings;
import com.smartengines.code.EngineSettingsGroup;
import com.smartengines.code.jnicodeengine;
import com.smartengines.common.Image;
import com.smartengines.common.ImagePixelFormat;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class ExampleUpload {
    private static final Set<String> codeTextLineArray = new HashSet<String>(){{
        add("iban");
        add("inn");
        add("kpp");
        add("phone_number");
        add("card_number");
        add("rcbic");
        add("rus_bank_account");
    }};
    public void getResultFromGallery(final Context context, Bitmap imageData) {
        try {
            Label.getInstance().message.set("Wait...");
            // 1. Get engine instance
            com.smartengines.code.CodeEngine engine = CodeEngine.getInstance(context);
            // 2. Create new session settings object
            CodeEngineSessionSettings sessionSettings = engine.GetDefaultSessionSettings();
//            // 2.1 Set forensics
//            if (SettingsStore.isForensics) {
//                sessionSettings.EnableForensics();
//            }
            // 2.2 Set document type
            ArrayList<String> docArray = SettingsStore.currentMask;
            for (String name : docArray) {
                if (name.equals("bank_card")) {
                    String engine_name = jnicodeengine.toString(EngineSettingsGroup.Card);
                    // Setting option to enable bank card recognition
                    sessionSettings.SetOption(engine_name + ".enabled", "true");
                    // Setting option to enable concrete bank card recognition: embossed, indent, freeform
                    // more information in README
                    sessionSettings.SetOption(engine_name + ".embossed.enabled", "true");
                }
                if (name.equals("barcode") || name.equals("barcode_session")) {
                    String engine_name = jnicodeengine.toString(EngineSettingsGroup.Barcode);
                    // Setting option to enable barcode recognition
                    sessionSettings.SetOption(engine_name + ".enabled", "true");
                    // Setting option to enable all barcode symbologies recognition
                    // more information in README
                    sessionSettings.SetOption(engine_name + ".COMMON.enabled", "true");
                    // Setting option to enable processing AAMVA preset
                    sessionSettings.SetOption(engine_name + ".preset", jnicodeengine.presetToString(BarcodePreset.AAMVA));
                    // Setting option of scenarios for barcode recognition
                    // more information in README
                    sessionSettings.SetOption(engine_name + ".roiDetectionMode", "anywhere");
                }
                if (codeTextLineArray.contains(name)) {
                    String engine_name = jnicodeengine.toString(EngineSettingsGroup.CodeTextLine);
                    // Setting option to enable code text line recognition
                    sessionSettings.SetOption(engine_name + ".enabled", "true");
                    // Setting option to enable one of codeTextLineArray type recognition
                    sessionSettings.SetOption(engine_name + "." + name + ".enabled", "true");
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
            // 2.3 Set custom options
            Map<String, String> map = SettingsStore.options;
            for (Map.Entry<String, String> entry : map.entrySet()) {
                String key = entry.getKey();
                String value = entry.getValue();
                sessionSettings.SetOption(key, value);
            }
            // 3. Spawn recognition session
            CodeEngineSession session = engine.SpawnSession(sessionSettings, SettingsStore.signature);

            // Prepare for FromBufferExtended()
            byte[] bytes = bitmapToByteArray(imageData);
            int stride = imageData.getRowBytes();
            int height = imageData.getHeight();
            int width = imageData.getWidth();

            // Bitmap.getConfig() return ARGB_8888 pixel format. The channel order of ARGB_8888 is RGBA!
            Image se_image = Image.FromBufferExtended(bytes, width, height, stride, ImagePixelFormat.IPF_RGBA, 1);
            CodeEngineResult finalResult = session.Process(se_image);
            ResultStore.instance.addResult(finalResult);
            // 4. Reset session
            session.Reset();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public byte[] bitmapToByteArray(Bitmap bitmap) {
        ByteBuffer byteBuffer = ByteBuffer.allocate(bitmap.getByteCount());
        bitmap.copyPixelsToBuffer(byteBuffer);
        byteBuffer.rewind();
        return byteBuffer.array();
    }
}
