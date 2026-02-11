/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

/**
 * @file se_strings_iterator.h
 * @brief String iterators used in SE libraries
 */

#ifndef SECOMMON_SE_STRINGS_ITERATOR_H_INCLUDED
#define SECOMMON_SE_STRINGS_ITERATOR_H_INCLUDED

#include <secommon/se_export_defs.h>

namespace se { namespace common {


/// Forward-declaration of the strings vector iterator implementation
class StringsVectorIteratorImpl;


/**
 * @brief Iterator to a vector-like collection of strings
 */
class SE_DLL_EXPORT StringsVectorIterator {
private:
  /// Private ctor from an internal implementation structure
  StringsVectorIterator(const StringsVectorIteratorImpl& pimpl);

public:
  /// Copy ctor
  StringsVectorIterator(const StringsVectorIterator& other);

  /// Assignment operator
  StringsVectorIterator& operator =(const StringsVectorIterator& other);

  /// Non-trivial dtor
  ~StringsVectorIterator();

  /// Constructs the iterator from an internal implementation structure
  static StringsVectorIterator ConstructFromImpl(
      const StringsVectorIteratorImpl& pimpl);

  /// Gets the string value
  const char* GetValue() const;

  /// Returns true iff this instance and rvalue point to the same object
  bool Equals(const StringsVectorIterator& rvalue) const;

  /// Returns true iff this instance and rvalue point to the same object
  bool operator ==(const StringsVectorIterator& rvalue) const;

  /// Returns true iff this instance and rvalue point to the different objects
  bool operator !=(const StringsVectorIterator& rvalue) const;

  /// Shifts the iterator to the next object
  void Advance();

  /// Shifts the iterator to the next object
  void operator ++();

private:
  class StringsVectorIteratorImpl* pimpl_; ///< internal implementation
};


/// Forward-declaration of the strings set iterator implementation
class StringsSetIteratorImpl;


/**
 * @brief Iterator to a set-like collection of strings
 */
class SE_DLL_EXPORT StringsSetIterator {
private:
  /// Private ctor from an internal implementation structure
  StringsSetIterator(const StringsSetIteratorImpl& pimpl);

public:
  /// Copy ctor
  StringsSetIterator(const StringsSetIterator& other);

  /// Assignment operator
  StringsSetIterator& operator =(const StringsSetIterator& other);

  /// Non-trivial dtor
  ~StringsSetIterator();

  /// Constructs the iterator from an internal implementation structure
  static StringsSetIterator ConstructFromImpl(
      const StringsSetIteratorImpl& pimpl);

  /// Gets the string value
  const char* GetValue() const;

  /// Returns true iff this instance and rvalue point to the same object
  bool Equals(const StringsSetIterator& rvalue) const;

  /// Returns true iff this instance and rvalue point to the same object
  bool operator ==(const StringsSetIterator& rvalue) const;

  /// Returns true iff this instance and rvalue point to the different objects
  bool operator !=(const StringsSetIterator& rvalue) const;

  /// Shifts the iterator to the next object
  void Advance();

  /// Shifts the iterator to the next object
  void operator ++();

private:
  class StringsSetIteratorImpl* pimpl_; ///< internal implementation
};


/// Forward-declaration of the strings map iterator implementation
class StringsMapIteratorImpl;


/**
 * @brief Iterator to a map from strings to strings
 */
class SE_DLL_EXPORT StringsMapIterator {
private:
  /// Private ctor from an internal implementation structure
  StringsMapIterator(const StringsMapIteratorImpl& pimpl);

public:
  /// Copy ctor
  StringsMapIterator(const StringsMapIterator& other);

  /// Assignment operator
  StringsMapIterator& operator =(const StringsMapIterator& other);

  /// Non-trivial dtor
  ~StringsMapIterator();

  /// Constructs the iterator from an internal implementation structure
  static StringsMapIterator ConstructFromImpl(
      const StringsMapIteratorImpl& pimpl);

  /// Gets the string key
  const char* GetKey() const;

  /// Gets the string value
  const char* GetValue() const;

  /// Returns true iff this instance and rvalue point to the same object
  bool Equals(const StringsMapIterator& rvalue) const;

  /// Returns true iff this instance and rvalue point to the same object
  bool operator==(const StringsMapIterator& rvalue) const;

  /// Returns true iff this instance and rvalue point to the different objects
  bool operator!=(const StringsMapIterator& rvalue) const;

  /// Shifts the iterator to the next object
  void Advance();

  /// Shifts the iterator to the next object
  void operator ++();

private:
  class StringsMapIteratorImpl* pimpl_; ///< internal implementation
};


} } // namespace se::common::

#endif // SECOMMON_SE_STRINGS_ITERATOR_H_INCLUDED
