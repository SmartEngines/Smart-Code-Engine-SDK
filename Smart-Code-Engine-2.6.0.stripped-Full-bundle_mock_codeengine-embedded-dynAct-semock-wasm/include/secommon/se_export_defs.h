/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

/**
 * @file se_export_defs.h
 * @brief Export-related definitions for secommon library
 */

#ifndef SECOMMON_SE_EXPORT_DEFS_H_INCLUDED
#define SECOMMON_SE_EXPORT_DEFS_H_INCLUDED

#if defined _WIN32 && SE_EXPORTS
# define SE_DLL_EXPORT __declspec(dllexport)
#else // defined _WIN32 && SE_EXPORTS
# if defined(__clang__) || defined(__GNUC__)
#  define SE_DLL_EXPORT __attribute__ ((visibility ("default")))
# else // clang of gnuc
#  define SE_DLL_EXPORT
# endif // clang of gnuc
#endif // defined _WIN32 && SE_EXPORTS

#endif // SECOMMON_SE_EXPORT_DEFS_H_INCLUDED
