/*
  Copyright (c) 2016-2024, Smart Engines Service LLC.
  All rights reserved.
*/

/**
 * @file code_engine_result.h
 * @brief Smart Code Engine recognition result class declaration.
 */

#ifndef CODEENGINE_CODE_ENGINE_RESULT_H_INCLUDED
#define CODEENGINE_CODE_ENGINE_RESULT_H_INCLUDED

#include <secommon/se_export_defs.h>

#include <codeengine/code_object.h>

namespace se {
namespace code {

/**
 * @brief The class representing the Smart Code Engine recognition result.
 */
class SE_DLL_EXPORT CodeEngineResult
{
public:
  /// Main ctor for the result object.
  CodeEngineResult(bool is_terminal = false);
  /// Copy ctor
  CodeEngineResult(const CodeEngineResult& other);
  /// Assignment operator
  CodeEngineResult& operator=(const CodeEngineResult& other);
  /// Non-trivial dtor.
  ~CodeEngineResult();

  /// Comparison operator
  bool operator==(const CodeEngineResult& other) const;

  /// Comparison operator
  bool operator!=(const CodeEngineResult& other) const;

  /// Get the number of processed objects.
  int GetObjectCount() const;
  /// Returns true iff there exists a code field with a provided name.
  bool HasObject(const char* object_name) const;
  /// Returns the code object.
  const CodeObject& GetCodeObject(const char* object_name) const;
  /// Sets the code object with a given name.
  void SetCodeObject(const char* object_name, const CodeObject& code_object);
  /// Returns the 'begin' map-like iterator to the processed code objects.
  CodeObjectsMapIterator ObjectsBegin() const;
  /// Returns the 'end' map-like iterator to the processed code objects.
  CodeObjectsMapIterator ObjectsEnd() const;
  /// Check if the result is terminal.
  bool IsTerminal() const;
  /// Sets the terminality flag for the whole result.
  void SetTerminal(bool terminal = true);
  /// Reset result
  void Reset();

private:
  struct CodeEngineResultImpl* pimpl_; ///< internal implementation
};

} // namespace code
} // namespace se

#endif // CODEENGINE_CODE_ENGINE_RESULT_H_INCLUDED
