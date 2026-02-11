/**
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

"use strict";

(async () => {
  // Main config
  const ENGINE_CONFIG = {
    activationUrl: "https://localhost:8000/client/sign_message",
    docTypes: "",
    signature: PUT_YOUR_PERSONAL_SIGNATURE_FROM_doc  // <-- set secret key
  };

  // Get root path relative to worker.js
  const pathname = self.location.pathname;
  let ROOT_PATH = pathname.substring(0, pathname.lastIndexOf("/") + 1); // "/dir/dir2/worker.js" return "/dir/dir2/"

  /* importScripts is still the most compatible.
   * Module workers are only supported with iOS15.
   * We don't want to use polyfill for that
   * https://wpt.fyi/results/workers/modules/dedicated-worker-import.any.html?label=master&label=stable&product=chrome&product=firefox&product=safari-14.1.2%20%2815611.3.10.1.7%29
   */

  importScripts(`${ROOT_PATH}se-func.js`);

  // Import getModuleName()
  let MODULE = await getModuleName();

  // For sample demonstration we change bin root folder
  if (ROOT_PATH == "/samples/codeengine_sample_wasm/") {
    ROOT_PATH = "/";
  }
  
  // Import the relevant global Engine object
  importScripts(`${ROOT_PATH}bin/${MODULE}/codeengine_wasm.js`);

  // *_wasm.js files are auto-generated from emscripten
  let module = {
    mainScriptUrlOrBlob: `${ROOT_PATH}bin/${MODULE}/codeengine_wasm.js`,
    locateFile: (file) => `${ROOT_PATH}bin/${MODULE}/` + file,
  };

  // Init WASM module
  const SE = await SmartCodeEngine(module);

  // Init recognition engine
  let ENGINE = createEngine(SE, MODULE);

  let spawnedSessionRGBA;

  onmessage = async function (msg) {
    switch (msg.data.requestType) {
      case "createSession":
        const data = msg.data.docData.split(":");
        // console.log(data)
        ENGINE_CONFIG.docTypes = data[1].trim();

        try {
          // Global session only for image stream
          spawnedSessionRGBA = createRGBASession(SE, ENGINE, ENGINE_CONFIG);
        } catch (e) {
          errorEmitter({ message: e, SE });
        }

        break;

      case "frame":
        // Check session activation
        try {
          await checkSession(spawnedSessionRGBA, ENGINE_CONFIG);
          const image = ImageFromRGBAbytes(msg.data.imageData, SE);
          const resultFrame = recognizeFrame(image, spawnedSessionRGBA);
          postMessage(resultFrame);
        } catch (e) {
          errorEmitter({ message: e, SE });
        }

        break;

      case "file":
        try {
          const fileResult = await recognizeFile(msg.data.imageData, ENGINE, ENGINE_CONFIG, SE);
          postMessage(fileResult);
        } catch (e) {
          errorEmitter({ message: e, SE });
        }

        break;

      case "reset":
        spawnedSessionRGBA?.Reset();

        break;

      // no default
    }
  };
})();
