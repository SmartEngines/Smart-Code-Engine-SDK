/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import "SmartIDCaptureButton.h"

@interface SmartIDCaptureButton () <UIGestureRecognizerDelegate>

@property (nonatomic, strong, nonnull) UITapGestureRecognizer* panGesture;
@property (nonatomic, assign) SECameraButtonState recordingState;
@property (nonatomic, assign) SECameraButtonMode mode;

@end

@implementation SmartIDCaptureButton

- (instancetype) init {
  if (self = [super initWithFrame:CGRectMake(0, 0, 60, 60)]) {
    [self configure];
  }
  return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self configure];
  }
  return self;
}
     
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self configure];
  }
  return self;
}

- (instancetype) initWithFrame:(CGRect)frame 
                       andMode:(SECameraButtonMode)mode {
  if (self = [super initWithFrame:frame]) {
    [self configure];
    [self setMode:mode];
  }
  return self;
}

- (void) configure {
  [self setPanGesture:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(animateTap)]];
  [[self panGesture] setDelegate:self];
  [self addGestureRecognizer:[self panGesture]];
  [[self layer] setCornerRadius:[self frame].size.width / 2.0];
  [[self layer] setBorderWidth:2.0];
  [[self layer] setBorderColor:[[self defaultColor] CGColor]];
  [self setBackgroundColor:[UIColor clearColor]];
  [self setMode:SECameraButtonModeVideo];
  [self setRecordingState:SECameraButtonStateWaiting];
}

- (void) animateTakePhotoWithCompletion:(void(^)(void))completion 
                               duration:(CFTimeInterval)duration {
  [UIView animateWithDuration:duration / 2.0
                   animations:^{
                     [self setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
                   }
                   completion:^(BOOL finished) {
                     [UIView animateWithDuration:duration / 2.0
                                      animations:^{
                                        [self setTransform:CGAffineTransformIdentity];
                                      }
                                      completion:^(BOOL finished) {
                                        if (completion) {
                                          completion();
                                        }
                                      }];
                   }];
}

- (void) animateStartRecordingWithCompletion:(void(^)(void))completion 
                                    duration:(CFTimeInterval)duration {
  [UIView animateWithDuration:duration
                   animations:^{
                     [self setTransform:CGAffineTransformRotate(CGAffineTransformMakeScale(0.6, 0.6), M_PI_2)];
                     [[self layer] setBorderColor:[[self videoProcColor] CGColor]];
                     [[self layer] setCornerRadius:5.0];
                     [self setBackgroundColor:[self videoProcColor]];
                   }
                   completion:^(BOOL finished) {
                     if (completion) {
                       completion();
                     }
                   }];
}

- (void) animateEndRecordingWithCompletion:(void(^)(void))completion
                                  duration:(CFTimeInterval)duration {
  [UIView animateWithDuration:duration
                   animations:^{
                     [self setTransform:CGAffineTransformIdentity];
                     [[self layer] setCornerRadius:[self frame].size.width / 2.0];
                     [[self layer] setBorderWidth:2.0];
                     [[self layer] setBorderColor:[[self defaultColor] CGColor]];
                     [self setBackgroundColor:[UIColor clearColor]];
                   }
                   completion:^(BOOL finished) {
                     if (completion) {
                       completion();
                     }
                   }];
}

- (void) restoreState {
  if ([self mode] == SECameraButtonModeVideo) {
    [self setRecordingState:SECameraButtonStateWaiting];
    [self animateEndRecordingWithCompletion:nil duration:0.0];
  }
}

- (void) animateTap {
  CFTimeInterval duration = [self animationDuration];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self setUserInteractionEnabled:NO];
    switch ([self mode]) {
      case SECameraButtonModePhoto: {
        [self animateTakePhotoWithCompletion:^{
              [[self delegate] SmartIDCameraButtonTapped:self];
              [self setUserInteractionEnabled:YES];
            }
                                    duration:duration];
        break;
      }
      case SECameraButtonModeVideo: {
        switch ([self recordingState]) {
          case SECameraButtonStateWaiting: {
            [self animateStartRecordingWithCompletion:^{
                  [self setRecordingState:SECameraButtonStateRecording];
                  [[self delegate] SmartIDCameraButtonTapped:self];
                  [self setUserInteractionEnabled:YES];
                }
                                             duration:duration];
            break;
          }
          case SECameraButtonStateRecording: {
            [self setRecordingState:SECameraButtonStateWaiting];
            [[self delegate] SmartIDCameraButtonTapped:self];
            [self animateEndRecordingWithCompletion:^{
                  [self setUserInteractionEnabled:YES];
                }
                                           duration:duration];
            break;
          }
        }
        break;
      }
    }
  });
}

- (UIColor *) defaultColor {
  if (!_defaultColor) {
    _defaultColor = [UIColor whiteColor];
  }
  return _defaultColor;
}

- (UIColor *) videoProcColor {
  if (!_videoProcColor) {
    _videoProcColor = [UIColor redColor];
  }
  return _videoProcColor;
}

- (SECameraButtonMode) mode {
  return _mode;
}

- (SECameraButtonState) recordingState {
  return _recordingState;
}

@end
