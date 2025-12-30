/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

/**
 * @file se_image.h
 * @brief secommon library Image
 */

#ifndef SECOMMON_SE_IMAGE_H_INCLUDED
#define SECOMMON_SE_IMAGE_H_INCLUDED

#include <secommon/se_export_defs.h>
#include <secommon/se_geometry.h>
#include <secommon/se_serialization.h>
#include <secommon/se_string.h>

#include <secommon/se_images_iterator.h>

namespace se { namespace common {

/**
 * @brief Image pixel format enum - only these formats are supported
 */
enum SE_DLL_EXPORT ImagePixelFormat {
  IPF_G = 0,     ///< Greyscale
  IPF_GA,        ///< Greyscale + Alpha
  IPF_AG,        ///< Alpha + Greyscale
  IPF_RGB,       ///< RGB
  IPF_BGR,       ///< BGR
  IPF_BGRA,      ///< BGR + Alpha
  IPF_ARGB,      ///< Alpha + RGB
  IPF_RGBA       ///< RGB + Alpha
};

/**
 * @brief The YUVType enum - YUV subtypes for extended YUV decoding
 */
enum SE_DLL_EXPORT YUVType {
  YUVTYPE_UNDEFINED = 0,  ///< No format
  YUVTYPE_NV21 = 1,       ///< NV 21
  YUVTYPE_420_888 = 2     ///< YUV 420 888
};

/**
 * @brief The YUVDimensions struct - extended YUV parameters
 */
class SE_DLL_EXPORT YUVDimensions {
public:
  /// Default ctor
  YUVDimensions();

  /// Main ctor
  YUVDimensions(int y_pixel_stride,
                int y_row_stride,
                int u_pixel_stride,
                int u_row_stride,
                int v_pixel_stride,
                int v_row_stride,
                int width,
                int height,
                YUVType type);

  int y_plane_pixel_stride; ///< Y plane pixel stride
  int y_plane_row_stride;   ///< Y plane row stride
  int u_plane_pixel_stride; ///< U plane pixel stride
  int u_plane_row_stride;   ///< U plane row stride
  int v_plane_pixel_stride; ///< V plane pixel stride
  int v_plane_row_stride;   ///< V plane row stride
  int width;                ///< image width in pixels
  int height;               ///< image height in pixels
  YUVType type;             ///< YUV format type
};

/**
 * @brief Class representing bitmap image
 */
class SE_DLL_EXPORT Image {
public:
  /**
   * @brief Returns the number of pages in an image
   * @param image_filename path to an imag file
   * @return the number of pages in an image
   */
  static int GetNumberOfPages(const char* image_filename);

  /**
   * @brief   Returns the name of the specified page.
   * @param   image_filename     The filename of the image to process.
   * @param   page_number        0-based page number.
   * @return  Separate page filename.
   */
  static MutableString GetImagePageName(const char *image_filename,
                                        int page_number);

