/**
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#include <cstdio>
#include <cstring>
#include <memory>
#include <string>
#include <vector>

#ifdef _MSC_VER
#pragma warning(disable : 4290)
#include <windows.h>
#endif // _MSC_VER

#include <codeengine/code_engine.h>

using namespace se::code;

class OptionalWorkflowFeedBack : public se::code::CodeEngineWorkflowFeedback {
public:
  virtual ~OptionalWorkflowFeedBack() override = default;

  virtual void
  ResultReceived(const se::code::CodeEngineResult &result) override {
    ::printf("[Feedback called]: Result received (Obj count:%d)\n",
             result.GetObjectCount());
  }

  virtual void SessionEnded() override {
    ::printf("[Feedback called]: Session ended\n");
  }
};

class OptionalVisualizationFeedBack
    : public se::code::CodeEngineVisualizationFeedback {
public:
  virtual ~OptionalVisualizationFeedBack() override = default;

  virtual void FeedbackReceived(const se::code::CodeEngineFeedbackContainer
                                    & /*feedback_container*/) override {
    ::printf("[Feedback called]: Feedback received\n");
  }
};

void OutputRecognitionResult(const se::code::CodeEngineResult &result) {
  ::printf("Total objects count: %d\n", result.GetObjectCount());

  for (auto it_obj = result.ObjectsBegin(); it_obj != result.ObjectsEnd();
       ++it_obj) {
    const se::code::CodeObject &code_object = it_obj.GetValue();
    ::printf(
        "%s: Accepted%sTerminal%s (%4.3lf) ID:%d\n    Detected "
        "frames: first %d, last %d\n",
        code_object.GetTypeStr(), code_object.IsAccepted() ? " [+] " : " [-] ",
        code_object.GetIsTerminal() ? " [+] " : " [-] ",
        code_object.GetConfidence(), code_object.GetID(),
        code_object.GetFirstDetectedFrame(), code_object.GetLastUpdatedFrame());

    if (code_object.HasQuadrangle())
      ::printf(
          "    Quad = { (%4.1lf, %4.1lf), (%4.1lf, %4.1lf), (%4.1lf, %4.1lf), "
          "(%4.1lf, %4.1lf) }\n",
          code_object.GetQuadrangle()[0].x, code_object.GetQuadrangle()[0].y,
          code_object.GetQuadrangle()[1].x, code_object.GetQuadrangle()[1].y,
          code_object.GetQuadrangle()[2].x, code_object.GetQuadrangle()[2].y,
          code_object.GetQuadrangle()[3].x, code_object.GetQuadrangle()[3].y);

    if (code_object.HasImage())
      ::printf("    Image W: %d H: %d\n", code_object.GetImage().GetWidth(),
               code_object.GetImage().GetHeight());

    ::printf("    Fields:\n");
    for (auto it_field = code_object.FieldsBegin();
         it_field != code_object.FieldsEnd(); ++it_field) {
      const se::code::CodeField &code_field = it_field.GetValue();
      ::printf("      %-21s%s (%4.3lf)\n", code_field.Name(),
               code_field.IsAccepted() ? " [+] " : " [-] ",
               code_field.GetConfidence());

      if (code_field.HasBinaryRepresentation()) {
        ::printf("        Base64 BinaryRepresentation: %s\n",
            code_field.GetBinaryRepresentation().GetBase64String().GetCStr());
        ::printf("        HexStr BinaryRepresentation: %s\n",
                 code_field.GetBinaryRepresentation().GetHexString().GetCStr());
      }

      if (code_field.HasOcrStringRepresentation())
        ::printf("        Ocr string representation: %s\n",
                 code_field.GetOcrString().GetFirstString().GetCStr());
    }

    ::printf("    Components:\n");
    for (auto it_comp = code_object.ComponentsBegin();
         it_comp != code_object.ComponentsEnd(); ++it_comp) {
      ::printf("      %s = { (%4.0lf, %lf), (%4.0lf, %lf), (%4.0lf, %lf), "
               "(%4.0lf, %4.0lf) }\n",
               it_comp.GetKey(), it_comp.GetValue()[0].x,
               it_comp.GetValue()[0].y, it_comp.GetValue()[1].x,
               it_comp.GetValue()[1].y, it_comp.GetValue()[2].x,
               it_comp.GetValue()[2].y, it_comp.GetValue()[3].x,
               it_comp.GetValue()[3].y);
    }

    ::printf("    Attributes:\n");
    for (auto it_attr = code_object.AttributesBegin();
         it_attr != code_object.AttributesEnd(); ++it_attr) {
      ::printf("      %s: %s\n", it_attr.GetKey(), it_attr.GetValue());
    }
  }

  ::printf("Result terminal:           %s\n",
           result.IsTerminal() ? " [+] " : " [-] ");
}

