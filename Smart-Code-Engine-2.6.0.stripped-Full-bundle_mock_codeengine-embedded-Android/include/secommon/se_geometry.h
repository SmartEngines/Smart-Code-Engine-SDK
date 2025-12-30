/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

/**
 * @file se_geometry.h
 * @brief Basic geometric classes and procedures for secommon library
 */

#ifndef SECOMMON_SE_GEOMETRY_H_INCLUDED
#define SECOMMON_SE_GEOMETRY_H_INCLUDED

#include <secommon/se_export_defs.h>
#include <secommon/se_serialization.h>

namespace se { namespace common {

/**
 * @brief Class representing a rectangle in an image
 */
class SE_DLL_EXPORT Rectangle {
public:
  /// Default ctor - initializes rectangle with zero-valued fields
  Rectangle();

  /// Main ctor - initializes all fields of a rectangle
  Rectangle(int x, int y, int width, int height);

  /// Serialize rectangle given serializer object
  void Serialize(Serializer& serializer) const;

  /// Internal serialization implementation
  void SerializeImpl(SerializerImplBase& serializer_impl) const;

public:
  int x;      ///< X-coordinate of the top-left corner (in pixels)
  int y;      ///< Y-coordinate of the top-left corner (in pixels)
  int width;  ///< Width of the rectangle (in pixels)
  int height; ///< Height of the rectangle (in pixels)
};


/**
 * @brief Class representing a point in an image
 */
class SE_DLL_EXPORT Point {
public:
  /// Default ctor - initializes a point with zero-valued coordinates
  Point();

  /// Main ctor - initializes both coordinates
  Point(double x, double y);

  /// Serialize point given serializer object
  void Serialize(Serializer& serializer) const;

  /// Internal serialization implementation
  void SerializeImpl(SerializerImplBase& serializer_impl) const;

public:
  double x; ///< X-coordinate of the point (in pixels)
  double y; ///< Y-coordinate of the point (in pixels)
};


/**
 * @brief Class representing a size of the (rectangular) object
 */
class SE_DLL_EXPORT Size {
public:
  /// Default ctor - initializes size with zero-valued fields
  Size();

  /// Main ctor - initializes all fields
  Size(int width, int height);

  /// Serialize size given serializer object
  void Serialize(Serializer& serializer) const;

  /// Internal serialization implementation
  void SerializeImpl(SerializerImplBase& serializer_impl) const;

public:
  int width;  ///< Width
  int height; ///< Height
};


/**
 * @brief Class representing a quadrangle in an image
 */
class SE_DLL_EXPORT Quadrangle {
public:
  /// Default ctor - initializes quadrangle with all points pointing to zero
  Quadrangle();

  /// Main ctor - initializes all four points of the quadrangle
  Quadrangle(const Point& a, const Point& b, const Point& c, const Point& d);

  /// Mutable subscript getter for a point (indices from 0 to 3)
  Point& operator[](int index);

  /// Subscript getter for a point (indices from 0 to 3)
  const Point& operator[](int index) const;

  /// Getter for a point (indices from 0 to 3)
  const Point& GetPoint(int index) const;

  /// Mutable getter for a point (indices from 0 to 3)
  Point& GetMutablePoint(int index);

  /// Setter for a point (indices from 0 to 3)
  void SetPoint(int index, const Point& p);

  /// Calculates, creates, and returns a bounding rectangle for the quadrangle
  Rectangle GetBoundingRectangle() const;

  /// Serialize rectangle given serializer object
  void Serialize(Serializer& serializer) const;

  /// Internal serialization implementation
  void SerializeImpl(SerializerImplBase& serializer_impl) const;

private:
  Point pts_[4]; ///< Constituent points
};

/// QuadranglesMapIterator internal implementation forward declaration
class QuadranglesMapIteratorImpl;

/**
 * @brief QuadranglesMapIterator: iterator object for maps of named quadrangles
 */
class SE_DLL_EXPORT QuadranglesMapIterator {
private:
  /// Private ctor from internal implementation
  QuadranglesMapIterator(const QuadranglesMapIteratorImpl& pimpl);

public:
  /// Copy ctor
  QuadranglesMapIterator(const QuadranglesMapIterator& other);