  /**
   * @brief Factory method for creating an empty image
   * @return Pointer to a created image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  static Image* CreateEmpty();

  /**
   * @brief Factory method for loading an image from file.
   *        Will be treated as IPF_G or IPF_RGB.
   * @param image_filename path to an image file (png, jpg, tif)
   * @param page_number page number (0 by default)
   * @param max_size maximum image size in pixels (0 for unrestricted)
   * @return Pointer to a created image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  static Image* FromFile(
      const char* image_filename,
      const int   page_number = 0,
      const Size& max_size = Size(25000, 25000));

  /**
   * @brief Factory method for loading an image from file pre-loaded in a buffer
   *        Will be treated as IPF_G or IPF_RGB.
   * @param data pointer to a loaded file buffer
   * @param data_length size of the loaded file buffer
   * @param page_number page number (0 by default)
   * @param max_size maximum image size in pixels (0 for unrestricted)
   * @return Pointer to a created image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  static Image* FromFileBuffer(
      unsigned char* data,
      int            data_length,
      const int      page_number = 0,
      const Size&    max_size = Size(25000, 25000));

  /**
   * @brief Factory method for loading an image from uncompressed pixels buffer,
   *        with UINT8 channel container. Copies the buffer internally.
   *        Buffers with types IPF_G, IPF_RGB, and IPF_BGRA are assumed.
   * @param raw_data - pointer to a pixels buffer
   * @param raw_data_length size of the pixels buffer
   * @param width width of the image in pixels
   * @param height height of the image in pixels
   * @param stride size of an image row in bytes (including alignment)
   * @param channels number of channels per-pixel
   * @return Pointer to a created image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  static Image* FromBuffer(
      unsigned char* raw_data,
      int            raw_data_length,
      int            width,
      int            height,
      int            stride,
      int            channels);

  /**
   * @brief Factory method for loading an image from an uncompressed pixel
   *        buffer with extended settings. Copies the buffer internally.
   * @param raw_data pointer to a pixels buffer
   * @param raw_data_length size of the pixels buffer
   * @param width width of the image in pixels
   * @param height height of the image in pixels
   * @param stride size of an image row in bytes (including alignment)
   * @param pixel_format pixel format
   * @param bytes_per_channel size of a pixel component in bytes
   * @return Pointer to a created image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  static Image* FromBufferExtended(
      unsigned char*   raw_data,
      int              raw_data_length,
      int              width,
      int              height,
      int              stride,
      ImagePixelFormat pixel_format,
      int              bytes_per_channel);

  /**
   * @brief Factory method for loading an image from YUV NV21 buffer
   * @param yuv_data pointer to YUV NV21 buffer
   * @param yuv_data_length size of the YUV NV21 buffer
   * @param width width of the image in pixels
   * @param height height of the image in pixels
   * @return Pointer to a created image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  static Image* FromYUVBuffer(
      unsigned char* yuv_data,
      int            yuv_data_length,
      int            width,
      int            height);


  /**
   * @brief Factory method for loading an image from a universal YUV buffer.
   * @param y_plane         pointer to Y plane buffer
   * @param y_plane_length  Y plane buffer length
   * @param u_plane         pointer to U plane buffer
   * @param u_plane_length  U plane buffer length
   * @param v_plane         pointer to V plane buffer
   * @param v_plane_length  V plane buffer length
   * @param dimensions      YUV parameters and dimensions
   * @return Pointer to a created image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  static Image* FromYUV(
      unsigned char*       y_plane,
      int                  y_plane_length,
      unsigned char*       u_plane,
      int                  u_plane_length,
      unsigned char*       v_plane,
      int                  v_plane_length,
      const YUVDimensions& dimensions);

  /**
   * @brief Factory method for loading an image from file pre-loaded in a buffer
   *        encoded as a Base64 string. Will be treated as IPF_G or IPF_RGB.
   * @param base64_buffer pointer to a base64 file buffer
   * @param page_number page number (0 by default)
   * @param max_size maximum image size in pixels (0 for unrestricted)
   * @return Pointer to a created image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  static Image* FromBase64Buffer(
      const char* base64_buffer, 
      const int   page_number = 0,
      const Size& max_size = Size(25000, 25000));

public:
  /// Default dtor
  virtual ~Image() = default;

  /**
   * @brief Gets the number of additional layers
   * @return The number of layers
   */
  virtual int GetNumberOfLayers() const = 0;

  /**
  * @brief Gets the additional layer by the specified name
  * @param name the name of the required layer
  * @return The layer
  */
  virtual const Image& GetLayer(const char* name) const = 0;

  /**
  * @brief Gets the additional layer by the specified name
  * @param name the name of the required layer
  * @return The pointer to the layer
  */
  virtual const Image* GetLayerPtr(const char* name) const = 0;

  /**
  * @brief Gets the 'begin' map iterator to the internal layers collection
  * @return The 'begin' map iterator to the internal layers collection
  */
  virtual ImagesMapIterator LayersBegin() const = 0;