int main(int argc, char **argv) {
#ifdef _MSC_VER
  SetConsoleOutputCP(65001);
#endif // _MSC_VER

  // 1st argument - path to the image to be recognized
  if (argc != 2) {
    ::printf("Version %s. Usage: %s <image_path>",
             se::code::CodeEngine::GetVersion(), argv[0]);
    return -1;
  }

  const std::string image_path = argv[1];

  ::printf("Smart Code Engine version: %s\n", se::code::CodeEngine::GetVersion());
  ::printf("image_path = %s\n", image_path.c_str());
  ::printf("\n");

  OptionalWorkflowFeedBack option_workflow_feedback;
  OptionalVisualizationFeedBack option_visualization_feedback;
  try {
    // Creating the recognition engine object - initializes all internal
    //     configuration structure. First parameter to the ctor is the
    //     lazy initialization flag (true by default). If set to false,
    //     all internal objects will be initialized here, instead of
    //     waiting until some session needs them.
    std::unique_ptr<se::code::CodeEngine> engine(
        se::code::CodeEngine::CreateFromEmbeddedBundle(true));

    // Before creating the session we need to have a session settings
    //     object. Such object can be created only by acquiring a
    //     default session settings object from the configured engine.
    std::unique_ptr<se::code::CodeEngineSessionSettings> settings(
        engine->GetDefaultSessionSettings());

    if (engine->IsEngineAvailable(se::code::CodeEngine_Barcode)) {
      std::string engine_name = toString(EngineSettingsGroup::Barcode);
      // Setting option to enable barcode recognition
      settings->SetOption((engine_name + ".enabled").c_str(), "true");
      // Setting option to enable all barcode symbologies recognition
      settings->SetOption((engine_name + ".COMMON.enabled").c_str(), "true");
      // Setting option to enable processing AAMVA preset
      settings->SetOption((engine_name + ".preset").c_str(), presetToString(BarcodePreset::AAMVA));
    }

    if (engine->IsEngineAvailable(se::code::CodeEngine_MRZ)) {
      // Setting option to enable mrz recognition
      // std::string engine_name = toString(EngineSettingsGroup::Mrz);
      // settings->SetOption((engine_name + ".enabled").c_str(), "true");
    }

    if (engine->IsEngineAvailable(se::code::CodeEngine_CodeTextLine)) {
      // Setting option to enable phone number recognition
      // std::string engine_name = toString(EngineSettingsGroup::CodeTextLine);
      // settings->SetOption((engine_name + ".enabled").c_str(), "true");
      // settings->SetOption((engine_name + ".phone_number.enabled").c_str(), "true");
    }

    if (engine->IsEngineAvailable(se::code::CodeEngine_BankCard)) {
      // Setting option to enable bank card recognition
      // std::string engine_name = toString(EngineSettingsGroup::Card);
      // settings->SetOption((engine_name + ".enabled").c_str(), "true");
    }

    // Creating a session object - a main handle for performing recognition.
    std::unique_ptr<se::code::CodeEngineSession> session(engine->SpawnSession(
        *settings, ${put_yor_personalized_signature_from_doc_README.html},
        &option_workflow_feedback, &option_visualization_feedback));

    // Creating an image object which will be used as an input for the session
    std::unique_ptr<se::common::Image> snapshot(
        se::common::Image::FromFile(image_path.c_str()));

    // Performing the recognition and obtaining the recognition result
    const se::code::CodeEngineResult& result = session->Process(*snapshot);

    // Printing the contents of the recognition result
    // Passing session settings object only to output document info
    OutputRecognitionResult(result);

  } catch (const se::common::BaseException &e) {
    ::printf("Exception thrown: %s\n", e.what());
    return -1;
  }

  return 0;
}
