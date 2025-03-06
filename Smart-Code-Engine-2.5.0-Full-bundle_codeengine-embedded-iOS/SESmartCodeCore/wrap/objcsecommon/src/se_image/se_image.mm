/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_image_impl.h>
#import <objcsecommon_impl/se_geometry_impl.h>
#import <objcsecommon_impl/se_serialization_impl.h>

#import <objcsecommon_impl/se_common_proxy_impl.h>

#include <memory>

se::common::ImagePixelFormat convertFormat(SECommonImagePixelFormat pixel_format) {
  if (pixel_format == SECommonImagePixelFormat_G) {
    return se::common::IPF_G;
  }
  if (pixel_format == SECommonImagePixelFormat_GA) {
    return se::common::IPF_GA;
  }
  if (pixel_format == SECommonImagePixelFormat_AG) {
    return se::common::IPF_AG;
  }
  if (pixel_format == SECommonImagePixelFormat_RGB) {
    return se::common::IPF_RGB;
  }
  if (pixel_format == SECommonImagePixelFormat_BGR) {
    return se::common::IPF_BGR;
  }
  if (pixel_format == SECommonImagePixelFormat_BGRA) {
    return se::common::IPF_BGRA;
  }
  if (pixel_format == SECommonImagePixelFormat_ARGB) {
    return se::common::IPF_ARGB;
  }
  if (pixel_format == SECommonImagePixelFormat_RGBA) {
    return se::common::IPF_RGBA;
  }
  return se::common::IPF_G;
}

@implementation SECommonImageRef {
  se::common::Image* ptr;
  bool is_mutable;
}

- (instancetype) initFromInternalImagePointer:(se::common::Image *)imptr
                           withMutabilityFlag:(BOOL)mutabilityFlag {
  if (self = [super init]) {
    ptr = imptr;
    is_mutable = (YES == mutabilityFlag);
  }
  return self;
}

- (se::common::Image *) getInternalImagePointer {
  return ptr;
}

- (BOOL) isMutable {
  return is_mutable? YES : NO;
}

#ifndef OBJCSECOMMON_WITHOUT_UIKIT
- (UIImage *) convertToUIImage {
  NSData* data = [NSData dataWithBytes:ptr->GetUnsafeBufferPtr()
                                length:ptr->GetHeight() * ptr->GetStride()];
  CGColorSpaceRef colorSpace;
  if (ptr->GetChannels() == 1) {
    colorSpace = CGColorSpaceCreateDeviceGray();
  } else {
    colorSpace = CGColorSpaceCreateDeviceRGB();
  }

  CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
  CGImageRef imageRef = CGImageCreate(
      ptr->GetWidth(), // width
      ptr->GetHeight(),  // height
      8,  // bits per component
      8 * ptr->GetChannels(),   // bits per pixel
      ptr->GetStride(),  // bytes per row
      colorSpace, // colorspace
      kCGImageAlphaNone | kCGBitmapByteOrderDefault, // bitmap info flags
      provider, // CGDataProviderRef,
      NULL, // Decode
      false, // Should interpolate
      kCGRenderingIntentDefault); // intent

  UIImage* ret = [UIImage imageWithCGImage:imageRef
                                     scale:1.0f
                               orientation:UIImageOrientationUp];
  CGImageRelease(imageRef);
  CGDataProviderRelease(provider);
  CGColorSpaceRelease(colorSpace);
  return ret;
}
#endif // OBJCSECOMMON_WITHOUT_UIKIT

