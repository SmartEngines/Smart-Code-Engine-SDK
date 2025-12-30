/**
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

// Init recognition engine
function createEngine(SE, MODULE){
  try {
    console.time("Create Engine");
    ENGINE = new SE.CodeEngine(false);
    console.timeEnd("Create Engine");

    readyEmitter({ version: SE.CodeEngineGetVersion() + " / " + MODULE + " / ", doclist: getAvailableDocList(SE, ENGINE) });
  } catch (e) {
    errorEmitter({ message: e, SE });
  }
  return ENGINE;
}

// Used for runtime calculation
let PERFSTART;

// Check if session is activated, and start recognizing if it is
const checkSession = async (spawnedSession, ENGINE_CONFIG) => {
  // Is session already activated? (In case of images from canvas)
  if (spawnedSession.IsActivated()) {
    logEmitter({ message: "✅ Already activated." });
    return;
  }

  // Send request to activation server
  logEmitter({ message: "⏳ Sending activation request..." });
  // Get dynamic key
  const dynKey = spawnedSession.GetActivationRequest();
  // Get response from activation server
  const response = await fetch(ENGINE_CONFIG.activationUrl, {
    method: "POST",
    //mode: 'no-cors', // no-cors, *cors, same-origin
    headers: { "Content-Type": "text/plain" }, // text/plain requests don't trigger a CORS preflight.
    body: JSON.stringify({ action: "activate_id_session", message: dynKey }), //`{"action": "activate_id_session", "message": "${dynKey}" }`,
    signal: AbortSignal.timeout(3000),
  });

  if (!response.ok) {
    let desc = await response.json();
    throw new Error(desc.message);
  }

  const desc = await response.json();
  // Response is ok, activate session
  // spawnedSession.Activate(desc.message);
  self.PERFSTART = performance.now();

  logEmitter({ message: "✉ Activation done. Waiting for recognition..." });
};
// Load image from file pre-loaded in a buffer
function ImageFromRGBbytes(imageData, SE) {
  return new SE.seImage(imageData);
}
// Load image from pixels buffer
function ImageFromRGBAbytes(canvas, SE) {
  const width = canvas.width;
  const height = canvas.height;
  const rawData = canvas.data.buffer;
  const channels = rawData.byteLength / (height * width); // Number of channels
  const stride = channels >= 3 ? rawData.byteLength / height : width; // Stride calculation
  return new SE.seImageFromBuffer(rawData, width, height, stride, channels);
}

// Recognize image from file
async function recognizeFile(data, ENGINE, ENGINE_CONFIG, SE) {
  // 1. Create session
  let spawnedSessionRGB = createRGBSession(SE, ENGINE, ENGINE_CONFIG);
  // 2. Activate session
  await checkSession(spawnedSessionRGB, ENGINE_CONFIG);
  // 3. Create image
  const image = ImageFromRGBbytes(data, SE);
  // 4. Get recognition result
  const result = spawnedSessionRGB.Process(image);

  const resultMessage = resultObject(result);

  // Free the memory!
  image.delete();
  result.delete();
  spawnedSessionRGB.Reset();

  return resultMessage;
}

// Frame processing method
function recognizeFrame(image, spawnedSessionRGBA) {
  // console.log(image.GetBase64String())
  const result = spawnedSessionRGBA.Process(image);

  /* We must feed the system if it still feels image hungry */
  if (!result.IsTerminal()) {
    return { 
      requestType: "FeedMeMore",
      codeObjectQuadrangles: getCodeObjectQuadrangles(result) 
    };
  }

  const resultMessage = resultObject(result);

  image.delete();
  result.delete();
  spawnedSessionRGBA.Reset();

  return resultMessage;
}

