/*
  Copyright (c) 2016-2024, Smart Engines Service LLC.
  All rights reserved.
*/

/**
 * @file code_object_field.h
 * @brief Smart Code Engine object field class declaration.
 */

#pragma once
#ifndef CODEENGINE_CODE_OBJECT_FIELD_H_INCLUDED
#define CODEENGINE_CODE_OBJECT_FIELD_H_INCLUDED

#include <secommon/se_common.h>

namespace se {
namespace code {

/**
 * @brief The class representing a value-holding field of a codified object.
 */
class SE_DLL_EXPORT CodeField
{
public:
  /// Default ctor
  CodeField();

  /**
   * @brief Ctor from byte string.
   * @param name name of code field.
   * @param byte_string value of processed byte string.
   * @param is_accepted the field's accept flag.
   * @param confidence the field's confidence (float in range [0.0, 1.0]).
   */
  CodeField(const char* name,
            const common::ByteString& byte_string,
            bool is_accepted = false,
            float confidence = 0.F);

  /**
   * @brief Ctor from OCR string.
   * @param name name of code field.
   * @param ocr_string value of processed OCR string.
   * @param is_accepted the field's accept flag.
   * @param confidence the field's confidence (float in range [0.0, 1.0]).
   */
  CodeField(const char* name,
            const common::OcrString& ocr_string,
            bool is_accepted = false,
            float confidence = 0.F);

  /// Non-trivial dtor
  ~CodeField();

  /// Copy ctor
  CodeField(const CodeField& copy);

  /// Assignment operator
  CodeField& operator=(const CodeField& other);

  /// Comporasion operator
  bool operator==(const CodeField& other) const;

public:
  /// Returns code field name.
  const char* Name() const;

  /// Sets code field name.
  void SetName(const char* name);

  /// Returns true iff the system is confident with the field processing result.
  bool IsAccepted() const;

  /// Sets the field's accept flag.
  void SetIsAccepted(const bool is_accepted);

  /// Returns system's confidence in the field processing (in range [0.0, 1.0])
  double GetConfidence() const;

  /// Sets the value of the system' confidence in the field processing (in range [0.0, 1.0]).
  void SetConfidence(const float confidence);

  /// Returns true iff the system considers this the final result of the field
  bool IsTerminal() const;

  /// Sets the field's is terminal flag.
  void SetIsTerminal(const bool is_terminal);

  /// Returns true iff the code field has a representation as a binary string
  bool HasBinaryRepresentation() const;

  /// Returns the binary representation of the code field
  const common::ByteString& GetBinaryRepresentation() const;

  /// Sets the binary representation of the code field.
  void SetBinaryRepresentation(const common::ByteString& byte_string);

  /// Returns true iff the code field has an OcrString representation
  bool HasOcrStringRepresentation() const;

  /// Returns the OcrString representation of the code field
  const common::OcrString& GetOcrString() const;

  /// Sets the OcrString representation of the code field.
  void SetOcrStringRepresentation(const common::OcrString& ocr_string);

private:
  class CodeFieldImpl* pimpl_; ///< internal implementation
};

/// Forward-declaration for CodeFieldsMapIterator internal implementation
class CodeFieldsMapIteratorImpl;

/**
 * @brief A class representing the iterator for string->code field maps
 */
class SE_DLL_EXPORT CodeFieldsMapIterator
{
private:
  /// Private ctor from the internal implementation
  CodeFieldsMapIterator(CodeFieldsMapIteratorImpl pimpl);

public:
  /// Non-trivial dtor
  ~CodeFieldsMapIterator();

  /// Copy ctor
  CodeFieldsMapIterator(const CodeFieldsMapIterator& other);

  /// Assignment operator
  CodeFieldsMapIterator& operator=(const CodeFieldsMapIterator& other);

  /// Factory method for creating the iterator from the internal implementation
  static CodeFieldsMapIterator ConstructFromImpl(
    CodeFieldsMapIteratorImpl pimpl);

  /// Returns the key
  const char* GetKey() const;

  /// Returns the value (the text field object)
  const CodeField& GetValue() const;

  /// Returns true iff the current instance and other point to the same object
  bool Equals(const CodeFieldsMapIterator& rvalue) const;

  /// Returns true iff the current instance and other point to the same object
  bool operator==(const CodeFieldsMapIterator& other) const;

  /// Returns true iff the instance and rvalue other to different objects
  bool operator!=(const CodeFieldsMapIterator& other) const;

  /// Advances the iterator to the next object in the collection
  void Advance();

  /// Advances the iterator to the next object in the collection
  void operator++();

private:
  CodeFieldsMapIteratorImpl* pimpl_; ///< internal implementation
};

} // namespace code
} // namespace se

#endif // CODEENGINE_CODE_OBJECT_FIELD_H_INCLUDED
