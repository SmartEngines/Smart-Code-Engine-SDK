/*
  Copyright (c) 2016-2024, Smart Engines Service LLC.
  All rights reserved.
*/

/**
 * @file code_object.h
 * @brief Smart Code Engine object class declaration.
 */

#pragma once
#ifndef CODEENGINE_CODE_OBJECT_H_INCLUDED
#define CODEENGINE_CODE_OBJECT_H_INCLUDED

#include <codeengine/code_object_field.h>

#include <stdint.h>

namespace se {
namespace code {

/**
 * @brief The enumeration to encode the possible types of codified objects
 *        which could be detected and recognized by Smart Code Engine.
 */
enum SE_DLL_EXPORT CodeObjectType
{
  CodeObject_LinearBarcode = (1 << 1),  ///< Any type of 1D barcode
  CodeObject_MatrixBarcode = (1 << 2),  ///< Any type of 2D barcode
  CodeObject_CodeTextLine = (1 << 3),   ///< Printed or handwritten codified text line
  CodeObject_MRZ = (1 << 4),            ///< Any type of machine-readable zone
  CodeObject_BankCard = (1 << 5),       ///< Any type of bank card
  CodeObject_PaymentDetails = (1 << 6), ///< Printed payment details
  CodeObject_Face = (1 << 7),           ///< Human face
  CodeObject_Container = (1 << 8)       ///< Collection of printed codefield text line
};

/**
 * @brief The class representing the internal structure of a detected and
 *        recognized codified object.
 */
class SE_DLL_EXPORT CodeObject
{
public:
  /// Default ctor -- creates an empty code object.
  CodeObject();

  /**
   * @brief Main ctor of code object.
   * @param name name of the code object.
   * @param is_accepted the code object accept flag.
   * @param confidence the code object confidence in range [0.0, 1.0]
   */
  CodeObject(const char* name,
             CodeObjectType object_type,
             bool is_accepted = false,
             float confidence = 0.0);

  /// Copy ctor
  CodeObject(const CodeObject& other);

  /// Assignment operator
  CodeObject& operator=(const CodeObject& other);

  /// Non-trivial dtor
  ~CodeObject();

  /// Comparison operator
  bool operator==(const CodeObject& other) const;

  /// Comparison operator
  bool operator!=(const CodeObject& other) const;

public:
  ///// BASIC FIELDS /////

  /// Unique identifier of an object within the recognition session
  int GetID() const;

  /// Type of the codified object
  CodeObjectType GetType() const;

  /// Type of the codified object in string format
  const char* GetTypeStr() const;

  /// Returns codified object name.
  const char* GetName() const;

  /// Returns true iff the system is confident with the object processing result
  bool IsAccepted() const;

  /// Returns true iff the object was accepted by a user-defined validator
  bool IsValidated() const;

  /// Returns system's confidence in the object processing (in range [0.0, 1.0])
  float GetConfidence() const;

  /// Sets the index of the frame where the object was initially detected
  void SetFirstDetectedFrame(int frame_number);

  /// Sets the index of the frame where the object was last updated
  void SetLastUpdatedFrame(int frame_number);

  /// Returns the index of the frame where the object was initially detected
  int GetFirstDetectedFrame() const;

  /// Returns the index of the frame where the object was last updated
  int GetLastUpdatedFrame() const;

  /// Returns true iff the system considers this the final result
  bool GetIsTerminal() const;

  /// Sets the terminality of the object
  void SetIsTerminal(bool is_terminal);

  ///// GEOMETRY /////

  /// Returns true iff the object has an associated quadrangle
  bool HasQuadrangle() const;

  /// Quadrangle of the object on the frame where the object was last updated
  const common::Quadrangle& GetQuadrangle() const;

  /// Sets the codified object quadrangle.
  void SetQuadrangle(const common::Quadrangle& quad);

  /// Returns true iff the object has an associated image
  bool HasImage() const;

  /// Image of the object, may be sourced from any frame
  const common::Image& GetImage() const;