  /**
  * @brief Gets the 'end' map iterator to the internal layers collection
  * @return The 'end' map iterator to the internal layers collection
  */
  virtual ImagesMapIterator LayersEnd() const = 0;

  /**
  * @brief Checks whether the Image contains the layer with the specified name
  * @param name the name of the required layer
  * @return whether the Image contains the layer with the specified name
  */
  virtual bool HasLayer(const char* name) const = 0;

  /**
  * @brief Checks whether the Image contains the layers
  * @return whether the Image contains the layers
  */
  virtual bool HasLayers() const = 0;

  /**
  * @brief Removes the layer with the specified name
  * @param name the name of the removable layer
  */
  virtual void RemoveLayer(const char* name) = 0;

  /// Clears the internal layers collection
  virtual void RemoveLayers() = 0;

  /**
  * @brief Add the image with the specified name to the internal layers collection 
  *        with copying of the pixels of the given image.
  * @param name the name of the new layer
  * @param image the value of the new layer
  */
  virtual void SetLayer(const char* name, const Image& image) = 0;

  /**
  * @brief Add the image with the specified name to the internal layers collection
  *        by transfering the given image to the internal layers collection. 
  *        The caller has to release the ownership of the set image.
  * @param name the name of the new layer
  * @param image the pointer to the value of the new layer
  */
  virtual void SetLayerWithOwnership(const char* name, Image* image) = 0;

public:
  /**
   * @brief Clones an image with copying of all pixels
   * @return Pointer to a cloned image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneDeep() const = 0;

  /**
   * @brief Clones an image without copying the pixels. The cloned image will
   *        be a separate object without memory ownership, the operations with
   *        it will be invalid if the source is deallocated.
   * @return Pointer to a cloned image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneShallow() const = 0;

  /// Clears the internal image structure
  virtual void Clear() = 0;

  /**
   * @brief Gets the required buffer length for copying the image pixels into
   *        an external pixels buffer
   * @return Number of required bytes
   */
  virtual int GetRequiredBufferLength() const = 0;

  /**
   * @brief Copies the image pixels
   * @param buffer pointer to an output pixels buffer
   * @param buffer_length available buffer size. Must be at least the size
   *        returned by the GetRequiredBufferLength() method.
   * @return The number of written bytes
   */
  virtual int CopyToBuffer(unsigned char* buffer, int buffer_length) const = 0;

#ifndef STRICT_DATA_CONTAINMENT
  /**
   * @brief Saves the image to an external file (png, jpg, tif). Format is
   *        deduced from the filename extension
   * @param image_filename filename to save the image
   */
  virtual void Save(const char* image_filename) const = 0;
#endif // #ifndef STRICT_DATA_CONTAINMENT

  /**
   * @brief Returns required buffer size for Base64 JPEG representation of an
   *        image. WARNING: will perform one extra JPEG encoding of an image
   * @return Buffer size in bytes.
   */
  virtual int GetRequiredBase64BufferLength() const = 0;

  /**
   * @brief Copies the Base64 JPEG representation of an image to an external
   *        buffer.
   * @param out_buffer output buffer for Base64 JPEG representation
   * @param buffer_length available buffer size. Must be at least the size
   *        return by the GetRequiredBase64BufferLength() method.
   * @return The number of written bytes.
   */
  virtual int CopyBase64ToBuffer(
      char* out_buffer, int buffer_length) const = 0;

  /**
   * @brief Returns Base64 JPEG representation of an image
   * @return Base64 JPEG representation in a MutableString form
   */
  virtual MutableString GetBase64String() const = 0;

  /**
   * @brief Estimates focus score of an image
   * @param quantile the derivatives quantile used to estimate focus score
   * @return Focus score of an image
   */
  virtual double EstimateFocusScore(double quantile = 0.95) const = 0;

  /**
   * @brief Scale the image to a new size
   * @param new_size new size of the image
   */
  virtual void Resize(const Size& new_size) = 0;

