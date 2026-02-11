/**
 * Copyright (c) 2012-2021, Smart Engines Ltd
 * All rights reserved.
 * <p>
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * <p>
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * Neither the name of the Smart Engines Ltd nor the names of its
 * contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 * <p>
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package com.smartengines;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

// Store for Engines settings
public class SettingsStore {

    /*
     * ========================================================================
     * ========================== Core methods ==============================
     * ========================================================================
     */

    public static Map<String, String> options = new HashMap<>();
    public static ArrayList<String> currentMask;
    public static String signature = null;
    public static Boolean isRoi = false;
    private static final Set<String> roiArray = new HashSet<String>(){{
        add("iban");
        add("inn");
        add("kpp");
        add("phone_number");
        add("card_number");
        add("rcbic");
        add("rus_bank_account");
        add("payment_details");
    }};

    // We use ArrayList due react-native supported data structure
    public static void SetMask(ArrayList<String> mask) {
        currentMask = mask;
        if (currentMask.size() == 1) {
            isRoi = roiArray.contains(mask.get(0));
        }
    }

    public static void SetSignature(String sign) {
        signature = sign;
    }

    public static void SetOptions(Map<String, String> map) {
        options = map;
    }

    /*
     * ========================================================================
     * ======================== Custom methods ==============================
     * ========================================================================
     */

    public static Map<String, Integer> cropCoords = new HashMap<>();

}
