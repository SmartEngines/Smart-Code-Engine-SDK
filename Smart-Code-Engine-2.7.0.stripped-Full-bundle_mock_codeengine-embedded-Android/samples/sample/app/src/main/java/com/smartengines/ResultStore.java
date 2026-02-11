/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines;

import android.util.Base64;
import android.util.Log;

import androidx.annotation.NonNull;

import com.smartengines.code.CodeEngineResult;
import com.smartengines.code.CodeField;
import com.smartengines.code.CodeFieldsMapIterator;
import com.smartengines.code.CodeObject;
import com.smartengines.code.CodeObjectsMapIterator;
import com.smartengines.common.StringsMapIterator;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

public class ResultStore {

    /**
     * Document fields
     */
    public static class FieldInfo {

        public final String value;
        public boolean isAccepted;
        public final Map<String, String> attr;

        // Fields, forensics
        FieldInfo(final String value, final boolean accepted, final Map<String, String> attr) {
            this.value = value;
            this.isAccepted = accepted;
            this.attr = attr;
        }

        // Images
        FieldInfo(final String value, final Map<String, String> attr) {
            this.value = value;
            this.attr = attr;
        }
    }


    /*
     * ========================================================================
     * ===================== ResultStore Storage ==========================
     * ========================================================================
     */

    public static final ResultStore instance = new ResultStore();

    private @NonNull String docType = ""; // representation of the returned document type

    private static final Map<String, Map<String, FieldInfo>> codeObjects = new HashMap<>();

    public void addResult(CodeEngineResult result) {

        codeObjects.clear();
        Set<String> docTypes = new HashSet<>();


        docType = "";

        int objectCount = result.GetObjectCount();

        // Get strings results
        for (CodeObjectsMapIterator codeObjectIt = result.ObjectsBegin();
             !codeObjectIt.Equals(result.ObjectsEnd());
             codeObjectIt.Advance()) {

            Map<String, FieldInfo> fields = new HashMap<>();

            String codeObjectname = codeObjectIt.GetKey();
            CodeObject codeObject = codeObjectIt.GetValue();
            docTypes.add(codeObject.GetTypeStr());

            Map<String, String> attr = new HashMap<>();
            for (StringsMapIterator attrIt = codeObject.AttributesBegin();
                 !attrIt.Equals(codeObject.AttributesEnd());
                 attrIt.Advance()) {
                attr.put(attrIt.GetKey(), attrIt.GetValue());
            }

            for (CodeFieldsMapIterator codeObjectFieldIt = codeObject.FieldsBegin();
                 !codeObjectFieldIt.Equals(codeObject.FieldsEnd());
                 codeObjectFieldIt.Advance()){
                CodeField codeField = codeObjectFieldIt.GetValue();

                String value = codeField.GetBinaryRepresentation().GetBase64String().GetCStr();

                if (codeField.HasOcrStringRepresentation()) {
                    value = codeField.GetOcrString().GetFirstString().GetCStr();
                }

                fields.put(codeField.Name(), new FieldInfo(value, codeField.IsAccepted(), attr));
            }
            codeObjects.put(codeObjectname, fields);

        }

        docType = String.join(", ", docTypes);
    }

    public Map<String, Map<String, FieldInfo>> getFields() {
        return codeObjects;
    }

    public String getType() {
        return docType;
    }

    // Decode base64 and save to local folder. JSON file will become much lighter.
    // React Native passes the json file from the native part with the images encoded
    // in base64 for quite a long time. Flutter doesn't have this problem.
    // Visually it works faster with base64 images. Tested on Mediatek Helio G95

    private String getUriAfterImageSave(String base64, String prefix) {
        // image name
        String filename = prefix + "-" + UUID.randomUUID().toString();
        String str = null;

        byte[] dd = Base64.decode(base64, 0);

        try {
            File createTempFile = File.createTempFile(
                    filename,
                    ".jpg",
                    null // if null it become as context.getCacheDir().
            );
            OutputStream fileOutputStream = new FileOutputStream(createTempFile);
            fileOutputStream.write(dd);
            fileOutputStream.close();
            str = createTempFile.getAbsolutePath();

        } catch (IOException e) {
            Log.e("Exception", "File write failed: " + e);
        }
        return str;
    }
}