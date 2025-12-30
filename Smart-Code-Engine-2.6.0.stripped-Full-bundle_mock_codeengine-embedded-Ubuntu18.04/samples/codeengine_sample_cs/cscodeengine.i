%module(directors="1") cscodeengine
%feature("director") se::code::CodeEngineWorkflowFeedback;
%feature("director") se::code::CodeEngineVisualizationFeedback;

%include std_map.i
%include std_string.i
%include std_vector.i

%include "secommon_include.i"

%apply (char *STRING, size_t LENGTH) {(const unsigned char* bytes, size_t n)};
%apply (char *STRING, size_t LENGTH) {(const char* out_buffer, int buffer_length)};

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

%pragma(csharp) imclassimports=%{
  using se.common;
%}

%include "arrays_csharp.i"
CSHARP_ARRAYS(char, byte)

%apply unsigned char INPUT[] { unsigned char* data };
%apply unsigned char INPUT[] { unsigned char* yuv_data };
%apply unsigned char INPUT[] { unsigned char* config_data };
%apply char OUTPUT[] { char* out_buffer };

%typemap(csimports) SWIGTYPE %{
  using se.common;
%}

%exception {
  try {
    $action
  } catch (const se::common::BaseException& e) {
        SWIG_CSharpSetPendingException(static_cast<SWIG_CSharpExceptionCodes>(SWIG_RuntimeError), (std::string("Base secommon exception caught: ") + e.what()).c_str());
  } catch (const std::exception& e) {
        SWIG_CSharpSetPendingException(static_cast<SWIG_CSharpExceptionCodes>(SWIG_RuntimeError), (std::string("CRITICAL!: STL exception caught: ") + e.what()).c_str());
  } catch (...) {
        SWIG_CSharpSetPendingException(static_cast<SWIG_CSharpExceptionCodes>(SWIG_RuntimeError), "CRITICAL!: Unknown exception caught");
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

%rename("%(lowercamelcase)s", %$isvariable) "";

namespace std {
  %template(Utf16CharVector) vector<uint16_t>;
  %template(StringVector) vector<string>;
  %template(StringVector2d) vector<vector<string> >;
}

%include "codeengine/code_engine_session_settings.h"
%include "codeengine/code_object_field.h"
%include "codeengine/code_object.h"
%include "codeengine/code_engine_result.h"
%include "codeengine/code_engine_session.h"
%include "codeengine/code_engine_feedback.h"
%include "codeengine/code_engine.h"