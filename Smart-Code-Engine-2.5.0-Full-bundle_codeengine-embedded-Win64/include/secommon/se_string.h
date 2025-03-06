/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

/**
 * @file se_string.h
 * @brief OcrString and related classes for secommon library
 */

#ifndef SECOMMON_SE_STRING_H_INCLUDED
#define SECOMMON_SE_STRING_H_INCLUDED

#include <cstddef>
#include <cstdint>
#include <secommon/se_export_defs.h>
#include <secommon/se_geometry.h>
#include <secommon/se_serialization.h>

namespace se { namespace common {

/**
 * @brief Class representing a mutable, memory-owner string
 */
class SE_DLL_EXPORT MutableString {
public:
  /// Default ctor, creates an empty string
  MutableString();

  /// Ctor from a C-string
  explicit MutableString(const char* c_str);

  /// Copy ctor
  MutableString(const MutableString& other);

  /// Assignment operator
  MutableString& operator =(const MutableString& other);

  /// Non-trivial dtor
  ~MutableString();

  /// Appends a string to this instance
  MutableString& operator +=(const MutableString& other);

  /// Creates a concatenation of this instance and the other string
  MutableString operator +(const MutableString& other) const;

  /// Returns an internal C-string
  const char* GetCStr() const;

  /// Returns the length of the string. WARNING: returns the number of bytes,
  /// not the number of UTF-8 characters
  int GetLength() const;

  /// Serializes the string given a serializer object
  void Serialize(Serializer& serializer) const;

  /// Internal serialization implementation
  void SerializeImpl(SerializerImplBase& serializer_impl) const;

private:
  int len_;   ///< length of the internal string in bytes
  char* buf_; ///< internal C-string
};


/**
 * @brief Class representing a possible character recognition result
 */
class SE_DLL_EXPORT OcrCharVariant {
public:
  /// Default ctor, creates an empty variant with zero confidence
  OcrCharVariant();

  /**
   * @brief Ctor from utf8-char represented as a mutable string
   * @param utf8_char utf8-character represented as a mutable string
   * @param confidence float confidence in range [0, 1]
   */
  OcrCharVariant(const MutableString& utf8_char, float confidence);

  /**
   * @brief Ctor from utf8-char represented as a C-string
   * @param utf8_char utf8-character represented as a C-string
   * @param confidence float confidence in range [0, 1]
   */
  OcrCharVariant(const char* utf8_char, float confidence);

  /// Default dtor
  ~OcrCharVariant() = default;

  /// Gets the character as a C-string
  const char* GetCharacter() const;

  /// Sets a character given a MutableString
  void SetCharacter(const MutableString& utf8_char);

  /// Sets a character given a C-string
  void SetCharacter(const char* utf8_char);

  /// Gets the confidence value
  float GetConfidence() const;

  /// Sets the confidence value (must be in range [0, 1])
  void SetConfidence(float confidence);

  /// Returns the internal score of the OcrCharVariant
  float GetInternalScore() const;

  /// Sets the internal score of the OcrCharVariant
  void SetInternalScore(float internal_score);

  /// Serializes the object given a serializer
  void Serialize(Serializer& serializer) const;

  /// Internal serialization implementation
  void SerializeImpl(SerializerImplBase& serializer_impl) const;

private:
  MutableString char_;   ///< character recognition result representation
  float conf_;           ///< confidence value
  float internal_score_; ///< internal score
};


/**
 * @brief Class representing an OCR information for a given recognized character
 */
class SE_DLL_EXPORT OcrChar {
public:
  /// Default ctor, creates an empty recognized character
  OcrChar();

  /**
   * @brief Main ctor from an array of variants
   * @param variants pointer to an array of variants
   * @param variants_count the number of variants in the array
   * @param is_highlighted highlight flag for the OcrChar
   * @param quad quadrangle of the OcrChar
   */
  OcrChar(const OcrCharVariant* variants,
          int                   variants_count,
          bool                  is_highlighted,
          const Quadrangle&     quad);

  /// Copy ctor
  OcrChar(const OcrChar& other);

  /// Assignment operator
  OcrChar& operator =(const OcrChar& other);

  /// Non-trivial dtor
  ~OcrChar();

  /// Gets the number of variants
  int GetVariantsCount() const;

  /// Gets the pointer to the variants array
  const OcrCharVariant* GetVariants() const;

  /// Returns the variant by its index (mutable ref)
  OcrCharVariant& operator [](int index);

  /// Returns the variant by its index (const ref)
  const OcrCharVariant& operator [](int index) const;

  /// Returns the variant by its index (const ref)
  const OcrCharVariant& GetVariant(int index) const;

  /// Returns the variant by its index (mutable ref)
  OcrCharVariant& GetMutableVariant(int index);

  /// Sets the variant to an array with a given index
  void SetVariant(int index, const OcrCharVariant& v);

  /// Resizes the variants array to a given size
  void Resize(int size);

  /// Returns the value of the highlight flag
  bool GetIsHighlighted() const;

  /// Sets the value of the highlight flag
  void SetIsHighlighted(bool is_highlighted);

  /// Returns the quadrangle of the OcrChar (const ref)
  const Quadrangle& GetQuadrangle() const;

