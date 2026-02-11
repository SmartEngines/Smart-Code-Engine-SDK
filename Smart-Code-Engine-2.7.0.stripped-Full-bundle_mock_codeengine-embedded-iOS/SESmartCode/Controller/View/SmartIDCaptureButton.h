/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SECameraButtonMode) {
  SECameraButtonModePhoto,
  SECameraButtonModeVideo
};

typedef NS_ENUM(NSUInteger, SECameraButtonState) {
  SECameraButtonStateRecording,
  SECameraButtonStateWaiting
};

@class SmartIDCaptureButton;

@protocol SmartIDCameraButtonDelegate

- (void) SmartIDCameraButtonTapped:(nonnull SmartIDCaptureButton *)sender;

@end

@interface SmartIDCaptureButton : UIButton

@property (nonatomic, nullable, weak) id<SmartIDCameraButtonDelegate> delegate;

@property (nonatomic, assign) float animationDuration;
@property (nonatomic, nonnull, strong) UIColor* defaultColor;
@property (nonatomic, nonnull, strong) UIColor* videoProcColor;

- (nonnull instancetype) initWithFrame:(CGRect)frame
                               andMode:(SECameraButtonMode)mode;

- (void) restoreState;
- (SECameraButtonMode) mode;
- (SECameraButtonState) recordingState;

@end
