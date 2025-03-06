/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCSECOMMON_IMPL_SE_COMMON_PROXY_H_INCLUDED
#define OBJCSECOMMON_IMPL_SE_COMMON_PROXY_H_INCLUDED

#import <Foundation/Foundation.h>

#include <secommon/se_exception.h>

#include <stdexcept>

void throwFromException(const se::common::BaseException& e);

void throwFromSTLException(const std::exception& e);

void throwNonMutableRefException();

#endif // OBJCSECOMMON_IMPL_SE_COMMON_PROXY_H_INCLUDED