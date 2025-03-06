%module(directors="1") pycodeengine
%feature("director") se::code::CodeEngineWorkflowFeedback;
%feature("director") se::code::CodeEngineVisualizationFeedback;

%include typemaps.i
%include exception.i
%include std_except.i
%include pybuffer.i
%pybuffer_mutable_string(char* out_buffer); 

%include "secommon_include.i"

%apply (char *STRING, size_t LENGTH) {(const unsigned char* config_data, int config_data_length)};

%{
  #include "secommon/se_common.h"
  #include "secommon/se_exception.h"
  #include "secommon/se_export_defs.h"
  #include "secommon/se_geometry.h"
  #include "secommon/se_image.h"
  #include "secommon/se_serialization.h"
  #include "secommon/se_string.h"
  #include "secommon/se_strings_iterator.h"
  #include "secommon/se_strings_set.h"


  #include "codeengine/code_engine_session_settings.h"
  #include "codeengine/code_object_field.h"
  #include "codeengine/code_object.h"
  #include "codeengine/code_engine_result.h"
  #include "codeengine/code_engine_session.h"
  #include "codeengine/code_engine_feedback.h"
  #include "codeengine/code_engine.h"

%}

%rename("%(lowercamelcase)s", %$isvariable) "";

%exception {
  try {
    $action
  } catch (const se::common::BaseException& e) {
        SWIG_exception(SWIG_RuntimeError, (std::string("CRITICAL: Base exception caught: ") + ": " + e.what()).c_str());
  } catch (const std::exception& e) {
        SWIG_exception(SWIG_RuntimeError, (std::string("CRITICAL!: STL exception caught: ") + e.what()).c_str());
  } catch (...) {
        SWIG_exception(SWIG_RuntimeError, "CRITICAL!: Unknown exception caught");
  }
}

%newobject se::code::CodeEngine::Create;
%newobject se::code::CodeEngine::CreateFromEmbeddedBundle;
%newobject se::code::CodeEngine::GetDefaultSessionSettings;
%newobject se::code::CodeEngine::SpawnSession;
%newobject se::code::CodeEngineSessionSettings::Clone;

%ignore ConstructFromImpl;
%ignore GetImpl;
%ignore GetMutableImpl;
// %ignore CodeEngineSessionSettings;


%include "codeengine/code_engine_session_settings.h"
%include "codeengine/code_object_field.h"
%include "codeengine/code_object.h"
%include "codeengine/code_engine_result.h"
%include "codeengine/code_engine_session.h"
%include "codeengine/code_engine_feedback.h"
%include "codeengine/code_engine.h"