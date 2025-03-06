/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "SmartCodeEngineInstance.h"
#import "SmartIDCaptureButton.h"

@protocol SmartCodeViewControllerDelegate <NSObject>

@optional

- (void) smartCodeViewControllerDidRecognize:(nonnull SECodeEngineResult *)result
                                fromBuffer:(nullable CMSampleBufferRef)buffer
                                 processTime:(NSTimeInterval)time;

- (void) smartCodeViewControllerDidRecognizeSingleImage:(nonnull SECodeEngineResult *)result;

- (void) smartCodeViewControllerDidCancel;

- (void) smartCodeViewControllerDidStop:(nonnull SECodeEngineResult *)result
                            processTime:(NSTimeInterval)time;

@end

@class DocTypeLabel;

@interface SmartCodeViewController : UIViewController <SmartCodeEngineDelegate,
                                                     SmartIDCameraButtonDelegate>

@property (weak, nullable) id<SmartCodeViewControllerDelegate> smartCodeDelegate;

@property (nonatomic, assign) BOOL displayDocumentQuadrangle;
@property (nonatomic, assign) BOOL displayZonesQuadrangles;
@property (nonatomic, assign) BOOL displayProcessingFeedback;
@property (nonatomic, assign) BOOL enableOnTapFocus;
@property (nonatomic, assign) BOOL shouldDisplayRoi;
@property (nonatomic, assign) BOOL bestCameraDevice;
@property (nonatomic, assign) BOOL lockCamera;
@property (nonatomic, assign) float quadranglesAlpha;
@property (nonatomic, assign) float quadranglesWidth;
@property (nonatomic, strong, nonnull) UIColor* quadranglesColor;
@property (nonatomic, strong, nonnull) UIColor* roiQuadranglesColor;
@property (nonatomic, strong, nonnull) UILabel* docTypeLabel;
@property (nonatomic, strong, nonnull) SmartIDCaptureButton* captureButton;
@property (nonatomic, weak, nullable) id<SmartIDCameraButtonDelegate> captureButtonDelegate;

@property (nonatomic, nonnull) UIButton* cancelButton;
@property (nonatomic, nonnull) UIButton* torchButton;

// optional elements
//@property (nonatomic, strong, nullable) DocTypeLabel* docTypeLabel;
@property (nonatomic, strong, nullable) UIButton* galleryButton;

- (nonnull instancetype) init;

- (nonnull instancetype) initWithLockedOrientation:(BOOL)lockOrientation;

- (nonnull instancetype) initWithLockedOrientation:(BOOL)lockOrientation WithTorch:(BOOL)torchOnByDefault;

- (nonnull instancetype) initWithLockedOrientation:(BOOL)lockOrientation
                                         WithTorch:(BOOL)torchOnByDefault
                                    WithBestDevice:(BOOL)bestDevice;

- (nonnull instancetype) initWithLockedOrientation:(BOOL)lockOrientation
                                         WithTorch:(BOOL)torchOnByDefault
                                    WithBestDevice:(BOOL)bestDevice
                                    WithLockCamera:(BOOL)lockCamera;

- (void) attachEngineInstance:(nonnull __weak SmartCodeEngineInstance *)instance;

- (void) setDefaultOrientation:(UIDeviceOrientation)orientation; // if orientation lock enabled

- (void) startRecognition;

- (void) stopRecognition;

- (CGSize) cameraSize;

- (CGRect) getCurrentRoi;

- (void) configureDocumentTypeLabel:(nonnull NSString *) label;

- (void) setRoiWithOffsetX:(CGFloat)offsetX
                      andY:(CGFloat)offsetY
               orientation:(UIDeviceOrientation)orientation
                displayRoi:(BOOL)displayroi;

- (void) processImageFile:(nonnull NSString *)filePath;
- (void) processUIImage:(nonnull UIImage *)image;

- (nonnull SECodeEngineSessionSettings *) sessionSettings;

@end



