/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

/**
 * @file se_images_iterator.h
 * @brief Image iterators used in SE libraries
 */

#ifndef SECOMMON_SE_IMAGES_ITERATOR_H_INCLUDED
#define SECOMMON_SE_IMAGES_ITERATOR_H_INCLUDED

#include <secommon/se_export_defs.h>

namespace se { namespace common {


/// Forward-declaration of the images map iterator implementation
class Image;
class ImagesMapIteratorImpl;

/**
 * @brief Iterator to a map from images to images
 */
class SE_DLL_EXPORT ImagesMapIterator {
private:
  /// Private dtor from an internal implementation structure
  ImagesMapIterator(const ImagesMapIteratorImpl& pimpl);

public:
  /// Copy ctor
  ImagesMapIterator(const ImagesMapIterator& other);

  /// Assignment operator
  ImagesMapIterator& operator =(const ImagesMapIterator& other);

  /// Non-trivial dtor
  ~ImagesMapIterator();

  /// Constructs the iterator from an internal implementation structure
  static ImagesMapIterator ConstructFromImpl(
      const ImagesMapIteratorImpl& pimpl);

  /// Gets the string key
  const char* GetKey() const;

  /// Gets the image value
  const Image& GetValue() const;

  /// Gets the pointer to the image value
  const Image* GetValuePtr() const;

  /// Returns true iff this instance and rvalue point to the same object
  bool Equals(const ImagesMapIterator& rvalue) const;

  /// Returns true iff this instance and rvalue point to the same object
  bool operator==(const ImagesMapIterator& rvalue) const;

  /// Returns true iff this instance and rvalue point to the different objects
  bool operator!=(const ImagesMapIterator& rvalue) const;

  /// Shifts the iterator to the next object
  void Advance();

  /// Shifts the iterator to the next object
  void operator ++();

private:
  class ImagesMapIteratorImpl* pimpl_; ///< internal implementation
};


} } // namespace se::common::

#endif // SECOMMON_SE_IMAGES_ITERATOR_H_INCLUDED