  /// Assignment operator
  QuadranglesMapIterator& operator =(const QuadranglesMapIterator& other);

  /// Non-trivial dtor
  ~QuadranglesMapIterator();

  /// Construction of the iterator object from internal implementation
  static QuadranglesMapIterator ConstructFromImpl(
      const QuadranglesMapIteratorImpl& pimpl);

  /// Returns the name of the quadrangle
  const char* GetKey() const;

  /// Returns the target quadrangle
  const Quadrangle& GetValue() const;

  /// Returns true iff the rvalue iterator points to the same object
  bool Equals(const QuadranglesMapIterator& rvalue) const;

  /// Returns true iff the rvalue iterator points to the same object
  bool operator ==(const QuadranglesMapIterator& rvalue) const;

  /// Returns true iff the rvalue iterator points to a different object
  bool operator !=(const QuadranglesMapIterator& rvalue) const;

  /// Points an iterator to the next object a the collection
  void Advance();

  /// Points an iterator to the next object a the collection
  void operator ++();

private:
  class QuadranglesMapIteratorImpl* pimpl_; ///< Internal implementation
};

class RectanglesVectorIteratorImpl;

class SE_DLL_EXPORT RectanglesVectorIterator {
private:
  /// Private ctor from internal implementation
  RectanglesVectorIterator(const RectanglesVectorIteratorImpl& pimpl);

public:
  /// Copy ctor
  RectanglesVectorIterator(const RectanglesVectorIterator& other);

  /// Assignment operator
  RectanglesVectorIterator& operator =(const RectanglesVectorIterator& other);

  /// Non-trivial dtor
  ~RectanglesVectorIterator();

  /// Construction of the iterator object from internal implementation
  static RectanglesVectorIterator ConstructFromImpl(
      const RectanglesVectorIteratorImpl& pimpl);

  /// Returns the target rectangle
  const Rectangle& GetValue() const;

  /// Returns true iff the rvalue iterator points to the same object
  bool Equals(const RectanglesVectorIterator& rvalue) const;

  /// Returns true if the rvalue iterator points to the same object
  bool operator ==(const RectanglesVectorIterator& rvalue) const;

  /// Returns true if the rvalue iterator points to a different object
  bool operator !=(const RectanglesVectorIterator& rvalue) const;

  /// Points an iterator to the next object a the collection
  void Advance();

  /// Points an iterator to the next object a the collection
  void operator ++();

private:
  class RectanglesVectorIteratorImpl* pimpl_; ///< Internal implementation
};

/**
 * @brief Class representing a polygon in an image
 */
class SE_DLL_EXPORT Polygon {
public:
  /// Default ctor - initializes a polygon with no points
  Polygon();

  /// Main ctor - initializes a polygon with points array (points are copied)
  Polygon(const Point* points, int points_count);

  /// Copy ctor - copies all points of the other polygon
  Polygon(const Polygon& other);

  /// Assignment operator - copies all points of the other polygon
  Polygon& operator =(const Polygon& other);

  /// Dtor (non-trivial)
  ~Polygon();

  /// Returns the number of points in the polygon
  int GetPointsCount() const;

  /// Returns a pointer to the first point in the polygon
  const Point* GetPoints() const;

  /// Mutable subscript getter for a point by an index
  Point& operator [](int index);

  /// Subscript getter for a point by an index
  const Point& operator [](int index) const;

  /// Getter for a point by an index
  const Point& GetPoint(int index) const;

  /// Mutable getter for a point by an index
  Point& GetMutablePoint(int index);

  /// Setter for a point by an index
  void SetPoint(int index, const Point& p);

