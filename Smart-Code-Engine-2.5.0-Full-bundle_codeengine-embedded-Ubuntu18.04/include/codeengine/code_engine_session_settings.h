/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

/**
 * @file code_engine_session_settings.h
 * @brief Smart Code Engine session settings class declaration.
 */

#ifndef CODEENGINE_CODE_ENGINE_SESSION_SETTINGS_H_INCLUDE
#define CODEENGINE_CODE_ENGINE_SESSION_SETTINGS_H_INCLUDE

#include <secommon/se_export_defs.h>
#include <secommon/se_strings_iterator.h>
#include <string>

namespace se {
namespace code {

/**
 * @brief The class representing the session settings for the Smart ID Engine
 *        document recognition functionality
 */
class SE_DLL_EXPORT CodeEngineSessionSettings
{
public:
  // CodeEngineSessionSettings();
  virtual ~CodeEngineSessionSettings();

  /**
   * @brief Clones the session settings object
   * @return A new object of session settings with an identical state. A newly
   *         created object is allocated, the caller is responsible for
   *         deleting it
   */
  virtual CodeEngineSessionSettings* Clone() const = 0;

  /// Returns the value of an option by name
  virtual const char* GetOption(const char* option_name) const = 0;

  /// Returns 'begin' like iterator for all session settings.
  virtual se::common::StringsMapIterator SettingsBegin() const = 0;

  /// Returns 'end' like iterator for all session settings.
  virtual se::common::StringsMapIterator SettingsEnd() const = 0;

  /// Return true iff there is an option with the given name
  virtual bool HasOption(const char* option_name) const = 0;

  /// Sets the key:value session option pair
  virtual void SetOption(const char* option_name, const char* option_value) = 0;
};

} // namespace code
} // namespace se

#endif // CODEENGINE_CODE_ENGINE_SESSION_SETTINGS_H_INCLUDE
