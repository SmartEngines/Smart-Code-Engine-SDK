using System;
using System.Text;

using se.code;
using se.common;

class OptionalWorkflowFeedBack : CodeEngineWorkflowFeedback
{
  public OptionalWorkflowFeedBack() : base()
  {
  }

  public override void ResultReceived(CodeEngineResult result) {
    Console.WriteLine("[Feedback called]: Result received (Obj count {0})",
           result.GetObjectCount());
  }

  public override void SessionEnded() {
     Console.WriteLine("[Feedback called]: Session ended");
  }

}

class OptionalVisualizationFeedBack : CodeEngineVisualizationFeedback
{
  public OptionalVisualizationFeedBack() : base()
  {
  }

  public override void FeedbackReceived(CodeEngineFeedbackContainer result) {
    Console.WriteLine("[Feedback called]: Feedback received\n");
  }

}

class CodeEngineSampleCs
{
  static void OutputRecognitionResult(CodeEngineResult result)
  {
    Console.OutputEncoding = System.Text.Encoding.UTF8;
    Console.WriteLine("Total objects count: {0}\n", result.GetObjectCount());

    for (CodeObjectsMapIterator it_obj = result.ObjectsBegin(); 
        !it_obj.Equals(result.ObjectsEnd()); it_obj.Advance()) {
      CodeObject code_object = it_obj.GetValue();
      Console.WriteLine("{0} Accepted{1}Terminal{2} ({3}) ID:{4}", code_object.GetTypeStr(),
          code_object.IsAccepted() ? " [+] " : " [-] ", code_object.GetIsTerminal() ? " [+] " : " [-] ", 
          code_object.GetConfidence(), code_object.GetID());
      Console.WriteLine("    Detected frames: first {0}, last {1}", code_object.GetFirstDetectedFrame(),
             code_object.GetLastUpdatedFrame());

      if (code_object.HasQuadrangle())
        Console.WriteLine("    Quad = ({0}, {1}), ({2}, {3}), ({4}, {5}), ({6}, {7})",
            code_object.GetQuadrangle().GetPoint(0).x, code_object.GetQuadrangle().GetPoint(0).y,
            code_object.GetQuadrangle().GetPoint(1).x, code_object.GetQuadrangle().GetPoint(1).y,
            code_object.GetQuadrangle().GetPoint(2).x, code_object.GetQuadrangle().GetPoint(2).y,
            code_object.GetQuadrangle().GetPoint(3).x, code_object.GetQuadrangle().GetPoint(3).y);

      if (code_object.HasImage())
        Console.WriteLine("    Image W:{0} H:{1}", code_object.GetImage().GetWidth(),
            code_object.GetImage().GetHeight());

      Console.WriteLine("    Fields:");
      for (CodeFieldsMapIterator it_field = code_object.FieldsBegin(); 
          !it_field.Equals(code_object.FieldsEnd()); it_field.Advance()) {
        CodeField code_field = it_field.GetValue();
        Console.WriteLine("      {0:-14}   {1} ({2})", code_field.Name(), code_field.IsAccepted() ? " [+] " : " [-] ", 
            code_field.GetConfidence());
        if (code_field.HasBinaryRepresentation()) {
          Console.WriteLine("        Base64 Binary representation: {0}", 
              code_field.GetBinaryRepresentation().GetBase64String().GetCStr());
          Console.WriteLine("        HexStr Binary representation: {0}", 
              code_field.GetBinaryRepresentation().GetHexString().GetCStr());
        }
        if (code_field.HasOcrStringRepresentation())
          Console.WriteLine("        Ocr string representation: {0}", code_field.GetOcrString().GetFirstString().GetCStr());
      }

      Console.WriteLine("    Components:");
      for (QuadranglesMapIterator it_comp = code_object.ComponentsBegin(); 
          !it_comp.Equals(code_object.ComponentsEnd()); it_comp.Advance()) 
        Console.WriteLine("      {0} = ({0}, {1}), ({2}, {3}), ({4}, {5}), ({6}, {7})", it_comp.GetKey(), 
            it_comp.GetValue().GetPoint(0).x, it_comp.GetValue().GetPoint(0).y, 
            it_comp.GetValue().GetPoint(1).x, it_comp.GetValue().GetPoint(1).y,
            it_comp.GetValue().GetPoint(2).x, it_comp.GetValue().GetPoint(2).y,
            it_comp.GetValue().GetPoint(3).x, it_comp.GetValue().GetPoint(3).y);
      

      Console.WriteLine("    Attributes:");
      for (StringsMapIterator it_attr = code_object.AttributesBegin(); 
          !it_attr.Equals(code_object.AttributesEnd()); it_attr.Advance()) 
        Console.WriteLine("      {0}: {1}\n", it_attr.GetKey(), it_attr.GetValue());
    }
    
    Console.WriteLine("Result terminal:       {0}", result.IsTerminal() ? " [+] " : " [-] "); 
 }

