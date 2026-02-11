/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

/**
 * @file se_serialization.h
 * @brief Facilities for serialization of objects
 */

#ifndef SECOMMON_SE_SERIALIZATION_H_INCLUDED
#define SECOMMON_SE_SERIALIZATION_H_INCLUDED

#include <secommon/se_export_defs.h>
#include <secommon/se_strings_iterator.h>

namespace se { namespace common {

/// Forward-declaration for internal serialization parameters implementation
class SerializationParametersImpl;

/**
 * @brief Class representing serialization parameters
 */
class SE_DLL_EXPORT SerializationParameters {
public:
  /// Default ctor
  SerializationParameters();
  /// Default dtor
  ~SerializationParameters();
  /// Copy ctor
  SerializationParameters(const SerializationParameters& copy);
  /// Assignment operator
  SerializationParameters& operator =(
      const SerializationParameters& other);

public:
  /**
   * @brief Checks whether the serialization parameters have an
   *        ignored object type
   * @param object_type the name of the object type to check
   * @return true iff the object type 'object_type' is ignored
   */
  bool HasIgnoredObjectType(const char* object_type) const;

  /**
   * @brief Adds an object type to the set of ignored
   * @param object_type the name of the object type to add
   */
  void AddIgnoredObjectType(const char* object_type);

  /**
   * @brief Removes an object type from the set of ignored
   * @param object_type the name of the object type to remove
   */
  void RemoveIgnoredObjectType(const char* object_type);

  /// Returns a begin iterator to the set of ignored object types
  se::common::StringsSetIterator IgnoredObjectTypesBegin() const;

  /// Returns an end iterator to the set of ignored object types
  se::common::StringsSetIterator IgnoredObjectTypesEnd() const;

  /**
   * @brief Checks whether the serialization parameters have an ignored key
   * @param key the name of the key to check
   * @return true iff the key 'key' is ignored
   */
  bool HasIgnoredKey(const char* key) const;

  /**
   * @brief Adds a key to the set of ignored keys
   * @param key the name of the key to add
   */
  void AddIgnoredKey(const char* key);

  /**
   * @brief Removes a key from the set of ignored keys
   * @param key the name of the key to remove
   */
  void RemoveIgnoredKey(const char* key);

  /// Returns a begin iterator to the set of ignored keys
  se::common::StringsSetIterator IgnoredKeysBegin() const;

  /// Returns an end iterator to the set of ignored keys
  se::common::StringsSetIterator IgnoredKeysEnd() const;

public:
  /// Returns an internal implementation structure
  const SerializationParametersImpl& GetImpl() const;

private:
  SerializationParametersImpl* pimpl_; ///< pointer to internal implementation
};


/// Forward-declaration of a serializer implementation
class SerializerImplBase;

/**
 * @brief Class representing the serializer object
 */
class SE_DLL_EXPORT Serializer {
public:
  /// Default dtor
  virtual ~Serializer() = default;

  /// Resets the serializer state
  virtual void Reset() = 0;

  /// Returns the serialized string
  virtual const char* GetCStr() const = 0;

  /// Returns the name of the serializer type
  virtual const char* SerializerType() const = 0;

public:
  /**
   * @brief Factory method for creating a JSON serializer object
   * @param params serialization parameters
   * @return Pointer to a constructed serializer object. New object is created,
   *         the caller is responsible for deleting it.
   */
  static Serializer* CreateJSONSerializer(
      const SerializationParameters& params);
};


} } // namespace se::common

#endif // SECOMMON_SE_SERIALIZATION_H_INCLUDED