  /// Resizes in internal array of points. If size is different from the
  ///         current size, the new array is allocated. Old points are copied,
  ///         new points are initialized with zero coordinates (if upsized)
  void Resize(int size);

  /// Calculates, creates, and returns a bounding rectangle for the polygon
  Rectangle GetBoundingRectangle() const;

  /// Serialize quadrangle given serializer object
  void Serialize(Serializer& serializer) const;

  /// Internal serialization implementation
  void SerializeImpl(SerializerImplBase& serializer_impl) const;

private:
  int pts_cnt_; ///< Number of points
  Point* pts_;  ///< Points array
};


/**
 * @brief Class representing projective transformation of a plane
 */
class SE_DLL_EXPORT ProjectiveTransform {
public:
  using Raw2dArrayType = double[3][3]; ///< type declaration for internal matrix

public:

  /**
   * @brief Returns true, iff the projective transform can be defined which
   *        transforms the quad 'src_quad' to the quad 'dst_quad'
   * @param src_quad transformation source
   * @param dst_quad transformation destination
   * @return true iff such transform can be defined and constructed
   */
  static bool CanCreate(const Quadrangle& src_quad, const Quadrangle& dst_quad);

  /**
   * @brief Returns true, iff the projective transform can be defined which
   *        transforms the quad 'src_quad' to an orthotropic rectangle
   *        with size 'dst_size'
   * @param src_quad transformation source
   * @param dst_size linear sizes of the transformation destionation
   * @return true iff such transform can be defined and constructed
   */
  static bool CanCreate(const Quadrangle& src_quad, const Size& dst_size);

  /**
   * @brief Creates a unit transformation
   * @return Unit transformation object
   */
  static ProjectiveTransform* Create();

  /**
   * @brief Creates a transformation which transforms the quad 'src_quad' to
   *        the quad 'dst_quad'
   * @param src_quad transformation source
   * @param dst_quad transformation destination
   * @return Created transform
   */
  static ProjectiveTransform* Create(
      const Quadrangle& src_quad,
      const Quadrangle& dst_quad);

  /**
   * @brief Create a transformation which transforms the quad 'src_quad' to an
   *        orthotropic rectangle with size 'dst_size'
   * @param src_quad transformation source
   * @param dst_size linear sizes of the transformation destination
   * @return Created transform
   */
  static ProjectiveTransform* Create(
      const Quadrangle& src_quad,
      const Size&       dst_size);

  /**
   * @brief Creates a transformation given raw matrix
   * @param coeffs transformation matrix
   * @return Created transform
   */
  static ProjectiveTransform* Create(const Raw2dArrayType& coeffs);

public:
  /// Default dtor
  virtual ~ProjectiveTransform() = default;

  /// Copies transform object
  virtual ProjectiveTransform* Clone() const = 0;

  /// Transforms an input point
  virtual Point TransformPoint(const Point& p) const = 0;

  /// Transforms an input quadrangle
  virtual Quadrangle TransformQuad(const Quadrangle& q) const = 0;

  /// Transforms an input polygon
  virtual Polygon TransformPolygon(const Polygon& poly) const = 0;

  /// Returns true iff the transformation is invertable
  virtual bool IsInvertable() const = 0;

  /// Inverts the projective transformation
  virtual void Invert() = 0;

  /// Creates a new object with an inverted transformation
  virtual ProjectiveTransform* CloneInverted() const = 0;

  /// Returns internal transformation matrix (constant)
  virtual const Raw2dArrayType& GetRawCoeffs() const = 0;

  /// Returns internal transformation matrix (mutable)
  virtual Raw2dArrayType& GetMutableRawCoeffs() = 0;

  /// Serializes the projective transformation given serializer object
  virtual void Serialize(Serializer& serializer) const = 0;
};


} } // namespace se::common

#endif // SECOMMON_SE_GEOMETRY_H_INCLUDED
