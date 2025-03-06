/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCSECOMMON_IMPL_SE_IMAGE_H_INCLUDED
#define OBJCSECOMMON_IMPL_SE_IMAGE_H_INCLUDED

#import <objcsecommon/se_image.h>

#include <secommon/se_image.h>

@interface SECommonImageRef (Internal)

- (instancetype) initFromInternalImagePointer:(se::common::Image *)imptr
                           withMutabilityFlag:(BOOL)mutabilityFlag;
- (se::common::Image *) getInternalImagePointer;

@end

@interface SECommonImage (Internal)

- (instancetype) initFromCreatedInternalImagePointer:(se::common::Image *)imptr;
- (const se::common::Image &) getInternalImage;

@end

#endif // OBJCSECOMMON_IMPL_SE_IMAGE_H_INCLUDED