// Create session settings and enable recognition engines
function createCodeSessionSettings(SE, ENGINE, selected_engine) {
  let sessionSettings = ENGINE.GetDefaultSessionSettings();

  if (selected_engine == "barcode") {
    console.log("Barcode enabled");
    let engine_name = SE.ToString(SE.EngineSettingsGroup.Barcode);
    console.log(engine_name);
    // Setting option to enable barcode recognition
    sessionSettings.SetOption(engine_name + ".enabled", "true");
    // Setting option to enable all barcode symbologies recognition
    sessionSettings.SetOption(engine_name + ".COMMON.enabled", "true");
    sessionSettings.SetOption(engine_name + ".maxAllowedCodes", "1");
    sessionSettings.SetOption(engine_name + ".roiDetectionMode", "anywhere");
  }

  if (selected_engine == "mrz") {
    console.log("MRZ enabled");
    // Setting option to enable mrz recognition
    let engine_name = SE.ToString(SE.EngineSettingsGroup.Mrz);
    console.log(engine_name);
    sessionSettings.SetOption((engine_name + ".enabled"), "true");
  }

  if (selected_engine == "bank_card") {
    console.log("Bank cards enabled");
    // Setting option to enable bank card recognition
    let engine_name = SE.ToString(SE.EngineSettingsGroup.Card);
    console.log(engine_name);
    sessionSettings.SetOption(engine_name + ".enabled", "true");
  }

  if (selected_engine == "code_text_line") {
    console.log("Code text lines enabled");
    // Setting option to enable code text lines recognition
    let engine_name = SE.ToString(SE.EngineSettingsGroup.CodeTextLine);
    console.log(engine_name);
    sessionSettings.SetOption(engine_name + ".enabled", "true");
    sessionSettings.SetOption(engine_name + ".card_number.enabled", "true");
  }

  if (selected_engine == "payment_details") {
    console.log("Payment details enabled");
    // Setting option to enable payment details recognition
    let engine_name = SE.ToString(SE.EngineSettingsGroup.PaymentDetails);
    console.log(engine_name);
    sessionSettings.SetOption(engine_name + ".enabled", "true");
    sessionSettings.SetOption(engine_name + ".inn.enabled", "true");
  }

  if (selected_engine == "license_plate") {
    console.log("License plates enabled");
    // Setting option to enable licenes plate recognition
    let engine_name = SE.ToString(SE.EngineSettingsGroup.LicensePlate);
    console.log(engine_name);
    sessionSettings.SetOption(engine_name + ".enabled", "true");
    sessionSettings.SetOption(engine_name + ".rus.enabled", "true");
  }

  if (selected_engine == "container_recog") {
    console.log("Container recog enabled");
    // Setting option to enable container recognition
    let engine_name = SE.ToString(SE.EngineSettingsGroup.ContainerRecog);
    console.log(engine_name);
    sessionSettings.SetOption(engine_name + ".enabled", "true");
  }

  return sessionSettings;
}

// Used for image sequence
function createRGBASession(SE, ENGINE, ENGINE_CONFIG) {
  let sessionSettings = createCodeSessionSettings(SE, ENGINE, ENGINE_CONFIG.docTypes);
  sessionSettings.SetOption("global.sessionTimeout", "5.0");
  // images from canvas has RGBA pixel format
  sessionSettings.SetOption("global.rgbPixelFormat", "RGBA");

  spawnedSession = ENGINE.SpawnSession(sessionSettings, ENGINE_CONFIG.signature);

  return spawnedSession;
}

// Used for file
function createRGBSession(SE, ENGINE, ENGINE_CONFIG) {
  let sessionSettings = createCodeSessionSettings(SE, ENGINE, ENGINE_CONFIG.docTypes);
  sessionSettings.SetOption("global.sessionTimeout", "5.0");

  let spawnedSession = ENGINE.SpawnSession(sessionSettings, ENGINE_CONFIG.signature);

  return spawnedSession;
}

// code from wasm-feature-detect.js
const getModuleName = async () => {
  const a = async (e) => {
    try {
      return "undefined" != typeof MessageChannel && new MessageChannel().port1.postMessage(new SharedArrayBuffer(1)), WebAssembly.validate(e);
    } catch (e) {
      return !1;
    }
  };

  const simd = async () => WebAssembly.validate(new Uint8Array([0, 97, 115, 109, 1, 0, 0, 0, 1, 5, 1, 96, 0, 1, 123, 3, 2, 1, 0, 10, 10, 1, 8, 0, 65, 0, 253, 15, 253, 98, 11]));
  const threads = () => a(new Uint8Array([0, 97, 115, 109, 1, 0, 0, 0, 1, 4, 1, 96, 0, 0, 3, 2, 1, 0, 5, 4, 1, 3, 1, 1, 10, 11, 1, 9, 0, 65, 0, 254, 16, 2, 0, 26, 11]));

  const hasSimd = await simd();
  // const hasThreads = await threads();
  const hasThreads = false;

  let module;

  if (hasSimd === true) {
    hasThreads //hasThreads
      ? (module = "simd.threads")
      : (module = "simd.nothreads");
  } else {
    module = "nosimd.nothreads";
  }

  return module;
};

// postMessages for errors for UI thread
const errorEmitter = (data) => {
  // It doesn't look good, but so far it's the only way to get string exceptions from WASM
  if (typeof data.message === "number") {
    try {
      data.message = "❌ " + data.SE.getExceptionMessage(data.message);
    } catch (e) {
      /* empty */
    }
  }
  console.error(data.message);
  // Some worker objects cannot be cloned to UI thread. Delete it.
  delete data["SE"];
  data.type = "error";
  postMessage({ requestType: "eventChannel", data });
};

// Event for ready state
const readyEmitter = (data) => {
  data.type = "ready";
  postMessage({ requestType: "eventChannel", data });
};

// Event for printing messages in log in UI side
const logEmitter = (data) => {
  data.type = "log";
  postMessage({ requestType: "eventChannel", data });
};

// Process runtime calculation
const timeDiff = () => ((performance.now() - self.PERFSTART) / 1000).toFixed(2);

//
const getArrFromPoints = (q) => [q.GetPoint(0), q.GetPoint(1), q.GetPoint(2), q.GetPoint(3)];