  /// Returns the quadrangle of the OcrChar (mutable ref)
  Quadrangle& GetMutableQuadrangle();

  /// Sets the quadrangle of the OcrChar
  void SetQuadrangle(const Quadrangle& quad);

  /// Sorts the variants array in the descending order of confidence values
  void SortVariants();

  /// Gets the first variant of the array (const ref)
  const OcrCharVariant& GetFirstVariant() const;

  /// Serializes the object given serializer
  void Serialize(Serializer& serializer) const;

  /// Internal serialization implementation
  void SerializeImpl(SerializerImplBase& serializer_impl) const;

private:
  int vars_cnt_;          ///< number of variants
  OcrCharVariant* vars_;  ///< variants array
  bool is_highlighted_;   ///< highlight flag
  Quadrangle quad_;       ///< OcrChar quadrangle
};


/// Forward-declaration of the ocr strings implementation
class OcrStringImpl;

/**
 * @brief Class representing text string recognition result
 */
class SE_DLL_EXPORT OcrString {
private:
  /// Private ctor from an internal implementation structure
  OcrString(const OcrStringImpl& ocr_string_impl);

public:
  /// Default ctor
  OcrString();

  /**
   * @brief Ctor from utf8 C-string. Splits the utf8-string into utf8-characters
   *        and creates an OcrChar for each one
   * @param utf8_str input utf8 C-string
   */
  OcrString(const char* utf8_str);

  /**
   * @brief Ctor from an array of characters
   * @param chars array of OcrChars
   * @param chars_count the number of characters
   */
  OcrString(const OcrChar* chars, int chars_count);

  /// Copy ctor
  OcrString(const OcrString& other);

  /// Assignment operator
  OcrString& operator =(const OcrString& other);

  /// Non-trivial destructor
  ~OcrString();

  /**
   * @brief Ctor from a ptr to OcrStringImpl class
   * @param ocr_string_impl ptr to OcrStringImpl class
   */
  static OcrString ConstructFromImpl(const class OcrStringImpl& ocr_string_impl);

  /// Gets the ptr to the OcrStringImpl class (const ptr)
  const class OcrStringImpl* GetOcrStringImplPtr() const;

  /// Gets the number of characters
  int GetCharsCount() const;

  /// Gets the pointer to the characters array
  const OcrChar* GetChars() const;

  /// Gets a character by index (mutable ref)
  OcrChar& operator [](int index);

  /// Gets a character by index (const ref)
  const OcrChar& operator [](int index) const;

  /// Gets a character by index (const ref)
  const OcrChar& GetChar(int index) const;

  /// Gets a character by index (mutable ref)
  OcrChar& GetMutableChar(int index);

  /// Sets a character by index
  void SetChar(int index, const OcrChar& chr);

  /// Appends a character
  void AppendChar(const OcrChar& chr);

  /// Appends a string
  void AppendString(const OcrString& str);

  /// Resizes the internal array of characters
  void Resize(int size);

  /// Returns the quadrangle of the OcrChar
  const Quadrangle GetQuadrangleByIndex(int idx) const;

  /// Returns the confidence of the best OcrCharVariant
  float GetBestVariantConfidenceByIndex(int idx) const;

  /// Sorts the variants in each character by the descending order of confidence
  void SortVariants();

  /// Returns a string composed of the best variants from each OcrChar
  MutableString GetFirstString() const;

  /// Unpack se::common::OcrChars from se::common::OcrString
  void UnpackChars();

  /// Repack se::common::OcrChars to se::common::OcrString
  void RepackChars();

  /// Serializes the object given serializer
  void Serialize(Serializer& serializer) const;

  /// Internal serialization implementation
  void SerializeImpl(SerializerImplBase& serializer_impl) const;

private:
  OcrStringImpl* ocr_string_impl_;
};

/**
 * @brief Class representing byte string
 */
class SE_DLL_EXPORT ByteString {
public:
  /// Default ctor, creates an empty string
  ByteString();

  /// Non-trivial dtor
  ~ByteString();

  /// Ctor from a given sequence of bytes and length
  explicit ByteString(const unsigned char* bytes, size_t n);

  /// Copy ctor
  ByteString(const ByteString &other);

  /// Assignment operator
  ByteString &operator=(const ByteString &other);

  /// Swap
  void swap(ByteString &other) noexcept;

  /// Returns the number of bytes
  int GetLength() const noexcept;

  /// Returns length of base64 formated buffer
  int GetRequiredBase64BufferLength() const;

  /// Format buffer to base64
  int CopyBase64ToBuffer(char* out_buffer, int buffer_length) const;

  /// Get base64 string from buffer
  MutableString GetBase64String() const;

  /// Returns length of hex formated buffer
  int GetRequiredHexBufferLength() const;

  /// Format buffer to hex
  int CopyHexToBuffer(char* out_buffer, int buffer_length) const;

  /// Get hex string from buffer
  MutableString GetHexString() const;

private:
  size_t len_;   ///< length of the internal buffer in bytes
  uint8_t *buf_; ///< internal buffer
};

} } // namespace se::common::

#endif // SECOMMON_SE_STRING_H_INCLUDED