  static void Main(string[] args)
  {
    if (args.Length < 1)
    {
      Console.WriteLine("Usage: codeengine_sample_cs <path-to-image-file>");
      Console.WriteLine(Environment.NewLine);
      return;
    }

    String image_path = args[0];

    Console.WriteLine("image_path = {0}", image_path);

    try
    {
      OptionalWorkflowFeedBack WorkflowFeedBack = new OptionalWorkflowFeedBack();
      OptionalVisualizationFeedBack VisualizationFeedBack = new OptionalVisualizationFeedBack();

      // Creating the recognition engine object - initializes all internal
      //     configuration structure. First parameter to the ctor is the
      //     lazy initialization flag (true by default). If set to false,
      //     all internal objects will be initialized here, instead of
      //     waiting until some session needs them.
      CodeEngine engine = CodeEngine.CreateFromEmbeddedBundle();

      // Before creating the session we need to have a session settings
      //     object. Such object can be created only by acquiring a
      //     default session settings object from the configured engine.
      CodeEngineSessionSettings settings = engine.GetDefaultSessionSettings();

      if (engine.IsEngineAvailable(CodeEngineType.CodeEngine_Barcode)) {
        String engine_name = cscodeengine.toString(EngineSettingsGroup.Barcode);
        // Setting option to enable barcode recognition
        settings.SetOption(engine_name + ".enabled", "true");
        // Setting option to enable all barcode symbologies recognition
        settings.SetOption(engine_name + ".COMMON.enabled", "true");
        // Setting option to enable processing AAMVA preset
        settings.SetOption(engine_name + ".preset", cscodeengine.presetToString(BarcodePreset.AAMVA));
      }

      if (engine.IsEngineAvailable(CodeEngineType.CodeEngine_MRZ)) {
        // Setting option to enable mrz recognition
        // String engine_name = cscodeengine.toString(EngineSettingsGroup.Mrz);
        // settings.SetOption(engine_name + ".enabled", "true");
      }

      if (engine.IsEngineAvailable(CodeEngineType.CodeEngine_CodeTextLine)) {
        // Setting option to enable phone number recognition
        // String engine_name = cscodeengine.toString(EngineSettingsGroup.CodeTextLine);
        // settings.SetOption(engine_name + ".enabled", "true");
        // settings.SetOption(engine_name + ".phone_number.enabled", "true");
      }

      if (engine.IsEngineAvailable(CodeEngineType.CodeEngine_BankCard)) {
        // Setting option to enable bank card recognition
        // String engine_name = cscodeengine.toString(EngineSettingsGroup.Card);
        // settings.SetOption(engine_name + ".enabled", "true");
      }

      // Creating a session object - a main handle for performing recognition.
      CodeEngineSession session = engine.SpawnSession(settings, @put_yor_personalized_signature_from_doc_README.html@, WorkflowFeedBack, VisualizationFeedBack);

      Image image;
#if _WINDOWS
//Fix for implicit encoding conversions in Win. Applies only to filename argument.
//Treating encoding as Win-1251, while OS thinks it is UTF-8.
//There is only beta-version of UTF-8 support in Win 10.

      Encoding win1251_encoding = Encoding.GetEncoding("Windows-1251");
      Encoding utf8_encoding = Encoding.GetEncoding("UTF-8");

      string imgname_input = args[0];
      byte[] win1251_as_utf8_input_bytes = utf8_encoding.GetBytes(imgname_input);
      byte[] converted_bytes = Encoding.Convert(win1251_encoding, utf8_encoding, win1251_as_utf8_input_bytes);
      string imgname_converted = System.Text.Encoding.UTF8.GetString(converted_bytes);

      image = Image.FromFileNoThrow(imgname_converted);

      CodeEngineResult recog_result = session.Process(image);
#else
      image = Image.FromFile(image_path);
      CodeEngineResult recog_result = session.Process(image);
#endif
      OutputRecognitionResult(recog_result);

      // this is important: GC works differently with native-heap objects
      recog_result.Dispose();
      session.Dispose();
      engine.Dispose();
    }
    catch (Exception e)
    {
      Console.WriteLine("Exception caught: {0}", e);
    }

    Console.WriteLine("Processing ended");
  }
}

