/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

/**
 * @file se_exception.h
 * @brief Exception classes for secommon library
 */

#ifndef SECOMMON_SE_EXCEPTION_H_INCLUDED
#define SECOMMON_SE_EXCEPTION_H_INCLUDED

#include <secommon/se_export_defs.h>

namespace se { namespace common {

/**
 * @brief BaseException class - base class for all SE exeptions. Cannot be
 *        created directly.
 */
class SE_DLL_EXPORT BaseException {
public:
  /// Non-trivial dtor
  virtual ~BaseException();

  /// Copy ctor
  BaseException(const BaseException& copy);

  /// Returns exception class name
  virtual const char* ExceptionName() const;

  /// Returns exception message
  virtual const char* what() const;

protected:
  /// Protected ctor
  BaseException(const char* msg);

private:
  char* msg_; ///< stored exception message
};


/**
 * @brief InvalidKeyException: thrown if to an associative container the access
 *        is performed with an invalid or a non-existent key, or if the access
 *        to a list is performed with an invalid or out-of-range index
 */
class SE_DLL_EXPORT InvalidKeyException : public BaseException {
public:
  /// Ctor with an exception message
  InvalidKeyException(const char* msg);

  /// Copy ctor
  InvalidKeyException(const InvalidKeyException& copy);

  /// Default dtor
  virtual ~InvalidKeyException() override = default;

  /// Returns exception class name
  virtual const char* ExceptionName() const override;
};


/**
 * @brief NotSupportedException: thrown when trying to access a method which
 *        given the current state or given the passed arguments is not supported
 *        in the current version of the library or is not supported
 *        at all by design
 */
class SE_DLL_EXPORT NotSupportedException : public BaseException {
public:
  /// Ctor with an exception message
  NotSupportedException(const char* msg);

  /// Copy ctor
  NotSupportedException(const NotSupportedException& copy);

  /// Default dtor
  virtual ~NotSupportedException() override = default;

  /// Returns exception class name
  virtual const char* ExceptionName() const override;
};


/**
 * @brief FileSystemException: thrown if an attempt is made to read from a
 *        non-existent file, or other file-system related IO error.
 */
class SE_DLL_EXPORT FileSystemException : public BaseException {
public:
  /// Ctor with an exception message
  FileSystemException(const char* msg);

  /// Copy ctor
  FileSystemException(const FileSystemException& copy);

  /// Default dtor
  virtual ~FileSystemException() override = default;

  /// Returns exception class name
  virtual const char* ExceptionName() const override;
};


/**
 * @brief UninitializedObjectException: thrown if an attempt is made to access
 *        a non-existent or non-initialized object
 */
class SE_DLL_EXPORT UninitializedObjectException : public BaseException {
public:
  /// Ctor with an exception message
  UninitializedObjectException(const char* msg);

  /// Copy ctor
  UninitializedObjectException(const UninitializedObjectException& copy);

  /// Default dtor
  virtual ~UninitializedObjectException() override = default;

  /// Returns exception class name
  virtual const char* ExceptionName() const override;
};


/**
 * @brief InvalidArgumentException: thrown if a method is called with invalid
 *        input parameters
 */
class SE_DLL_EXPORT InvalidArgumentException : public BaseException {
public:
  /// Ctor with an exception message
  InvalidArgumentException(const char* msg);

  /// Copy ctor
  InvalidArgumentException(const InvalidArgumentException& copy);

  /// Default dtor
  virtual ~InvalidArgumentException() override = default;

  /// Returns exception class name
  virtual const char* ExceptionName() const override;
};


/**
 * @brief MemoryException: thrown if an allocation is attempted with
 *                         insufficient RAM
 */
class SE_DLL_EXPORT MemoryException : public BaseException {
public:
  /// Ctor with an exception message
  MemoryException(const char* msg);

  /// Copy ctor
  MemoryException(const MemoryException& copy);

  /// Default dtor
  virtual ~MemoryException() override = default;

  /// Returns exception class name
  virtual const char* ExceptionName() const override;
};


/**
 * @brief InvalidStateException: thrown if an error occurs within the system
 *        in relation to an incorrect internal state of the system objects
 */
class SE_DLL_EXPORT InvalidStateException : public BaseException {
public:
  /// Ctor with an exception message
  InvalidStateException(const char* msg);

  /// Copy ctor
  InvalidStateException(const InvalidStateException& copy);

  /// Default dtor
  virtual ~InvalidStateException() override = default;

  /// Returns exception class name
  virtual const char* ExceptionName() const override;
};


/**
 * @brief InternalException: thrown if an unknown error occurs or if the error
 *        occurs within internal system components
 */
class SE_DLL_EXPORT InternalException : public BaseException {
public:
  /// Ctor with an exception message
  InternalException(const char* msg);

  /// Copy ctor
  InternalException(const InternalException& copy);

  /// Default dtor
  virtual ~InternalException() override = default;

  /// Returns exception class name
  virtual const char* ExceptionName() const override;
};


} } // namespace se::common

#endif // SECOMMON_SE_EXCEPTION_H_INCLUDED
