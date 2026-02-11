/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_common_proxy_impl.h>

void throwFromException(const se::common::BaseException& e) {
  NSException* exc = [NSException
      exceptionWithName:[NSString stringWithUTF8String:e.ExceptionName()]
      reason:[NSString stringWithUTF8String:e.what()]
      userInfo:nil];
  @throw exc;
}

void throwFromSTLException(const std::exception& e) {
  NSException* exc = [NSException
      exceptionWithName:@"STL Exception"
      reason:[NSString stringWithUTF8String:e.what()]
      userInfo:nil];
  @throw exc;
}

void throwNonMutableRefException() {
  NSException* exc = [NSException
      exceptionWithName:@"Reference Exception"
      reason:@"Trying to call mutating method from non-mutable ref"
      userInfo:nil];
  @throw exc;
}
