/*
  Copyright (c) 2016-2024, Smart Engines Service LLC.
  All rights reserved.
*/

/**
 * @file code_engine.h
 * @brief Smart Code Engine main class declaration.
 */

#ifndef CODEENGINE_CODE_ENGINE_H_INCLUDED
#define CODEENGINE_CODE_ENGINE_H_INCLUDED

#include <codeengine/code_engine_feedback.h>
#include <codeengine/code_engine_session.h>
#include <codeengine/code_engine_session_settings.h>
#include <codeengine/code_object_field.h>
#include <codeengine/code_object.h>

#include <secommon/se_export_defs.h>
#include <secommon/se_geometry.h>
#include <secommon/se_image.h>

namespace se {
namespace code {

enum SE_DLL_EXPORT CodeEngineType
{
  CodeEngine_Barcode = (1 << 1),       ///< Barcode engine
  CodeEngine_CodeTextLine = (1 << 2),  ///< CodeTextLine engine
  CodeEngine_MRZ = (1 << 3),           ///< MRZ engine
  CodeEngine_BankCard = (1 << 4),      ///< BankCard engine
  CodeEngine_PaymentDetails = (1 << 5),///< PaymentDetails engine
  CodeEngine_LicensePlate = (1 << 6),   ///< LicensePlate engine
  CodeEngine_ContainerRecog= (1 << 7)   ///< ContainerRecog engine
};

enum class SE_DLL_EXPORT EngineSettingsGroup
{
  Global = 1 << 1,
  Barcode = 1 << 2,
  Card = 1 << 3,
  CodeTextLine = 1 << 4,
  Mrz = 1 << 5,
  PaymentDetails = 1 << 6,
  LicensePlate = 1 << 7,
  ContainerRecog = 1 << 8
};

enum class SE_DLL_EXPORT BarcodePreset
{
  GS1 = 1 << 1,
  AAMVA = 1 << 2,
  URL = 1 << 3,
  VCARD = 1 << 4,
  EMAIL = 1 << 5,
  ICALENDAR = 1 << 6,
  PHONE = 1 << 7,
  SMS = 1 << 8,
  ISBN = 1 << 9,
  WIFI = 1 << 10,
  GEO = 1 << 11,
  PAYMENT = 1 << 12,
  NONE = 1 << 13
};

SE_DLL_EXPORT EngineSettingsGroup
engineSettingsGroupFromString(const char* group_name);

SE_DLL_EXPORT const char *
toString(EngineSettingsGroup group);

SE_DLL_EXPORT const char *
presetToString(BarcodePreset preset);

/**
 * @brief The main CodeEngine class containing all configuration
 *        and resources of the Smart Code Engine product.
 */
class SE_DLL_EXPORT CodeEngine
{
public:
  /**
   * @brief The factory method for creating the CodeEngine object with a
   *        configuration bundle file.
   * @param config_path filesystem path to a engine configuration bundle.
   */
  static CodeEngine* Create(const char* config_path,
                            bool lazy_configuration = true);

  /**
   * @brief The factory method for creating the CodeEngine object with a
   *        configuration bundle buffer.
   * @param config_data pointer to the configuration bundle file buffer.
   * @param config_data_length size of the configuration buffer in bytes.
   */
  static CodeEngine* Create(const unsigned char* config_data,
                            int config_data_length,
                            bool lazy_configuration = true);

  /**
   * @brief The factory method for creating the CodeEngine object with an
   *        embedded bundle configuration.
   */
  static CodeEngine* CreateFromEmbeddedBundle(bool lazy_configuration = true);

  /**
   * @brief Default dtor.
   */
  virtual ~CodeEngine() = default;

  /**
   * @brief Returns the CodeEngine version number.
   */
  static const char* GetVersion();

  /**
   * @brief Creates a minimal valid SessionSettings object with default session
   *        processing settings.
   * @return A newly created CodeSessionSettings object. The object is
   *         allocated, the caller is responsible for deleting it.
   */
  virtual CodeEngineSessionSettings* GetDefaultSessionSettings() = 0;

  /**
   * @brief Spawns a new code object recognition session.
   * @param object_type which object types should be recognized in the spawned
   *        session.
   * @param settings a settings object which is used to spawn a session.
   * @param signature a unique caller signature to unlock the internal
   *        library calls (provided with your SDK package).
   * @param workflow_reporter an optional pointer to the implementation of
   *        workflow feedback callbacks class.
   * @param visualization_reporter an optional pointer to the implementation
   *        of visualization feedback callbacks class.
   * @return A newly created session object. The object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual CodeEngineSession* SpawnSession(
    const CodeEngineSessionSettings& settings,
    const char* signature,
    CodeEngineWorkflowFeedback* workflow_reporter = nullptr,
    CodeEngineVisualizationFeedback* visualization_reporter =
      nullptr) const = 0;

  /**
   * @brief Checks if the selected engine is available for user.
   * @return Bool value if engine is available.
   */
  virtual bool IsEngineAvailable(CodeEngineType engine_type) const = 0;
};

} // namespace code
} // namespace se

#endif // CODEENGINE_CODE_ENGINE_H_INCLUDED