  /// Set image of the object
  void SetImage(const common::Image& img);

  /// Remove image of the object.
  void RemoveImage();

  /// Returns the number of internal object components
  int GetComponentsCount() const;

  /// Returns an internal object component (quadrangle) by its name
  const common::Quadrangle& GetComponent(const char* comp_name) const;

  /// Set component to internal object by its name
  void SetComponent(const char* comp_name, const common::Quadrangle& comp);

  /// Returns true iff there exists a component with a provided name
  bool HasComponent(const char* comp_name) const;

  /// Returns the 'begin' map-like iterator to the internal components
  common::QuadranglesMapIterator ComponentsBegin() const;

  /// Returns the 'end' map-like iterator to the internal components
  common::QuadranglesMapIterator ComponentsEnd() const;

  ///// DECODED OR RECOGNIZED FIELDS /////

  /// Returns the number of code fields
  int GetFieldsCount() const;

  /// Returns the code field with a given name
  const CodeField& GetField(const char* field_name) const;

  /// Sets code field with a given name.
  void SetField(const char* field_name, const CodeField& code_field);

  /// Returns true iff there exists a code field with a provided name
  bool HasField(const char* field_name) const;

  /// Remove code field with a given name.
  void RemoveField(const char* field_name);

  /// Returns the 'begin' map-like iterator to the code fields
  CodeFieldsMapIterator FieldsBegin() const;

  /// Returns the 'end' map-like iterator to the code fields
  CodeFieldsMapIterator FieldsEnd() const;

  ///// KEY-VALUE ATTRIBUTES /////

  /// Gets the number of object's attributes
  int GetAttributesCount() const;

  /// Returns the field attribute by its name
  const char* GetAttribute(const char* attr_name) const;

  /// Returns true iff the object has the attribute with a given name
  bool HasAttribute(const char* attr_name) const;

  /// Sets the field's attribute by name
  void SetAttribute(const char* attr_name, const char* attr_value);

  /// Returns the 'begin' iterator to the collection of the object attributes
  se::common::StringsMapIterator AttributesBegin() const;

  /// Returns the 'end' iterator to the collection of the object attributes
  se::common::StringsMapIterator AttributesEnd() const;

private:
  class CodeObjectImpl* pimpl_; ///< internal implementation
};

/// Forward-declaration for CodeFieldsMapIterator internal implementation
class CodeObjectsMapIteratorImpl;

/**
 * @brief A class representing the iterator for string->code object maps
 */
class SE_DLL_EXPORT CodeObjectsMapIterator
{
private:
  /// Private ctor from the internal implementation
  CodeObjectsMapIterator(CodeObjectsMapIteratorImpl pimpl);

public:
  /// Non-trivial dtor
  ~CodeObjectsMapIterator();

  /// Copy ctor
  CodeObjectsMapIterator(const CodeObjectsMapIterator& other);

  /// Assignment operator
  CodeObjectsMapIteratorImpl& operator=(
    const CodeObjectsMapIteratorImpl& other);

  /// Factory method for creating the iterator from the internal implementation
  static CodeObjectsMapIterator ConstructFromImpl(
    CodeObjectsMapIteratorImpl pimpl);

  /// Returns the key
  const char* GetKey() const;

  /// Returns the value (the text field object)
  const CodeObject& GetValue() const;

  /// Returns true iff the current instance and other point to the same object
  bool Equals(const CodeObjectsMapIterator& rvalue) const;

  /// Returns true iff the current instance and other point to the same object
  bool operator==(const CodeObjectsMapIterator& other) const;

  /// Returns true iff the instance and rvalue other to different objects
  bool operator!=(const CodeObjectsMapIterator& other) const;

  /// Advances the iterator to the next object in the collection
  void Advance();

  /// Advances the iterator to the next object in the collection
  void operator++();

private:
  CodeObjectsMapIteratorImpl* pimpl_; ///< internal implementation
};

} // namespace code
} // namespace se

#endif // CODEENGINE_CODE_OBJECT_H_INCLUDED
