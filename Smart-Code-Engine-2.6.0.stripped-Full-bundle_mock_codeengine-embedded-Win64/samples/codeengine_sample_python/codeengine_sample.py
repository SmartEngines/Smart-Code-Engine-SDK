#!/usr/bin/python
import sys
import os

sys.path.append(os.path.join(sys.path[0], '../../bindings/python/'))
sys.path.append(os.path.join(sys.path[0],'../../bin/'))

import pycodeengine

class OptionalWorkflowFeedBack(pycodeengine.CodeEngineWorkflowFeedback):

  def ResultReceived(self, result):
    print('[Feedback called]: Result received (Obj count: {})'.format(
      result.GetObjectCount()))

  def SessionEnded(self):
    print('[Feedback called]: Session ended')

class OptionalVisualizationFeedBack(pycodeengine.CodeEngineVisualizationFeedback):

  def FeedbackReceived(self, feedback_container):
    print('[Feedback called]: Feedback received')

#  Here we simply output the recognized fields
def OutputRecognitionResult(result):
    print('Total objects count: {}'.format(result.GetObjectCount()))
    print('')
    it_obj = result.ObjectsBegin()
    while (it_obj != result.ObjectsEnd()):
      code_object = it_obj.GetValue()
      if code_object.IsAccepted(): co_IsAccepted = " [+] "
      else: co_IsAccepted = " [-] "
      if code_object.GetIsTerminal(): co_GetIsTerminal = " [+] "
      else: co_GetIsTerminal = " [-] "
      print('{0} Accepted{1}Terminal{2} ({3}) ID:{4}'.format(code_object.GetTypeStr(), 
             co_IsAccepted, co_GetIsTerminal, code_object.GetConfidence(), code_object.GetID()))
      print('    Detected frames: first {0}, last {1}'.format(code_object.GetFirstDetectedFrame(),
             code_object.GetLastUpdatedFrame()))

      if code_object.HasQuadrangle():
        print('    Quad = ({0}, {1}), ({2}, {3}), ({4}, {5}), ({6}, {7})'.format(
               code_object.GetQuadrangle().GetPoint(0).x, code_object.GetQuadrangle().GetPoint(0).y,
               code_object.GetQuadrangle().GetPoint(1).x, code_object.GetQuadrangle().GetPoint(1).y,
               code_object.GetQuadrangle().GetPoint(2).x, code_object.GetQuadrangle().GetPoint(2).y,
               code_object.GetQuadrangle().GetPoint(3).x, code_object.GetQuadrangle().GetPoint(3).y))

      if code_object.HasImage():
        print('    Image W:{0} H{1}'.format(code_object.GetImage().GetWidth(),
               code_object.GetImage().GetHeight()))

      print('    Fields:')
      it_field = code_object.FieldsBegin()
      while (it_field != code_object.FieldsEnd()):
        code_field = it_field.GetValue()
        if code_field.IsAccepted(): cf_IsAccepted = " [+] "
        else: cf_IsAccepted = " [-] "
        print('      {0:<14}   {1} ({2})'.format(code_field.Name(), cf_IsAccepted, 
               code_field.GetConfidence()))

        if code_field.HasBinaryRepresentation():
          print('        Base64 Binary representation: {}'.format(
                 code_field.GetBinaryRepresentation().GetBase64String().GetCStr()))
          print('        HexStr Binary representation: {}'.format(
                 code_field.GetBinaryRepresentation().GetHexString().GetCStr()))

        if code_field.HasOcrStringRepresentation():
          print("        Ocr string representation: {}".format(code_field.GetOcrString().GetFirstString().GetCStr()))

        it_field.Advance()

      print("    Components:")
      it_comp = code_object.ComponentsBegin()
      while (it_comp != code_object.ComponentsEnd()):
        print('      {0} = ({0}, {1}), ({2}, {3}), ({4}, {5}), ({6}, {7})'.format(
               it_comp.GetKey(), 
               it_comp.GetValue().GetPoint(0).x, it_comp.GetValue().GetPoint(0).y, 
               it_comp.GetValue().GetPoint(1).x, it_comp.GetValue().GetPoint(1).y,
               it_comp.GetValue().GetPoint(2).x, it_comp.GetValue().GetPoint(2).y,
               it_comp.GetValue().GetPoint(3).x, it_comp.GetValue().GetPoint(3).y))
        it_comp.Advance()

      print('    Attributes:')
      it_attr = code_object.AttributesBegin()
      while (it_attr != code_object.AttributesEnd()):
        print('      {0}: {1}'.format(it_attr.GetKey(), it_attr.GetValue()))
        it_attr.Advance()

      print('')
      it_obj.Advance()

    if result.IsTerminal(): res_IsTerminal = " [+] "
    else: res_IsTerminal = " [-] "
    print('Result terminal:       {}'.format(res_IsTerminal))