  /**
   * @brief Clones the image scaled to a new size
   * @param new_size new size of the image
   * @return Pointer to a scaled image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneResized(const Size& new_size) const = 0;

  /**
   * @brief Projectively crops a region of image, with approximate selection
   *        of the cropped image size
   * @param quad quadrangle in the image for cropping.
   */

  virtual void Crop(const Quadrangle& quad) = 0;

  /**
   * @brief Clones the image projectively cropped with approximate selection
   *        of the target image size
   * @param quad quadrangle in the image for cropping
   * @return Pointer to a cropped image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneCropped(const Quadrangle& quad) const = 0;

  /**
   * @brief Projectively crops a region of image, with a given target size.
   * @param quad quadrangle in the image for cropping
   * @param size target cropped image size
   */
  virtual void Crop(const Quadrangle& quad, const Size& size) = 0;

  /**
   * @brief Clones the image projectively cropped with a given target size
   * @param quad quadrangle in the image for cropping
   * @param size target cropped image size
   * @return Pointer to a cropped image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneCropped(const Quadrangle& quad, const Size& size) const = 0;

  /**
   * @brief Crops an image to a rectangular image region
   * @param rect rectangular region to crop
   */
  virtual void Crop(const Rectangle& rect) = 0;

  /**
   * @brief Clones the image cropped to a selected rectangular region
   *        (with copying of pixels)
   * @param rect rectangular region to crop
   * @return Pointer to a cropped image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneCropped(const Rectangle& rect) const = 0;

  /**
   * @brief Clones the image cropped to a selected rectangular region, without
   *        copying of pixels. The cloned image will be a separate object
   *        without memory ownership, the operations with it will be invalid if
   *        the source is deallocated.
   * @param rect rectangular region to crop
   * @return Pointer to a cropped image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneCroppedShallow(const Rectangle& rect) const = 0;

  /**
   * @brief Masks image region specified by rectangle
   * @param rect rectangle region to mask
   * @param pixel_expand expand offset in pixels for each point (0 by default)
   * @param pixel_density reduce dencity of pixels (0 by default)
   */
  virtual void Mask(const Rectangle& rect, int pixel_expand = 0, double pixel_density = 0) = 0;

  /**
   * @brief Clone the image with masked region specified by rectangle
   * @param rect rectangle region to mask
   * @param pixel_expand expand offset in pixels for each point (0 by default)
   * @return Pointer to a masked image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneMasked(const Rectangle& rect, int pixel_expand = 0) const = 0;

  /**
   * @brief Mask image region specified by quadrangle
   * @param quad quadrangle region to mask
   * @param pixel_expand expand offset in pixels for each point (0 by default)
   */
  virtual void Mask(const Quadrangle& quad, int pixel_expand = 0, double pixel_density = 0) = 0;

  /**
   * @brief Clone the image with masked region specified by quadrangle
   * @param quad quadrangle region to mask
   * @param pixel_expand expand offset in pixels for each point (0 by default)
   * @param pixel_density reduce dencity of pixels (0 by default)
   * @return Pointer to a masked image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneMasked(const Quadrangle& quad, int pixel_expand = 0) const = 0;

  /**
  * @brief Fills image region specified by rectangle and color. The method will use
  * the first as many channel values as there are channels in the image
  * @param rect rectangle region to fill
  * @param ch1 1-st channel value
  * @param ch2 2-nd channel value
  * @param ch3 3-rd channel value
  * @param ch4 4-th channel value
  * @param pixel_expand expand offset in pixels for each point (0 by default)
  */
  virtual void Fill(const Rectangle& rect, int ch1, int ch2 = 0, int ch3 = 0, int ch4 = 0, int pixel_expand = 0) = 0;

