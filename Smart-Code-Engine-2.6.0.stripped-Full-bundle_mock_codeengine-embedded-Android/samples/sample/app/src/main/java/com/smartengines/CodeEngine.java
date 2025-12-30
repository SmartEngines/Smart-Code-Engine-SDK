package com.smartengines;

import android.content.Context;
import android.util.Log;
import android.widget.Toast;

import com.smartengines.code.CodeEngineSessionSettings;
import com.smartengines.common.StringsMapIterator;
import com.smartengines.common.StringsSetIterator;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class CodeEngine {
    private static com.smartengines.code.CodeEngine instance;

    public static com.smartengines.code.CodeEngine getInstance(Context context) {
        if (instance == null) {

            // load library
            System.loadLibrary("jnicodeengine");

            try {
                instance = com.smartengines.code.CodeEngine.CreateFromEmbeddedBundle(true);
            } catch (Exception e) {
                Toast t = Toast.makeText(context, e.getMessage(), Toast.LENGTH_LONG);
                t.show();
                Log.e("SMARTENGINES", e.getMessage());
            }
        }
        return instance;
    }

    public static String[] getDocumentsList(Context context) {
        final List<String> scipSettings = new ArrayList<>(Arrays.asList("global"));
        Set<String> engines = new HashSet<>();
        List<String> documents = new ArrayList<>();

        com.smartengines.code.CodeEngine engine = getInstance(context);

        CodeEngineSessionSettings sessionSettings = engine.GetDefaultSessionSettings();

        for (StringsMapIterator mt = sessionSettings.SettingsBegin();
             !mt.Equals(sessionSettings.SettingsEnd()); mt.Advance()) {
            String setting = mt.GetKey();
            String doctype = Arrays.asList(setting.split("\\.")).get(0); // to get "type" from "type.smth.enabled" setting
            if (!scipSettings.contains(doctype)) {
                if (!engines.contains(doctype) && (setting.split("\\.").length == 3 ||
                        doctype.equals("mrz"))) {
                    if (doctype.equals("code_text_line")) {
                        String codeTextLineType = setting.split("\\.")[1];
                        documents.add(codeTextLineType);
                        doctype = doctype + "." + codeTextLineType;
                    } else {
                        documents.add(doctype);
                    }

                    if (doctype.equals("barcode")) {
                        documents.add("barcode_session");
                    }

                    engines.add(doctype);
                }

            }
        }

        String[] array = new String[documents.size()];
        documents.toArray(array);

        return array;
    }

}

