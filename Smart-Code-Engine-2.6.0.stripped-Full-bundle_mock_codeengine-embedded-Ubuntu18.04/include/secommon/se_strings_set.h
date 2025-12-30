/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

/**
 * @file se_strings_set.h
 * @brief String set used in SE libraries
 */

#ifndef SECOMMON_SE_STRINGS_SET_H_INCLUDED
#define SECOMMON_SE_STRINGS_SET_H_INCLUDED

#include <secommon/se_export_defs.h>
#include <secommon/se_strings_iterator.h>

namespace se { namespace common {


/**
 * @brief A read-only set-like collection of strings
 */
class SE_DLL_EXPORT StringsSet {
public:
  /// Default dtor
  virtual ~StringsSet() = default;

  /// Returns the number of strings in the set
  virtual int GetStringsCount() const = 0;

  /// Return true iff the given string is in the set
  virtual bool HasString(const char* string) const = 0;

  /// Returns a begin-iterator to the set of strings
  virtual StringsSetIterator StringsBegin() const = 0;

  /// Returns an end-iterator to the set of strings
  virtual StringsSetIterator StringsEnd() const = 0;
};


} } // namespace se::common::

#endif // SECOMMON_SE_STRINGS_SET_H_INCLUDED
