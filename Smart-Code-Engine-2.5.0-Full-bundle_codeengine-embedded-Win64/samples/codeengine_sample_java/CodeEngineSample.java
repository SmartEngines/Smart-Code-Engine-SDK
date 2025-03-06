/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

import com.smartengines.code.*;
import com.smartengines.common.*;

public class CodeEngineSample {

  static {
    System.loadLibrary("jnicodeengine");
  }


public static class OptionalWorkflowFeedBack extends CodeEngineWorkflowFeedback {
    public void ResultReceived(CodeEngineResult result) {
      System.out.printf("[Feedback called]: Result received (Obj count (%d)\n", result.GetObjectCount());
      System.out.flush();
    }

    public void SessionEnded() {
      System.out.printf("[Optional callback called]: Session ended\n");
      System.out.flush();
    }
  }

public static class OptionalVisualizationFeedBack extends CodeEngineVisualizationFeedback {
    public void FeedbackReceived(CodeEngineFeedbackContainer feedback_container) {
      System.out.printf("[Feedback called]: Feedback received\n");
      System.out.flush();
    }
  }

  public static OptionalWorkflowFeedBack WorkflowFeedBack = new OptionalWorkflowFeedBack();
  public static OptionalVisualizationFeedBack VisualizationFeedBack = new OptionalVisualizationFeedBack();

  // Here we simply output the recognized fields
  public static void OutputRecognitionResult(CodeEngineResult result) {
    System.out.printf("Total objects count: %d\n", result.GetObjectCount());

    for (CodeObjectsMapIterator it_obj = result.ObjectsBegin(); 
        !it_obj.Equals(result.ObjectsEnd()); it_obj.Advance()) {
      CodeObject code_object = it_obj.GetValue();
      System.out.printf("%s: Accepted%sTerminal%s (%f) ID:{%d}\n", code_object.GetTypeStr(),
          code_object.IsAccepted() ? " [+] " : " [-] ", code_object.GetIsTerminal() ? " [+] " : " [-] ", 
          code_object.GetConfidence(), code_object.GetID());
      System.out.printf("    Detected frames: first %d, last %d\n", code_object.GetFirstDetectedFrame(),
             code_object.GetLastUpdatedFrame());

      if (code_object.HasQuadrangle())
        System.out.printf("    Quad = { (%f, %f), (%f, %f), (%f, %f), " +
          "(%f, %f) }\n",
            code_object.GetQuadrangle().GetPoint(0).getX(), code_object.GetQuadrangle().GetPoint(0).getY(),
            code_object.GetQuadrangle().GetPoint(1).getX(), code_object.GetQuadrangle().GetPoint(1).getY(),
            code_object.GetQuadrangle().GetPoint(2).getX(), code_object.GetQuadrangle().GetPoint(2).getY(),
            code_object.GetQuadrangle().GetPoint(3).getX(), code_object.GetQuadrangle().GetPoint(3).getY());

      if (code_object.HasImage())
        System.out.printf("    Image W:%d H:%d", code_object.GetImage().GetWidth(),
            code_object.GetImage().GetHeight());

      System.out.printf("    Fields:\n");
      for (CodeFieldsMapIterator it_field = code_object.FieldsBegin();
           !it_field.Equals(code_object.FieldsEnd()); it_field.Advance()) {
        CodeField code_field = it_field.GetValue();
        System.out.printf("      %-21s%s (%f)\n", code_field.Name(),
                 code_field.IsAccepted() ? " [+] " : " [-] ",
                 code_field.GetConfidence());

        if (code_field.HasBinaryRepresentation()) {
          System.out.printf("        Base64 BinaryRepresentation: %s\n",
              code_field.GetBinaryRepresentation().GetBase64String().GetCStr());
          System.out.printf("        HexStr BinaryRepresentation: %s\n",
                   code_field.GetBinaryRepresentation().GetHexString().GetCStr());
        }

        if (code_field.HasOcrStringRepresentation())
          System.out.printf("        Ocr string representation: %s\n",
                   code_field.GetOcrString().GetFirstString().GetCStr());
      }

      System.out.printf("    Components:\n");
      for (QuadranglesMapIterator it_comp = code_object.ComponentsBegin();
           !it_comp.Equals(code_object.ComponentsEnd()); it_comp.Advance()) {
        System.out.printf("      %s = { (%f, %f), (%f, %f), (%f, %f), " +
             "(%f, %f) }\n",
             it_comp.GetKey(), 
             it_comp.GetValue().GetPoint(0).getX(), it_comp.GetValue().GetPoint(0).getY(), 
             it_comp.GetValue().GetPoint(1).getX(), it_comp.GetValue().GetPoint(1).getY(), 
             it_comp.GetValue().GetPoint(2).getX(), it_comp.GetValue().GetPoint(2).getY(), 
             it_comp.GetValue().GetPoint(3).getX(), it_comp.GetValue().GetPoint(3).getY());
      }

      System.out.printf("    Attributes:\n");
      for (StringsMapIterator it_attr = code_object.AttributesBegin();
           !it_attr.Equals(code_object.AttributesEnd()); it_attr.Advance()) {
        System.out.printf("      %s: %s\n", it_attr.GetKey(), it_attr.GetValue());
      }
    }
    System.out.printf("Result terminal:           %s\n",
           result.IsTerminal() ? " [+] " : " [-] ");
    System.out.flush();
  }

