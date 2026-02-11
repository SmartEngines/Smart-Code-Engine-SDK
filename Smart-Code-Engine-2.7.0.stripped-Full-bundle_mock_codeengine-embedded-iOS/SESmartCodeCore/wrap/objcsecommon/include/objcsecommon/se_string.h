/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCSECOMMON_SE_STRING_H_INCLUDED
#define OBJCSECOMMON_SE_STRING_H_INCLUDED

#import <Foundation/Foundation.h>

#import <objcsecommon/se_geometry.h>
#import <objcsecommon/se_serialization.h>

@interface SECommonOcrCharVariant : NSObject

- (nonnull instancetype) init;
- (nonnull instancetype) initWithChar:(nonnull NSString *)character 
                             withConf:(double)confidence;
- (nonnull NSString *) getCharacter;
- (void) setCharacterTo:(nonnull NSString *)character;
- (double) getConfidence;
- (void) setConfidence:(double)confidence;

- (void) serialize:(nonnull SECommonSerializer *)serializer;

@end


@interface SECommonOcrChar : NSObject

- (nonnull instancetype) init;
- (nonnull instancetype) initWithVariants:(nonnull NSArray *)variants
                        withIsHighlighted:(BOOL)is_highlighted
                           withQuadrangle:(nonnull SECommonQuadrangle *)quad;
- (int) getVariantsCount;
- (nonnull SECommonOcrCharVariant *) getVariantAt:(int)index;
- (void) setVariantAt:(int)index
                   to:(nonnull SECommonOcrCharVariant *)var;
- (void) resize:(int)size;
- (BOOL) getIsHighlighted;
- (void) setIsHighlightedTo:(BOOL)is_highlighed;
- (nonnull SECommonQuadrangle *) getQuadrangle;
- (void) setQuadrangleTo:(nonnull SECommonQuadrangle *)quad;
- (void) sortVariants;
- (nonnull SECommonOcrCharVariant *) getFirstVariant;

- (void) serialize:(nonnull SECommonSerializer *)serializer;

@end


@interface SECommonOcrString : NSObject

- (nonnull instancetype) init;
- (nonnull instancetype) initWithString:(nonnull NSString *)string;
- (nonnull instancetype) initWithChars:(nonnull NSArray *)chars;
- (int) getCharsCount;
- (nonnull SECommonOcrChar *) getCharAt:(int)index;
- (void) setCharAt:(int)index
                to:(nonnull SECommonOcrChar *)ocrchar;
- (void) unpackChars;
- (void) repackChars;
- (void) appendChar:(nonnull SECommonOcrChar *)ocrchar;
- (void) appendString:(nonnull SECommonOcrString *)string;
- (void) resize:(int)size;
- (void) sortVariants;
- (nonnull NSString *) getFirstString;

- (void) serialize:(nonnull SECommonSerializer *)serializer;

@end


@interface SECommonByteString : NSObject

- (nonnull instancetype) init;
- (int) getLength;
- (int) getRequiredBase64BufferLength;
- (nonnull NSString *) getBase64String;
- (int) getRequiredHexBufferLength;
- (nonnull NSString *) getHexString;

@end

#endif // OBJCSECOMMON_SE_STRING_H_INCLUDED
