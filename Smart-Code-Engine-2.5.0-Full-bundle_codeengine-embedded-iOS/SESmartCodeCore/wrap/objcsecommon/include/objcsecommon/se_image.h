/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCSECOMMON_SE_IMAGE_H_INCLUDED
#define OBJCSECOMMON_SE_IMAGE_H_INCLUDED

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#ifndef OBJCSECOMMON_WITHOUT_UIKIT
#import <UIKit/UIImage.h>
#endif // OBJCSECOMMON_WITHOUT_UIKIT

#import <objcsecommon/se_geometry.h>
#import <objcsecommon/se_serialization.h>

typedef enum {
  SECommonImagePixelFormat_G,
  SECommonImagePixelFormat_GA,
  SECommonImagePixelFormat_AG,
  SECommonImagePixelFormat_RGB,
  SECommonImagePixelFormat_BGR,
  SECommonImagePixelFormat_BGRA,
  SECommonImagePixelFormat_ARGB,
  SECommonImagePixelFormat_RGBA
} SECommonImagePixelFormat;

@class SECommonImage;

@interface SECommonImageRef : NSObject

- (BOOL) isMutable;

#ifndef OBJCSECOMMON_WITHOUT_UIKIT
- (nonnull UIImage *) convertToUIImage;
#endif // OBJCSECOMMON_WITHOUT_UIKIT

- (nonnull SECommonImage *) cloneDeep;
- (nonnull SECommonImage *) cloneShallow;

- (void) clear;

- (int) getRequiredBufferLength;
- (int) copyToBuffer:(nonnull unsigned char *)buffer
    withBufferLenght:(int)buffer_length;

#ifndef STRICT_DATA_CONTAINMENT
- (void) saveToFile:(nonnull NSString *)image_filename;
#endif // STRICT_DATA_CONTAINMENT

- (int) getRequiredBase64BufferLength;
- (int) copyToBase64Buffer:(nonnull char *)out_buffer
          withBufferLength:(int)buffer_length;
- (nonnull NSString *) getBase64String;

- (double) estimateFocusScore;
- (double) estimateFocusScoreWithQuantile:(double)quantile;

- (void) resizeTo:(nonnull SECommonSize *)new_size;
- (nonnull SECommonImage *) cloneResizedTo:(nonnull SECommonSize *)new_size;

- (void) cropToQuadrangle:(nonnull SECommonQuadrangle *)quad;
- (nonnull SECommonImage *) cloneCroppedToQuadrangle:(nonnull SECommonQuadrangle *)quad;

- (void) cropToQuadrangle:(nonnull SECommonQuadrangle *)quad
                   toSize:(nonnull SECommonSize *)size;
- (nonnull SECommonImage *) cloneCroppedToQuadrangle:(nonnull SECommonQuadrangle *)quad
                                              toSize:(nonnull SECommonSize *)size;

- (void) cropToRectangle:(nonnull SECommonRectangle *)rect;
- (nonnull SECommonImage *) cloneCroppedToRectangle:(nonnull SECommonRectangle *)rect;
- (nonnull SECommonImage *) cloneCroppedToRectangleShallow:(nonnull SECommonRectangle *)rect;

- (void) maskRectangle:(nonnull SECommonRectangle *)rect
       withPixelExpand:(int)pixel_expand;
- (nonnull SECommonImage *) cloneWithMaskedRectangle:(nonnull SECommonRectangle *)rect
                                     withPixelExpand:(int)pixel_expand;

- (void) maskQuadrangle:(nonnull SECommonQuadrangle *)quad
        withPixelExpand:(int)pixel_expand;
- (nonnull SECommonImage *) cloneWithMaskedQuadrangle:(nonnull SECommonQuadrangle *)quad
                                      withPixelExpand:(int)pixel_expand;

- (void) flipVertical;
- (nonnull SECommonImage *) cloneFlippedVertical;

- (void) flipHorizontal;
- (nonnull SECommonImage *) cloneFlippedHorizontal;

- (void) rotate90:(int)times;
- (nonnull SECommonImage *) cloneRotated90:(int)times;

- (void) averageChannels;
- (nonnull SECommonImage *) cloneAveragedChannels;

- (void) invert;
- (nonnull SECommonImage *) cloneInverted;

- (int) getWidth;
- (int) getHeight;
- (nonnull SECommonSize *) getSize;
- (int) getStride;
- (int) getChannels;
- (BOOL) isMemoryOwner;
- (void) forceMemoryOwner;

- (void) serialize:(nonnull SECommonSerializer *)serializer;

@end


@interface SECommonImage : NSObject

- (nonnull instancetype) init;

- (nonnull instancetype) initFromFile:(nonnull NSString *)image_filename
                          withMaxSize:(nullable SECommonSize *)max_size;

- (nonnull instancetype) initFromFileBuffer:(nonnull unsigned char *)data
                             withDataLength:(int)data_length
                                withMaxSize:(nullable SECommonSize *)max_size;

- (nonnull instancetype) initFromRawBuffer:(nonnull unsigned char *)raw_data
                         withRawDataLength:(int)raw_data_length
                                 withWidth:(int)width
                                withHeight:(int)height
                                withStride:(int)stride
                              withChannels:(int)channels;

- (nonnull instancetype) initFromRawBufferExtended:(nonnull unsigned char *)raw_data
                                 withRawDataLength:(int)raw_data_length
                                         withWidth:(int)width
                                        withHeight:(int)height
                                        withStride:(int)stride
                              withImagePixelFormat:(SECommonImagePixelFormat)pixel_format
                               withBytesPerChannel:(int)bytes_per_channel;

- (nonnull instancetype) initFromYUVBuffer:(nonnull unsigned char *)yuv_data
                         withYUVDataLength:(int)yuv_data_length
                                 withWidth:(int)width
                                withHeight:(int)height;

- (nonnull instancetype) initFromBase64Buffer:(nonnull NSString *)base64_buffer
                                  withMaxSize:(nullable SECommonSize *)max_size;

- (nonnull instancetype) initFromBase64BufferAsUTF8String:(nonnull const char *)base64_buffer
                                              withMaxSize:(nullable SECommonSize *)max_size;

- (nonnull instancetype) initFromSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer;

#ifndef OBJCSECOMMON_WITHOUT_UIKIT
- (nonnull instancetype) initFromUIImage:(nonnull UIImage *)image;
#endif // OBJCSECOMMON_WITHOUT_UIKIT

- (nonnull SECommonImageRef *) getRef;
- (nonnull SECommonImageRef *) getMutableRef;

@end

#endif // OBJCSECOMMON_SE_IMAGE_H_INCLUDED