  public static void main(String[] args) {

    // 1st argument - path to the image to be recognized
    if (args.length != 1) {
      System.out.printf("Version %s. Usage: codeengine_sample_java" + 
          " <image_path>\n", 
          CodeEngine.GetVersion());
      System.exit(-1);
    }

    String image_path = args[0];
    
    System.out.printf("Smart Code Engine version: %s\n", CodeEngine.GetVersion());
    System.out.printf("image_path = %s\n", image_path);
    System.out.println();
    System.out.flush();

    try {
      // Creating the recognition engine object - initializes all internal
      //     configuration structure. First parameter to the ctor is the
      //     lazy initialization flag (true by default). If set to false,
      //     all internal objects will be initialized here, instead of
      //     waiting until some session needs them.
      CodeEngine engine = CodeEngine.CreateFromEmbeddedBundle(true);

      // Before creating the session we need to have a session settings
      //     object. Such object can be created only by acquiring a
      //     default session settings object from the configured engine.
      CodeEngineSessionSettings settings = engine.GetDefaultSessionSettings();

      if (engine.IsEngineAvailable(CodeEngineType.CodeEngine_Barcode)) {
        String engine_name = jnicodeengine.toString(EngineSettingsGroup.Barcode);
        // Setting option to enable barcode recognition
        settings.SetOption(engine_name + ".enabled", "true");
        // Setting option to enable all barcode symbologies recognition
        settings.SetOption(engine_name + ".COMMON.enabled", "true");
        // Setting option to enable processing AAMVA preset
        settings.SetOption(engine_name + ".preset", jnicodeengine.presetToString(BarcodePreset.AAMVA));
      }

      if (engine.IsEngineAvailable(CodeEngineType.CodeEngine_MRZ)) {
        // Setting option to enable mrz recognition
        // String engine_name = jnicodeengine.toString(EngineSettingsGroup.Mrz);
        // settings.SetOption(engine_name + ".enabled", "true");
      }

      if (engine.IsEngineAvailable(CodeEngineType.CodeEngine_CodeTextLine)) {
        // Setting option to enable phone number recognition
        // String engine_name = jnicodeengine.toString(EngineSettingsGroup.CodeTextLine);
        // settings.SetOption(engine_name + ".enabled", "true");
        // settings.SetOption(engine_name + ".phone_number.enabled", "true");
      }

      if (engine.IsEngineAvailable(CodeEngineType.CodeEngine_BankCard)) {
        // Setting option to enable bank card recognition
        // String engine_name = jnicodeengine.toString(EngineSettingsGroup.Card);
        // settings.SetOption(engine_name + ".enabled", "true");
      }

      // Creating a session object - a main handle for performing recognition.
      CodeEngineSession session = engine.SpawnSession(settings, ${put_yor_personalized_signature_from_doc_README.html}, WorkflowFeedBack, VisualizationFeedBack); 

      // Creating an image object which will be used as an input for the session
      Image image = Image.FromFile(image_path);

      // Performing the recognition and obtaining the recognition result
      CodeEngineResult result = session.Process(image);
      
      // Printing the contents of the recognition result
      // Passing session settings object only to output document info
      OutputRecognitionResult(result);

      // After the objects are no longer needed it is important to use the 
      // .delete() methods on them. It will force the associated native heap memory 
      // to be deallocated. Note that Java's GC does not care too much about the 
      // native heap and thus can delay the actual freeing of the associated memory, 
      // thus it is better to manage the internal native heap deallocation manually
      image.delete();
      result.delete();
      session.delete();
      settings.delete();
      engine.delete();

    } catch (java.lang.RuntimeException e) {
      System.out.printf("Exception caught: %s\n", e.toString());
      System.out.flush();
      System.exit(-1);
    }
  }
}