  /**
   * @brief Clone the image with filled region specified by rectangle and color. The method will use
   * the first as many channel values as there are channels in the image
   * @param rect rectangle region to fill
   * @param ch1 1-st channel value
   * @param ch2 2-nd channel value
   * @param ch3 3-rd channel value
   * @param ch4 4-th channel value
   * @param pixel_expand expand offset in pixels for each point (0 by default)
   * @return Pointer to a filled image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneFilled(const Rectangle& rect, int ch1, int ch2 = 0, int ch3 = 0, int ch4 = 0, int pixel_expand = 0) const = 0;

  /**
   * @brief Fill image region specified by quadrangle and color. The method will use
   * the first as many channel values as there are channels in the image
   * @param quad quadrangle region to fill
   * @param ch1 1-st channel value
   * @param ch2 2-nd channel value
   * @param ch3 3-rd channel value
   * @param ch4 4-th channel value
   * @param pixel_expand expand offset in pixels for each point (0 by default)
   */
  virtual void Fill(const Quadrangle& quad, int ch1, int ch2 = 0, int ch3 = 0, int ch4 = 0, int pixel_expand = 0) = 0;

  /**
   * @brief Clone the image with filled region specified by quadrangle and color. The method will use
   * the first as many channel values as there are channels in the image
   * @param quad quadrangle region to fill
   * @param ch1 1-st channel value
   * @param ch2 2-nd channel value
   * @param ch3 3-rd channel value
   * @param ch4 4-th channel value
   * @param pixel_expand expand offset in pixels for each point (0 by default)
   * @return Pointer to a filled image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneFilled(const Quadrangle& quad, int ch1, int ch2 = 0, int ch3 = 0, int ch4 = 0, int pixel_expand = 0) const = 0;

  /**
   * @brief Flips an image around the vertical axis
   */
  virtual void FlipVertical() = 0;

  /**
   * @brief Clones the image flipped around the vertical axis
   * @return Pointer to a flipped image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneFlippedVertical() const = 0;

  /**
   * @brief Flips an image around the horizontal axis
   */
  virtual void FlipHorizontal() = 0;

  /**
   * @brief Clones the image flipped around the horizontal axis
   * @return Pointer to a flipped image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneFlippedHorizontal() const = 0;

  /**
   * @brief Rotates the image clockwise by a multiple of 90 degrees
   * @param times the number of times to rotate
   */
  virtual void Rotate90(int times) = 0;

  /**
   * @brief Clones the image rotated clockwise by a multiple of 90 degrees
   * @param times the number of times to rotate
   * @return Pointer to a rotated image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneRotated90(int times) const = 0;

  /**
   * @brief Makes a single-channel image with averaged intensity values
   */
  virtual void AverageChannels() = 0;

  /**
   * @brief Clones the image with averaged channel intensity values
   * @return Pointer to a created image. New object is allocated, the caller
   *         is responsible for deleting it.
   */
  virtual Image* CloneAveragedChannels() const = 0;

  /**
   * @brief Inverts the colors of the image
   */
  virtual void Invert() = 0;

  /**
   * @brief Clones the image with inverted colos
   * @return Pointer to a created image. New object is allocated, the caller
   *         is responsible for deleting it
   */
  virtual Image* CloneInverted() const = 0;

  /// Gets the image width in pixels
  virtual int GetWidth() const = 0;

  /// Gets the image height in pixels
  virtual int GetHeight() const = 0;

  /// Gets the image size in pixels
  virtual Size GetSize() const = 0;

  /// Gets the number of image row in bytes, including alignment
  virtual int GetStride() const = 0;

  /// Gets the number of channels per pixel
  virtual int GetChannels() const = 0;

  /// Gets the pointer to the pixels buffer
  virtual void* GetUnsafeBufferPtr() const = 0;

  /// Returns whether this instance owns and will release pixel data
  virtual bool IsMemoryOwner() const = 0;

  /// Forces memory ownership - allocates new image data and copies the pixels
  virtual void ForceMemoryOwner() = 0;

  /// Serializes the image given the serializer object
  virtual void Serialize(Serializer& serializer) const = 0;
};


} } // namespace se::common

#endif // SECOMMON_SE_IMAGE_H_INCLUDED