// Prepare result object for worker response
function resultObject(result) {
  self.PERFSTART = performance.now();
  return {
    requestType: "result",
    docType: "",
    data: getTextFields(result),
    images: [],
    time: timeDiff()
  };
}

// Get text fields in result
function getTextFields(result) {
  const data = [];
  const co = result.ObjectsBegin();
  for (; !co.Equals(result.ObjectsEnd()); co.Advance()) {
    const code_object = co.GetValue();
    let object_data = {
      "type": code_object.GetTypeStr(), 
      "attributes": {}
    }
    const tf = code_object.FieldsBegin();
    for (; !tf.Equals(code_object.FieldsEnd()); tf.Advance()) {
      // const key = tf.GetKey();
      const code_field = tf.GetValue();
      let code_field_name = code_field.Name();
      let value_binary = "";
      let value_string = "";

      if (code_field.HasBinaryRepresentation()) {
        value_binary = code_field.GetBinaryRepresentation().GetBase64String();
      }

      if (code_field.HasOcrStringRepresentation())
      value_string = code_field.GetOcrString().GetFirstString();

      object_data[code_field_name] = {
        name: code_field_name,
        value_binary: value_binary,
        value_string: value_string,
        isAccepted: code_field.IsAccepted()
      };
    }
    // attr

    let start = code_object.AttributesBegin();
    let end = code_object.AttributesEnd();

    console.log("==== Field Attributes START ====");

    for (; !start.Equals(end); start.Advance()) {

      let attrKey = start.GetKey();
      console.log("attrKey is: " + attrKey)
      let attrValue = start.GetValue();
      console.log("attrValue is: " + attrValue)
      object_data["attributes"][attrKey] = attrValue;

      console.log("🔸 " + attrKey + ":" + attrValue);

    }
    console.log("==== Field Attributes END ====");

    data.push(object_data);
  }

  return data;
}

// Parse code object quadrangles from result
function getCodeObjectQuadrangles(result) {
  const arr = [];
  const co = result.ObjectsBegin();
  for (; !co.Equals(result.ObjectsEnd()); co.Advance()) {
    const code_object = co.GetValue();
    if(code_object.HasQuadrangle()){
      const q = code_object.GetQuadrangle();
      arr.push(getArrFromPoints(q));
    }
  }
  return arr;
}

// Get available document lists in your SDK
function getAvailableDocList(SE, ENGINE) {
  let engines = [];
  if (ENGINE.IsEngineAvailable(SE.CodeEngineType.CodeEngine_Barcode)) {
    console.log("Barcode enabled");
    let engine_name = SE.ToString(SE.EngineSettingsGroup.Barcode);
    console.log(engine_name);
    engines.push(engine_name);
  }

  if (ENGINE.IsEngineAvailable(SE.CodeEngineType.CodeEngine_MRZ)) {
    console.log("MRZ enabled");
    // Setting option to enable mrz recognition
    let engine_name = SE.ToString(SE.EngineSettingsGroup.Mrz);
    console.log(engine_name);
    engines.push(engine_name);
  }

  if (ENGINE.IsEngineAvailable(SE.CodeEngineType.CodeEngine_BankCard)) {
    console.log("Bank cards enabled");
    // Setting option to enable bank card recognition
    let engine_name = SE.ToString(SE.EngineSettingsGroup.Card);
    console.log(engine_name);
    engines.push(engine_name);
  }

  if (ENGINE.IsEngineAvailable(SE.CodeEngineType.CodeEngine_CodeTextLine)) {
    console.log("Code text lines enabled");
    // Setting option to enable code text line recognition
    let engine_name = SE.ToString(SE.EngineSettingsGroup.CodeTextLine);
    console.log(engine_name);
    engines.push(engine_name);
  }

  if (ENGINE.IsEngineAvailable(SE.CodeEngineType.CodeEngine_PaymentDetails)) {
    console.log("Payment details enabled");
    // Setting option to enable payment details recognition
    let engine_name = SE.ToString(SE.EngineSettingsGroup.PaymentDetails);
    console.log(engine_name);
    engines.push(engine_name);
  }

  if (ENGINE.IsEngineAvailable(SE.CodeEngineType.CodeEngine_LicensePlate)) {
    console.log("License plates enabled");
    // Setting option to enable license plate recognition
    let engine_name = SE.ToString(SE.EngineSettingsGroup.LicensePlate);
    console.log(engine_name);
    engines.push(engine_name);
  }

  if (ENGINE.IsEngineAvailable(SE.CodeEngineType.CodeEngine_ContainerRecog)) {
    console.log("Container recog enabled");
    // Setting option to enable container recognition
    let engine_name = SE.ToString(SE.EngineSettingsGroup.ContainerRecog);
    console.log(engine_name);
    engines.push(engine_name);
  }

  arr = [];
  for (const element of engines) {
    arr.push("Engine name: " + element);
  }

  return arr;
}