- (SECommonImage *) cloneDeep {
  try {
    return [[SECommonImage alloc] initFromCreatedInternalImagePointer:ptr->CloneDeep()];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (SECommonImage *) cloneShallow {
  try {
    return [[SECommonImage alloc] initFromCreatedInternalImagePointer:ptr->CloneShallow()];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) clear {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    ptr->Clear();
  }
}

- (int) getRequiredBufferLength {
  return ptr->GetRequiredBufferLength();
}

- (int) copyToBuffer:(unsigned char *)buffer
    withBufferLenght:(int)buffer_length {
  try {
    ptr->CopyToBuffer(buffer, buffer_length);
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return -1;
}

#ifndef STRICT_DATA_CONTAINMENT
- (void) saveToFile:(NSString *)image_filename {
  try {
    ptr->Save([image_filename UTF8String]);
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
}
#endif // STRICT_DATA_CONTAINMENT

- (int) getRequiredBase64BufferLength {
  try {
    ptr->GetRequiredBase64BufferLength();
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return -1;
}

- (int) copyToBase64Buffer:(char *)out_buffer
          withBufferLength:(int)buffer_length {
  try {
    ptr->CopyBase64ToBuffer(out_buffer, buffer_length);
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return -1;
}

- (NSString *) getBase64String {
  try {
    return [NSString stringWithUTF8String:ptr->GetBase64String().GetCStr()];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (double) estimateFocusScore {
  return [self estimateFocusScoreWithQuantile:0.95];
}

- (double) estimateFocusScoreWithQuantile:(double)quantile {
  try {
    return ptr->EstimateFocusScore(quantile);
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return -1.0;
}

- (void) resizeTo:(SECommonSize *)new_size {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    try {
      ptr->Resize([new_size getInternalSize]);
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
    }
  }
}

- (SECommonImage *) cloneResizedTo:(SECommonSize *)new_size {
  try {
    return [[SECommonImage alloc]
        initFromCreatedInternalImagePointer:ptr->CloneResized([new_size getInternalSize])];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) cropToQuadrangle:(SECommonQuadrangle *)quad {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    try {
      ptr->Crop([quad getInternalQuadrangle]);
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
    }
  }
}

- (SECommonImage *) cloneCroppedToQuadrangle:(SECommonQuadrangle *)quad {
  try {
    return [[SECommonImage alloc]
        initFromCreatedInternalImagePointer:ptr->CloneCropped([quad getInternalQuadrangle])];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) cropToQuadrangle:(SECommonQuadrangle *)quad
                   toSize:(SECommonSize *)size {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    try {
      ptr->Crop([quad getInternalQuadrangle], [size getInternalSize]);
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
    }
  }
}

- (SECommonImage *) cloneCroppedToQuadrangle:(SECommonQuadrangle *)quad
                                      toSize:(SECommonSize *)size {
  try {
    return [[SECommonImage alloc]
        initFromCreatedInternalImagePointer:ptr->CloneCropped([quad getInternalQuadrangle], [size getInternalSize])];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) cropToRectangle:(SECommonRectangle *)rect {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    try {
      ptr->Crop([rect getInternalRectangle]);
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
    }
  }
}

- (SECommonImage *) cloneCroppedToRectangle:(SECommonRectangle *)rect {
  try {
    return [[SECommonImage alloc]
        initFromCreatedInternalImagePointer:ptr->CloneCropped([rect getInternalRectangle])];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (SECommonImage *) cloneCroppedToRectangleShallow:(SECommonRectangle *)rect {
  try {
    return [[SECommonImage alloc]
        initFromCreatedInternalImagePointer:ptr->CloneCroppedShallow([rect getInternalRectangle])];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) maskRectangle:(SECommonRectangle *)rect
       withPixelExpand:(int)pixel_expand {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    try {
      ptr->Mask([rect getInternalRectangle], pixel_expand);
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
    }
  }
}

- (SECommonImage *) cloneWithMaskedRectangle:(SECommonRectangle *)rect
                             withPixelExpand:(int)pixel_expand {
  try {
    return [[SECommonImage alloc]
        initFromCreatedInternalImagePointer:ptr->CloneMasked([rect getInternalRectangle], pixel_expand)];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) maskQuadrangle:(SECommonQuadrangle *)quad
        withPixelExpand:(int)pixel_expand {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    try {
      ptr->Mask([quad getInternalQuadrangle], pixel_expand);
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
    }
  }
}

- (SECommonImage *) cloneWithMaskedQuadrangle:(SECommonQuadrangle *)quad
                              withPixelExpand:(int)pixel_expand {
  try {
    return [[SECommonImage alloc]
        initFromCreatedInternalImagePointer:ptr->CloneMasked([quad getInternalQuadrangle], pixel_expand)];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) flipVertical {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    try {
      ptr->FlipVertical();
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
    }
  }
}

- (SECommonImage *) cloneFlippedVertical {
  try {
    return [[SECommonImage alloc]
        initFromCreatedInternalImagePointer:ptr->CloneFlippedVertical()];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) flipHorizontal {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    try {
      ptr->FlipHorizontal();
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
    }
  }
}

- (SECommonImage *) cloneFlippedHorizontal {
  try {
    return [[SECommonImage alloc]
        initFromCreatedInternalImagePointer:ptr->CloneFlippedHorizontal()];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

////////////////////////

- (void) rotate90:(int)times {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    try {
      ptr->Rotate90(times);
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
    }
  }
}

- (SECommonImage *) cloneRotated90:(int)times {
  try {
    return [[SECommonImage alloc]
        initFromCreatedInternalImagePointer:ptr->CloneRotated90(times)];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

////////////////////////

- (void) averageChannels {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    try {
      ptr->AverageChannels();
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
    }
  }
}

- (SECommonImage *) cloneAveragedChannels {
  try {
    return [[SECommonImage alloc]
        initFromCreatedInternalImagePointer:ptr->CloneAveragedChannels()];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (void) invert {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    try {
      ptr->Invert();
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
    }
  }
}

- (SECommonImage *) cloneInverted {
  try {
    return [[SECommonImage alloc]
        initFromCreatedInternalImagePointer:ptr->CloneInverted()];
  } catch (const se::common::BaseException& e) {
    throwFromException(e);
  }
  return nil;
}

- (int) getWidth {
  return ptr->GetWidth();
}

- (int) getHeight {
  return ptr->GetHeight();
}

- (SECommonSize *) getSize {
  return [[SECommonSize alloc] initFromInternalSize:ptr->GetSize()];
}

- (int) getStride {
  return ptr->GetStride();
}

- (int) getChannels {
  return ptr->GetChannels();
}

- (BOOL) isMemoryOwner {
  return ptr->IsMemoryOwner()? YES: NO;
}

- (void) forceMemoryOwner {
  if (!is_mutable) {
    throwNonMutableRefException();
  } else {
    try {
      ptr->ForceMemoryOwner();
    } catch (const se::common::BaseException& e) {
      throwFromException(e);
    }
  }
}

- (void) serialize:(SECommonSerializer *)serializer {
  ptr->Serialize([serializer getInternalSerializer]);
}

@end


@implementation SECommonImage {
  std::unique_ptr<se::common::Image> internal;
}

- (instancetype) initFromCreatedInternalImagePointer:(se::common::Image *)imptr {
  if (self = [super init]) {
    internal.reset(imptr);
  }
  return self;
}

- (const se::common::Image &) getInternalImage {
  return *internal;
}

//////////////

- (instancetype) init {
  if (self = [super init]) {
    internal.reset(se::common::Image::CreateEmpty());
  }
  return self;
}

- (instancetype) initFromFile:(NSString *)image_filename
                  withMaxSize:(SECommonSize *)max_size {
  if (self = [super init]) {
    try {
      se::common::Size internal_max_size(15000, 15000);
      const int default_page_number = 0;
      if (max_size) {
        internal_max_size = [max_size getInternalSize];
      }
      internal.reset(se::common::Image::FromFile(
          [image_filename UTF8String], default_page_number, internal_max_size));
    } catch (const se::common::BaseException& e) {
      internal.reset();
      throwFromException(e);
    }
  }
  return self;
}

- (instancetype) initFromFileBuffer:(unsigned char *)data
                     withDataLength:(int)data_length
                        withMaxSize:(SECommonSize *)max_size {
  if (self = [super init]) {
    try {
      se::common::Size internal_max_size(15000, 15000);
      const int default_page_number = 0;
      if (max_size) {
        internal_max_size = [max_size getInternalSize];
      }
      internal.reset(se::common::Image::FromFileBuffer(
          data, data_length, default_page_number, internal_max_size));
    } catch (const se::common::BaseException& e) {
      internal.reset();
      throwFromException(e);
    }
  }
  return self;
}

- (instancetype) initFromRawBuffer:(unsigned char *)raw_data
                 withRawDataLength:(int)raw_data_length
                         withWidth:(int)width
                        withHeight:(int)height
                        withStride:(int)stride
                      withChannels:(int)channels {
  if (self = [super init]) {
    try {
      internal.reset(se::common::Image::FromBuffer(
          raw_data,
          raw_data_length,
          width,
          height,
          stride,
          channels));
    } catch (const se::common::BaseException& e) {
      internal.reset();
      throwFromException(e);
    }
  }
  return self;
}

- (instancetype) initFromRawBufferExtended:(unsigned char *)raw_data
                         withRawDataLength:(int)raw_data_length
                                 withWidth:(int)width
                                withHeight:(int)height
                                withStride:(int)stride
                      withImagePixelFormat:(SECommonImagePixelFormat)pixel_format
                       withBytesPerChannel:(int)bytes_per_channel {
  if (self = [super init]) {
    try {
      internal.reset(se::common::Image::FromBufferExtended(
          raw_data,
          raw_data_length,
          width,
          height,
          stride,
          convertFormat(pixel_format),
          bytes_per_channel));
    } catch (const se::common::BaseException& e) {
      internal.reset();
      throwFromException(e);
    }
  }
  return self;
}

- (instancetype) initFromYUVBuffer:(unsigned char *)yuv_data
                 withYUVDataLength:(int)yuv_data_length
                         withWidth:(int)width
                        withHeight:(int)height {
  if (self = [super init]) {
    try {
      internal.reset(se::common::Image::FromYUVBuffer(
          yuv_data,
          yuv_data_length,
          width,
          height));
    } catch (const se::common::BaseException& e) {
      internal.reset();
      throwFromException(e);
    }
  }
  return self;
}

- (instancetype) initFromBase64Buffer:(NSString *)base64_buffer
                          withMaxSize:(SECommonSize *)max_size {
  return [self initFromBase64BufferAsUTF8String:[base64_buffer UTF8String]
                                    withMaxSize:max_size];
}

- (instancetype) initFromBase64BufferAsUTF8String:(const char *)base64_buffer
                                      withMaxSize:(SECommonSize *)max_size {
  if (self = [super init]) {
    try {
      se::common::Size internal_max_size(15000, 15000);
      const int default_page_number = 0;
      if (max_size) {
        internal_max_size = [max_size getInternalSize];
      }
      internal.reset(se::common::Image::FromBase64Buffer(
          base64_buffer, default_page_number, internal_max_size));
    } catch (const se::common::BaseException& e) {
      internal.reset();
      throwFromException(e);
    }
  }
  return self;
}

- (instancetype) initFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
  if (self = [super init]) {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    uint8_t* basePtr = (uint8_t*)CVPixelBufferGetBaseAddress(imageBuffer);

    const int bytesPerRow = static_cast<int>(CVPixelBufferGetBytesPerRow(imageBuffer));
      
    const int width = static_cast<int>(CVPixelBufferGetWidth(imageBuffer));
    const int height = static_cast<int>(CVPixelBufferGetHeight(imageBuffer));
    const int channels = 4; // assuming BGRA

    if (basePtr == 0 || bytesPerRow == 0 || width == 0 || height == 0) {
      return nil;
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    try {
      internal.reset(se::common::Image::FromBufferExtended(
          basePtr,
          bytesPerRow * height,
          width,
          height,
          bytesPerRow,
          se::common::ImagePixelFormat(se::common::IPF_BGRA),
                                                           1));
    } catch (const se::common::BaseException& e) {
      internal.reset();
      throwFromException(e);
    }
  }
  return self;
}

#ifndef OBJCSECOMMON_WITHOUT_UIKIT
- (instancetype) initFromUIImage:(UIImage *)image {

  if (self = [super init]) {
    CGImageRef cgImage = [image CGImage];
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    CGImageAlphaInfo alpha_info = CGImageGetAlphaInfo(cgImage);
    size_t channels_num = CGImageGetBitsPerPixel(cgImage) / CGImageGetBitsPerComponent(cgImage);
    CFDataRef dataRef = CGDataProviderCopyData(provider);
    unsigned char* data = const_cast<unsigned char*>(CFDataGetBytePtr(dataRef));
    try {
      SECommonImagePixelFormat pixel_format;
      switch (alpha_info) {
        case kCGImageAlphaNone:
          if (channels_num == 1) {
            pixel_format = SECommonImagePixelFormat_G;
          } else {
            if (channels_num == 3) {
            pixel_format = SECommonImagePixelFormat_RGB;
            } else {
              throw(se::common::NotSupportedException("Unsupported image format"));
            }
          }
          break;
        case kCGImageAlphaLast:
          if (channels_num == 2) {
            pixel_format = SECommonImagePixelFormat_GA;
          } else {
            if (channels_num == 4){
            pixel_format = SECommonImagePixelFormat_RGBA;
            } else {
              throw(se::common::NotSupportedException("Unsupported image format"));
            }
          }
          break;
        case kCGImageAlphaFirst:
          if (channels_num == 2) {
            pixel_format = SECommonImagePixelFormat_AG;
          } else {
            if (channels_num == 4){
            pixel_format = SECommonImagePixelFormat_ARGB;
            } else {
              throw(se::common::NotSupportedException("Unsupported image format"));
            }
          }
          break;
        case kCGImageAlphaNoneSkipLast:
          if (channels_num == 2) {
            pixel_format = SECommonImagePixelFormat_GA;
          } else {
            if (channels_num == 4){
            pixel_format = SECommonImagePixelFormat_RGBA;
            } else {
              throw(se::common::NotSupportedException("Unsupported image format"));
            }
          }
          break;
        case kCGImageAlphaNoneSkipFirst:
          if (channels_num == 2) {
            pixel_format = SECommonImagePixelFormat_AG;
          } else {
            if (channels_num == 4){
            pixel_format = SECommonImagePixelFormat_ARGB;
            } else {
              throw(se::common::NotSupportedException("Unsupported image format"));
            }
          }
          break;
          case kCGImageAlphaPremultipliedLast:
          if (channels_num == 2) {
            pixel_format = SECommonImagePixelFormat_AG;
          } else {
            if (channels_num == 4){
            pixel_format = SECommonImagePixelFormat_RGBA;
            } else {
              throw(se::common::NotSupportedException("Unsupported image format"));
            }
          }
          break;
          case kCGImageAlphaPremultipliedFirst:
          if (channels_num == 2) {
            pixel_format = SECommonImagePixelFormat_AG;
          } else {
            if (channels_num == 4){
            pixel_format = SECommonImagePixelFormat_ARGB;
            } else {
              throw(se::common::NotSupportedException("Unsupported image format"));
            }
          }
          break;
          case kCGImageAlphaOnly:
              throw(se::common::NotSupportedException("Unsupported image format. No color data, alpha data only."));

          break;
        default:
          throw(se::common::NotSupportedException("Unsupported image format"));
          break;
      }
      
      int bits_per_pixel = static_cast<int>(CGImageGetBitsPerPixel(cgImage));
      int bits_per_comp = static_cast<int>(CGImageGetBitsPerComponent(cgImage));
      
      int bytes_per_comp = bits_per_comp / 8;
      
      int width = static_cast<int>(CGImageGetWidth(cgImage));
      int height = static_cast<int>(CGImageGetHeight(cgImage));
      int stride = static_cast<int>(CGImageGetBytesPerRow(cgImage));
      
      internal.reset(se::common::Image::FromBufferExtended(
          data,
          stride * height,
          width,
          height,
          stride,
          convertFormat(pixel_format),
          bytes_per_comp));

      CFRelease(dataRef);
    } catch (const se::common::BaseException& e) {
      internal.reset();
      CFRelease(dataRef);
      throwFromException(e);
    }
  }
  return self;
}
#endif // OBJCSECOMMON_WITHOUT_UIKIT

- (SECommonImageRef *) getRef {
  return [[SECommonImageRef alloc] initFromInternalImagePointer:internal.get()
                                             withMutabilityFlag:NO];
}

- (SECommonImageRef *) getMutableRef {
  return [[SECommonImageRef alloc] initFromInternalImagePointer:internal.get()
                                             withMutabilityFlag:YES];
}

@end
