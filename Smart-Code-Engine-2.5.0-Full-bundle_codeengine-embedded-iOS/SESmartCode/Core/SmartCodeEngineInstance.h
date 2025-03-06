/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import <objccodeengine/code_engine.h>
#import <objccodeengine/code_engine_result.h>

#import <objcsecommon/se_image.h>

@protocol SmartCodeEngineDelegate <NSObject>
@optional
- (void) SmartCodeEngineObtainedResult:(nonnull SECodeEngineResult *)result;
- (void) SmartCodeEngineObtainedFeedback:(nonnull SECodeEngineFeedbackContainer *)feedback;

- (void) SmartCodeEngineObtainedResult:(nonnull SECodeEngineResult *)result
                 fromFrameWithBuffer:(nonnull CMSampleBufferRef)buffer;

- (void) SmartCodeEngineObtainedResult:(nonnull SECodeEngineResult *)result
                 fromFrameWithBuffer:(nonnull CMSampleBufferRef)buffer
                           processTime:(NSTimeInterval)time;

- (void) SmartCodeEngineObtainedSingleImageResult:(nonnull SECodeEngineResult *)result;
@end

@protocol SmartCodeEngineInitializationDelegate <NSObject>
@optional
- (void) SmartCodeEngineInitialized;
- (void) SmartCodeEngineVideoSessionStarted;
- (void) SmartCodeEngineVideoSessionDismissed;
@end

@interface SmartCodeEngineInstance : NSObject

@property (weak, nonatomic, nullable, readonly) id<SmartCodeEngineDelegate> engineDelegate;
@property (weak, nonatomic, nullable, readonly) id<SmartCodeEngineInitializationDelegate> initializationDelegate;

@property (strong, nullable, readonly) SECodeEngine* engine; // main configuration of Smart Code Engine
@property (strong, nullable, readonly) SECodeEngineSession* videoSession; // current video recognition session
@property (strong, nullable) SECodeEngineSessionSettings* sessionSettings; // current session settings
@property (strong, nullable) SECodeEngineSessionSettings* defaultSessionSettings; // default session settings

@property BOOL engineInitialized;
@property BOOL videoSessionRunning;
@property BOOL collectingQuadrangles;

- (NSTimeInterval) processTime;
- (int) frameNumber;

@property (nonatomic, strong, nullable) NSMutableArray<SECodeEngineFeedbackContainer *> *collectedQuadrangles;

- (nonnull instancetype) initWithSignature:(nonnull NSString *)signature;
- (void) setEngineDelegate:(nullable __weak id<SmartCodeEngineDelegate>)delegate;
- (void) setInitializationDelegate:(nullable __weak id<SmartCodeEngineInitializationDelegate>)delegate;
//
- (void) initializeEngine:(NSString *_Nullable)bundlePath;
- (void) initializeEngine;

- (void) initVideoSession;

- (void) dismissVideoSession;
- (void) dismissVideoSessionRunning;

- (void) processFrame:(nonnull CMSampleBufferRef)sampleBuffer
      withOrientation:(UIDeviceOrientation)deviceOrientation;

- (void) processFrame:(nonnull CMSampleBufferRef)sampleBuffer
      withOrientation:(UIDeviceOrientation)deviceOrientation
               andRoi:(CGRect)roi;

- (nonnull NSArray*) processSingleImage:(nonnull SECommonImageRef *)image;
- (nonnull NSArray*) processSingleImageFromFile:(nonnull NSString *)filePath;
- (nonnull NSArray*) processSingleImageFromUIImage:(nonnull UIImage *)image;

- (void) resetSessionSettings;
- (void) resetQuadrangles;
- (nullable NSMutableArray<SECodeEngineFeedbackContainer *> *) getQuadrangles;
- (bool) isCollectingQuadrangles;

@end

