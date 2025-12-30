/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef OBJCSECOMMON_SE_GEOMETRY_H_INCLUDED
#define OBJCSECOMMON_SE_GEOMETRY_H_INCLUDED

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#ifndef OBJCSECOMMON_WITHOUT_UIKIT
#import <UIKit/UIKit.h>
#endif // OBJCSECOMMON_WITHOUT_UIKIT

#import <objcsecommon/se_serialization.h>

@interface SECommonRectangle : NSObject

@property (nonatomic) int x;
@property (nonatomic) int y;
@property (nonatomic) int width;
@property (nonatomic) int height;

- (nonnull instancetype) init;
- (nonnull instancetype) initWithX:(int)x
                             withY:(int)y
                         withWidth:(int)width
                        withHeight:(int)height;

- (void) serialize:(nonnull SECommonSerializer *)serializer;

@end


@interface SECommonPoint : NSObject

@property (nonatomic) double x;
@property (nonatomic) double y;

- (nonnull instancetype) init;
- (nonnull instancetype) initWithX:(double)x
                             withY:(double)y;

- (void) serialize:(nonnull SECommonSerializer *)serializer;

@end


@interface SECommonSize : NSObject

@property (nonatomic) int width;
@property (nonatomic) int height;

- (nonnull instancetype) init;
- (nonnull instancetype) initWithWidth:(int)width
                            withHeight:(int)height;

- (void) serialize:(nonnull SECommonSerializer *)serializer;

@end


@interface SECommonQuadrangle : NSObject

- (nonnull instancetype) init;
- (nonnull instancetype) initWithPoints:(nonnull NSArray *)points;
- (nonnull SECommonPoint *) getPointAt:(int)index;
- (void) setPointAt:(int)index
                 to:(nonnull SECommonPoint *)point;
- (nonnull SECommonRectangle *) getBoundingRectangle;

- (void) serialize:(nonnull SECommonSerializer *)serializer;

#ifndef OBJCSECOMMON_WITHOUT_UIKIT
- (void) shiftPoints:(CGPoint)offsets;
- (void) preprocesssWithFrameSize:(CGSize)frameSize                 // frame size of the view for drawing
                       sourceSize:(CGSize)ssize                     // source image size
                deviceOrientation:(UIDeviceOrientation)dOrientation // orientation when frame with given quadrangle captured
             interfaceOrientation:(UIInterfaceOrientation)iOrientation // current interface orientation
                          offsets:(CGPoint)offsets                  // roi offsets
                          isFront:(BOOL)isFront;                    // mirror quads if it's front camera

- (void) rotate90ccw:(CGSize)viewSize;
- (void) rotate90cw:(CGSize)viewSize;
- (nonnull UIBezierPath *) bezierPath;
#endif // OBJCSECOMMON_WITHOUT_UIKIT

@end


@interface SECommonQuadranglesMapIterator : NSObject

- (nonnull instancetype) initWithOther:(nonnull SECommonQuadranglesMapIterator *)other;
- (BOOL) isEqualToIter:(nonnull SECommonQuadranglesMapIterator *)other;

- (nonnull NSString *) getKey;
- (nonnull SECommonQuadrangle *) getValue;
- (void) advance;

@end


@interface SECommonPolygon : NSObject

- (nonnull instancetype) init;
- (nonnull instancetype) initWithPoints:(nonnull NSArray *)points;
- (int) getPointsCount;
- (nonnull SECommonPoint *) getPointAt:(int)index;
- (void) setPointAt:(int)index
                 to:(nonnull SECommonPoint *)point;
- (void) resize:(int)size;
- (nonnull SECommonRectangle *) getBoundingRectangle;

- (void) serialize:(nonnull SECommonSerializer *)serializer;

@end


@interface SECommonProjectiveTransform : NSObject

+ (BOOL)canCreateWithSrcQuad:(nonnull SECommonQuadrangle *)src_quad
                 withDstQuad:(nonnull SECommonQuadrangle *)dst_quad;
+ (BOOL)canCreateWithSrcQuad:(nonnull SECommonQuadrangle *)src_quad
                 withDstSize:(nonnull SECommonSize *)dst_size;  

- (nonnull instancetype) init;
- (nonnull instancetype) initWithSrcQuad:(nonnull SECommonQuadrangle *)src_quad
                             withDstQuad:(nonnull SECommonQuadrangle *)dst_quad;
- (nonnull instancetype) initWithSrcQuad:(nonnull SECommonQuadrangle *)src_quad
                             withDstSize:(nonnull SECommonSize *)dst_size;
- (nonnull SECommonPoint *) transformPoint:(nonnull SECommonPoint *)point;
- (nonnull SECommonQuadrangle *) transformQuadrangle:(nonnull SECommonQuadrangle *)quad;
- (nonnull SECommonPolygon *) transformPolygon:(nonnull SECommonPolygon *)poly;
- (double) getCellAtRow:(int)row
                  atCol:(int)col;
- (void) setCellAtRow:(int)row
                atCol:(int)col
              toValue:(double)val;
- (BOOL) isInvertable;
- (void) invert;

- (void) serialize:(nonnull SECommonSerializer *)serializer;

@end

#endif // OBJCSECOMMON_SE_GEOMETRY_H_INCLUDED
