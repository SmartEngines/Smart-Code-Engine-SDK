/*
  Copyright (c) 2016-2024, Smart Engines Service LLC.
  All rights reserved.
*/

/**
 * @file code_engine_feedback.h
 * @brief Smart Code Engine main feedback class declaration.
 */
#ifndef CODEENGINE_CODE_ENGINE_FEEDBACK_H_INCLUDED
#define CODEENGINE_CODE_ENGINE_FEEDBACK_H_INCLUDED

#include <secommon/se_export_defs.h>
#include <secommon/se_geometry.h>

#include <codeengine/code_engine_result.h>

namespace se {
namespace code {

/**
 * @brief The class representing the visual feedback container - a collection
 *        of named quadrangles in an image
 */
class SE_DLL_EXPORT CodeEngineFeedbackContainer
{
public:
  /// Non-trivial dtor
  ~CodeEngineFeedbackContainer();

  /// Default ctor - creates an empty container
  CodeEngineFeedbackContainer();

  /// Copy ctor
  CodeEngineFeedbackContainer(const CodeEngineFeedbackContainer& copy);

  /// Assignment operator
  CodeEngineFeedbackContainer& operator=(
    const CodeEngineFeedbackContainer& other);

public:
  /// Returns the number of quadrangles in the container
  int GetQuadranglesCount() const;

  /// Returns true iff there exists a quadrangle with a given name
  bool HasQuadrangle(const char* quad_name) const;

  /// Returns the quadrangle with a given name
  const se::common::Quadrangle& GetQuadrangle(const char* quad_name) const;

  /// Sets the quadrangle for a given name
  void SetQuadrangle(const char* quad_name, const se::common::Quadrangle& quad);

  /// Removes the quadrangle with a given name from the collection
  void RemoveQuadrangle(const char* quad_name);

  /// Returns the 'begin' map iterator to the quadrangles collection
  se::common::QuadranglesMapIterator QuadranglesBegin() const;

  /// Returns the 'end' map iterator to the quadrangles collection
  se::common::QuadranglesMapIterator QuadranglesEnd() const;

private:
  /// Internal container implementation.
  class CodeEngineFeedbackContainerImpl* pimpl_;
};

/**
 * @brief Abstract interface for receiving Smart Code Engine callbacks for
 *        visualization purposes. All callbacks must be implemented.
 */
class SE_DLL_EXPORT CodeEngineVisualizationFeedback
{
public:
  /// Virtual dtor.
  virtual ~CodeEngineVisualizationFeedback() = default;

  /// A container with a set of quadrangles for visualization.
  virtual void FeedbackReceived(
    const CodeEngineFeedbackContainer& feedback_container) = 0;
};

/**
 * @brief Abstract interface for receiving Smart Code Engine workflow callbacks.
 *        All callbacks must be implemented.
 */
class SE_DLL_EXPORT CodeEngineWorkflowFeedback
{
public:
  /// Virtual dtor.
  virtual ~CodeEngineWorkflowFeedback();

  /// This method is called when the input frame is processed by all the
  /// internal engines.
  virtual void ResultReceived(const CodeEngineResult& result_received) = 0;

  /// This method is called when the result becomes terminal.
  virtual void SessionEnded() = 0;
};

} // namespace code
} // namespace se

#endif // CODEENGINE_CODE_ENGINE_FEEDBACK_H_INCLUDED
