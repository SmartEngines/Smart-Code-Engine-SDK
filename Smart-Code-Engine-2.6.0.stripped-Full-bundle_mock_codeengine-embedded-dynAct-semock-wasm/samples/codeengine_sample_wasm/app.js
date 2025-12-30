/**
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

// https://web.dev/module-workers/

const video = document.querySelector("#video");
video.setAttribute("playsinline", true);
const canvas = document.querySelector("#canvas");
const overlayCanvas = document.querySelector("#overlayCanvas");

const fileSelector = document.querySelector("#select_file");

const startButton = document.querySelector("#button_start");
const selectButton = document.querySelector("#button_select");
const cameraButton = document.querySelector("#button_camera");
const buttons = document.querySelector("#buttons");

const wasmLog = document.querySelector(".wasm");

// Lock the log after a camera error.
// Prevents the log from being overwritten by Worker
let isLogNotLocked = true;

const log = e => {
  if (isLogNotLocked) {
    wasmLog.innerHTML = e;
  }
};

log("⏳ Loading and compiling wasm...");

let SEWorker = new Worker("./worker.js" + "?v=" + Math.random());// random for prevent caching

startButton.addEventListener("click", (event) => {
  SEWorker.postMessage(requestFrame());
});

fileSelector.addEventListener("change", (event) => {
  const file = event.target.files[0];

  if (file?.type && file?.type.indexOf("image") === -1) {
    console.log("File is not an image.", file.type, file);
    return;
  }

  const reader = new FileReader();

  // prettier-ignore
  reader.addEventListener("load", () => {
    SEWorker.postMessage({ requestType: "file", imageData: reader.result });
  }, false,);

  if (file) {
    reader.readAsArrayBuffer(file);
  }
});

let stream;

async function cameraInit(cameraId) {
  const constraints = {
    audio: false,
    video: {
      width: {
        ideal: 640,
        //min: 640,
        //max: 1280, // will be slow? Looks like 640 is ok for most cases.
      },
      height: {
        ideal: 480,
        //min: 480,
        //max: 720,
      },
      deviceId: cameraId || "undefined",
      // facingMode: "enviroment",
    },
  };

  try {
    // We must remove all streams before switching devices!
    if (stream) {
      stream.getTracks().forEach((track) => track.stop());
    }

    stream = await navigator.mediaDevices.getUserMedia(constraints);

    console.log("Got stream with constraints:", constraints);
    video.srcObject = stream;
    await video.play();
  } catch (error) {
    if (error.name === "OverconstrainedError") {
      const v = constraints.video;
      console.error(`The resolution ${v.width.exact}x${v.height.exact} px is not supported by your device.`);
    } else if (error.name === "NotAllowedError") {
      console.error("Permissions have not been granted to use your camera and " + "microphone, you need to allow the page access to your devices in " + "order for the demo to work.");
    }
    console.error(`getUserMedia error: ${error.name}`, error);
  }

  const { videoWidth, videoHeight } = video;
  // dublicate canvas size for overlay
  canvas.width = overlayCanvas.width = videoWidth;
  canvas.height = overlayCanvas.height = videoHeight;
  // we use opacity for css animation
  canvas.style.opacity = 1;
  const ctx = canvas.getContext("2d", { willReadFrequently: true });
  const animate = function () {
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
    requestAnimationFrame(animate);
  };

  animate();
}

function init() {
  // Ask camera permissions
  navigator.mediaDevices
    .getUserMedia({ video: true })
    .then(async () => {
      // get list of video devices
      let deviceInfos = await navigator.mediaDevices.enumerateDevices();
      const arr = [];
      for (let i = 0; i !== deviceInfos.length; ++i) {
        const deviceInfo = deviceInfos[i];
        if (deviceInfo.kind === "videoinput") {
          console.log(deviceInfo);
          arr.push({
            label: deviceInfo.label,
            value: deviceInfo.deviceId,
            facingMode: deviceInfo.getCapabilities().facingMode,
          });
        }
      }

      const environment = arr.find((el) => el.facingMode == "environment") || arr[0];
      console.log(environment);

      for (let i in arr) {
        cameraButton.add(new Option(arr[i].label, arr[i].value));
        if (arr[i].value == environment.value) {
          cameraButton.selectedIndex = i;
        }
      }

      cameraButton.addEventListener("change", async (event) => {
        console.log("You selected: ", event.target.value);
        await cameraInit(event.target.value);
      });

      await cameraInit(environment.value);
    })
    .catch((error) => {
      if (error.name === "OverconstrainedError") {
        console.error(`The resolution ${constraints.video.width.exact}x${constraints.video.height.exact} px is not supported by your device.`);
        log(`The resolution ${constraints.video.width.exact}x${constraints.video.height.exact} px is not supported by your device.`);
      } else if (error.name === "NotAllowedError") {
        console.error("😕 You need to grant this page permission to access your camera.");
        log("😕 You need to grant this page permission to access your camera.");
      } else {
        console.error(`getUserMedia error: ${error.name}`, error);
        log(error);
      }
      isLogNotLocked = false;
    });
}

init();

function fillSelectOption(list) {
  for (let el of list) selectButton.options.add(new Option(el, el));

  SEWorker.postMessage({
    requestType: "createSession",
    docData: selectButton.value,
  });

  selectButton.addEventListener("change", function () {
    console.log("You selected: ", this.value);
    SEWorker.postMessage({ requestType: "createSession", docData: this.value });
  });
}

function requestFrame() {
  // Show requested images by the wasm
  console.log("%c ", `line-height:8rem;padding-right:25%;background:url(${canvas.toDataURL("image/jpeg", 1.0)}) top left / contain no-repeat`);

  // Add to console `window.sm_debug = true` to run debug
  if (window?.sm_debug == true) {
    let link = document.createElement("a");
    link.setAttribute("download", Math.random() + "_test.png");
    const url = canvas.toDataURL("image/png").replace("image/png", "image/octet-stream");
    link.setAttribute("href", url);
    link.click();
  }

  return {
    requestType: "frame",
    imageData: canvas.getContext("2d", { alpha: false, willReadFrequently: true }).getImageData(0, 0, canvas.width, canvas.height)
  };
}

SEWorker.onmessage = function (msg) {
  switch (msg.data.requestType) {
    // events from wasm worker
    case "eventChannel":
      wasmEmitter(msg.data.data);
      break;

    // processing result
    case "result":
      let result = msg.data;

      // empty result object means timeout event
      if (Object.keys(result.data).length === 0) {
        console.log("😕 Document Not found");
        log("😕 Document Not found");
        SEWorker.postMessage({ requestType: "reset" });
        return;
      }

      console.log("👍 Document Ready");
      log("👍 Document Ready " + result.time + " s");

      console.log(result);
      printResult(result);
      // Clear overlay canvas
      canvasHandler.clear(overlayCanvas);
      // reset session on result. Overwise you will always get result of latest document every request.
      SEWorker.postMessage({ requestType: "reset" });

      break;

    // providing more images for recognition
    case "FeedMeMore":
      console.log("🥝 Feed Me More...");
      console.log("🥝 Feed Me More...", msg);
      canvasHandler.draw(msg.data, overlayCanvas);
      SEWorker.postMessage(requestFrame());
      break;
    // no default
  }
};


// Wasm events handler
function wasmEmitter(eventType) {
  switch (eventType.type) {
    case "ready":
      console.log("🟢 v." + eventType.version + " Ready");
      log("🟢 v." + eventType.version + " Ready");
      buttons.style.display = "block";
      fillSelectOption(eventType.doclist);
      break;

    case "log":
      log(eventType.message);
      console.log(eventType.message);
      break;

    case "error":
      // reset file input value
      fileSelector.value = null;
      log(eventType.message);
      SEWorker.postMessage({ requestType: "reset" });
      break;
    // no default
  }
}

const drawQuadrangle = (p) => {
  const path = new Path2D();
  path.moveTo(p[0].x, p[0].y);
  path.lineTo(p[1].x, p[1].y);
  path.lineTo(p[2].x, p[2].y);
  path.lineTo(p[3].x, p[3].y);
  path.lineTo(p[0].x, p[0].y);
  return path;
};

const canvasHandler = {
  clear(overlayCanvas) {
    overlayCanvas.getContext("2d").clearRect(0, 0, overlayCanvas.width, overlayCanvas.height);
  },
  draw(result, overlayCanvas) {
    this.clear(overlayCanvas);
    const ctx = overlayCanvas.getContext("2d");

    if (result?.codeObjectQuadrangles) {
      for (let i = 0; i < result.codeObjectQuadrangles.length; i++) {
        const p = result.codeObjectQuadrangles[i];
        ctx.lineWidth = 2;
        ctx.strokeStyle = "green";
        ctx.stroke(drawQuadrangle(p));
      }
    }

    // debug drawing
    // console.log("%c ", `line-height:8rem;padding-right:25%;background:url(${overlayCanvas.toDataURL("image/jpeg", 1.0)}) top left / contain no-repeat`);
  },
};

function printResult(r) {

  const output = document.querySelector("#output");
  const outputFieldTemplate = document.querySelector('#output-field-template');
  const outputAttrTemplate = document.querySelector('#output-attr-template');


  //cleanOutput
  output.innerHTML = null;

  for (const obj in r.data) {
    console.log("obj is: ", obj)

    let clone = outputFieldTemplate.content.cloneNode(true);
    clone.querySelector("b+span").innerText = r.data[obj]["type"];
    output.appendChild(clone);

    for (const prop in r.data[obj]) {
      console.log("prop is: " + prop)

      if (prop == "type") { continue; }

      if (prop == "attributes") {

        let cloneAttr = outputAttrTemplate.content.cloneNode(true);
        const ul = cloneAttr.querySelector("ul");

        for (const attr in r.data[obj][prop]) {
          const li = document.createElement('li');
          li.innerText = attr + ":" + r.data[obj][prop][attr];
          ul.appendChild(li);
        }

        output.appendChild(cloneAttr);
        continue;
      }

      const clone = outputFieldTemplate.content.cloneNode(true);
      clone.querySelector("b").innerText = prop;
      clone.querySelector("b+span").innerText = r.data[obj][prop].value_binary;
      clone.querySelector("b+span+span").innerText = r.data[obj][prop].value_string;
      output.appendChild(clone);

    }
    // add separator
    output.appendChild(document.createElement('hr'));
  }

}
