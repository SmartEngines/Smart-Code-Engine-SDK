/*
  Copyright (c) 2016-2024, Smart Engines Service LLC.
  All rights reserved.
*/

/**
 * @file  code_engine_session.h
 * @brief Smart Code Engine session object declaration.
 */

#pragma once
#ifndef CODEENGINE_CODE_ENGINE_SESSION_H_INCLUDED
#define CODEENGINE_CODE_ENGINE_SESSION_H_INCLUDED

#include <codeengine/code_engine_result.h>
#include <codeengine/code_object.h>

#include <memory>

namespace se {
namespace code {

/**
 * @brief The main processing class for the Smart Code Engine recognition
 *        functionality.
 */
class SE_DLL_EXPORT CodeEngineSession
{
public:
  /// Default dtor
  virtual ~CodeEngineSession() = default;

  /**
   * @brief Get an activation request for this session (valid for SDK built with
   * dynamic activation feature)
   * @return A string with activation request.
   */
  virtual const char* GetActivationRequest() = 0;

  /**
   * @brief Activate current session (valid for SDK built with dynamic
   * activation feature)
   * @param activation_response the response from activation server.
   */
  virtual void Activate(const char* activation_response) = 0;

  /**
   * @brief Check if current session was activated (valid for SDK built with
   * dynamic activation feature)
   * @return Boolean check (true/false).
   */
  virtual bool IsActivated() const = 0;

  /**
   * @brief Processes the input image (or frame).
   * @param image the input image (or a frame of a video sequence)
   * @return The updated recognition result.
   */
  virtual const CodeEngineResult& Process(const common::Image& image) = 0;

  /// Returns the current recognition result.
  virtual const CodeEngineResult& GetCurrentResult() const = 0;

  /// Returns true iff the current recognition result is terminal.
  virtual bool IsResultTerminal() const = 0;

  /// Resets the session state.
  virtual void Reset() = 0;
};

} // namespace code
} // namespace se

#endif // CODEENGINE_CODE_ENGINE_SESSION_H_INCLUDED
