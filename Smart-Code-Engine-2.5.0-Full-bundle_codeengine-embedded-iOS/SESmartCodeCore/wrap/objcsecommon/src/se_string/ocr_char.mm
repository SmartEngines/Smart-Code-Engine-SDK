/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_string_impl.h>
#import <objcsecommon_impl/se_geometry_impl.h>
#import <objcsecommon_impl/se_serialization_impl.h>
#import <objcsecommon_impl/se_common_proxy_impl.h>

#include <secommon/se_exception.h>

#include <memory>
#include <vector>

@implementation SECommonOcrChar {
  std::unique_ptr<se::common::OcrChar> internal;  
}

- (instancetype) initFromInternalOcrChar:(const se::common::OcrChar &)ocrchar {
  if (self = [super init]) {
    internal.reset(new se::common::OcrChar(ocrchar));
  }
  return self;
}

- (const se::common::OcrChar &) getInternalOcrChar {
  return *internal;
}

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(new se::common::OcrChar);
  }
  return self;
}

- (instancetype) initWithVariants:(NSArray *)variants
                withIsHighlighted:(BOOL)is_highlighted
                   withQuadrangle:(SECommonQuadrangle *)quad {
  if (self = [super init]) {
    std::vector<se::common::OcrCharVariant> internal_variants;
    for (int i = 0; i < static_cast<int>([variants count]); ++i) {
      SECommonOcrCharVariant* var = [variants objectAtIndex:i];
      if (![var isKindOfClass:[SECommonOcrCharVariant class]]) {
        NSException* exc = [NSException
            exceptionWithName:@"InvalidArgumentException"
            reason:@"OcrChar must contain variants"
            userInfo:nil];
        @throw exc;
        return nil;
      }
      internal_variants.push_back([var getInternalOcrCharVariant]);
    }
    internal.reset(new se::common::OcrChar(
        internal_variants.data(),
        static_cast<int>(internal_variants.size()),
        YES == is_highlighted,
        [quad getInternalQuadrangle]));
  }
  return self;
}

- (int) getVariantsCount {
  return internal->GetVariantsCount();
}

- (SECommonOcrCharVariant *) getVariantAt:(int)index {
  try {
    return [[SECommonOcrCharVariant alloc] initFromInternalOcrCharVariant:internal->GetVariant(index)];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) setVariantAt:(int)index
                   to:(SECommonOcrCharVariant *)var {
  try {
    return internal->SetVariant(index, [var getInternalOcrCharVariant]);
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
}

- (void) resize:(int)size {
  internal->Resize(size);
}

- (BOOL) getIsHighlighted {
  return internal->GetIsHighlighted();
}

- (void) setIsHighlightedTo:(BOOL)is_highlighed {
  internal->SetIsHighlighted(is_highlighed == true);
}

- (SECommonQuadrangle *) getQuadrangle {
  return [[SECommonQuadrangle alloc] initFromInternalQuadrangle:internal->GetQuadrangle()];
}

- (void) setQuadrangleTo:(SECommonQuadrangle *)quad {
  internal->SetQuadrangle([quad getInternalQuadrangle]);
}

- (void) sortVariants {
  internal->SortVariants();
}

- (SECommonOcrCharVariant *) getFirstVariant {
  try {
    return [[SECommonOcrCharVariant alloc] initFromInternalOcrCharVariant:internal->GetFirstVariant()];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) serialize:(SECommonSerializer *)serializer {
  internal->Serialize([serializer getInternalSerializer]);
}

@end