def main():
  if len(sys.argv) != 2:
    print('Version {}. Usage: '
            '{} <image_path>'.format(
            pycodeengine.CodeEngine.GetVersion(), sys.argv[0]))
    sys.exit(-1)

  image_path = sys.argv[1]

  print('Smart Code Engine version {}'.format(
         pycodeengine.CodeEngine.GetVersion()))
  print('image_path = {}'.format( image_path))
  print('')

  WorkflowFeedBack = OptionalWorkflowFeedBack()
  VisualizationFeedBack = OptionalVisualizationFeedBack()
  try:
    # Creating the recognition engine object - initializes all internal
    #     configuration structure. First parameter to the factory method
    #     is the lazy initialization flag (true by default). If set to
    #     false, all internal objects will be initialized here, instead of
    #     waiting until some session needs them.
    engine = pycodeengine.CodeEngine.CreateFromEmbeddedBundle(True)

    # Before creating the session we need to have a session settings
    #     object. Such object can be created only by acquiring a
    #     default session settings object from the configured engine.
    settings = engine.GetDefaultSessionSettings()

    if engine.IsEngineAvailable(pycodeengine.CodeEngine_Barcode):
      engine_name = pycodeengine.toString(pycodeengine.EngineSettingsGroup_Barcode)
      # Setting option to enable barcode recognition
      settings.SetOption(engine_name + ".enabled", "true");
      # Setting option to enable all barcode symbologies recognition
      settings.SetOption(engine_name + ".COMMON.enabled", "true");
      # Setting option to enable processing AAMVA preset
      settings.SetOption(engine_name + ".preset", pycodeengine.presetToString(pycodeengine.BarcodePreset_AAMVA));

    # Enable mrz recognition
    if engine.IsEngineAvailable(pycodeengine.CodeEngine_MRZ):
      engine_name = pycodeengine.toString(pycodeengine.EngineSettingsGroup_Mrz)
      # settings.SetOption(engine_name + ".enabled", "true");
      
    # Enable phone number recognition
    if engine.IsEngineAvailable(pycodeengine.CodeEngine_CodeTextLine):
      engine_name = pycodeengine.toString(pycodeengine.EngineSettingsGroup_CodeTextLine)
      # settings.SetOption(engine_name + ".enabled", "true");
      # settings.SetOption(engine_name + ".phone_number.enabled", "true");
      
    # Enable bank card recognition
    if engine.IsEngineAvailable(pycodeengine.CodeEngine_BankCard) :
      engine_name = pycodeengine.toString(pycodeengine.EngineSettingsGroup_Card)
      # settings.SetOption(engine_name + ".enabled", "true");

    # Creating a session object - a main handle for performing recognition.
    session = engine.SpawnSession(settings, @put_yor_personalized_signature_from_doc_README.html@, WorkflowFeedBack, VisualizationFeedBack)

    # Creating image objects which will be used as an input for the session
    image = None
    try:
      image = pycodeengine.Image.FromFile(image_path)
      session.Process(image)

      # Obtaining the recognition result
      result = session.GetCurrentResult()
      OutputRecognitionResult(result)

    except BaseException as e: 
      print(e)
      print('Caught exception')
      return 0
    
  except BaseException as e: 
    print('Exception thrown: {}'.format(e))
    return -1

  return 0


if __name__ == '__main__':
    main()
