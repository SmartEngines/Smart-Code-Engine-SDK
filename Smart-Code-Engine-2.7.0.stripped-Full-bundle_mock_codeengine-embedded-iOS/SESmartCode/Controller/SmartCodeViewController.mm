/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import "SmartCodeViewController.h"
#import "SmartIDRoiView.h"
#import "SmartIDQuadrangleView.h"
#import "SmartIDCameraManager.h"
#import "CameraFocusSquare.h"

#import <objcsecommon/se_geometry.h>

@interface SmartCodeViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) SmartIDVideoPreviewView* videoPreview;
@property (nonatomic, strong) SmartIDRoiView* roiView;
@property (nonatomic, assign) UIDeviceOrientation lastOrientation;
@property (nonatomic, assign) BOOL displayroi;
@property (nonatomic, assign) BOOL guiInitialized;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSArray *>* rois;
@property (nonatomic, assign) CGRect currentRoi;
@property (nonatomic, assign) UIDeviceOrientation defaultOrientation;

@property (nonatomic, strong) SmartIDCameraManager* camera;
@property (nonatomic, strong) SmartIDQuadrangleView* quadrangleView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, strong) CameraFocusSquare* camFocus;
@property (nonatomic, assign) BOOL obsIsAdjustingFocus;
@property (nonatomic, strong) AVCaptureDevice* camDevice;
@property (nonatomic, assign) BOOL torchOnByDefault;

@property (nonatomic, weak) SmartCodeEngineInstance* engineInstance;

@property (nonatomic, assign) BOOL lockOrientation;

@end

@implementation SmartCodeViewController {
  BOOL structureInitialized;
}

@synthesize engineInstance, camera, quadrangleView, previewLayer;

- (void) commonInitialize {
  structureInitialized = NO;

  self.rois = [[NSMutableDictionary alloc] init];

  [[self rois] setObject:@[@0, @0] forKey:@(UIDeviceOrientationPortrait)];
  [[self rois] setObject:@[@0, @0] forKey:@(UIDeviceOrientationLandscapeLeft)];
  [[self rois] setObject:@[@0, @0] forKey:@(UIDeviceOrientationLandscapeRight)];
  [[self rois] setObject:@[@0, @0] forKey:@(UIDeviceOrientationPortraitUpsideDown)];

  [self setQuadranglesAlpha:1.0];
  [self setQuadranglesWidth:1.5];
  [self setQuadranglesColor:[UIColor greenColor]];
  [self setRoiQuadranglesColor:[UIColor purpleColor]];

  self.docTypeLabel = [[UILabel alloc] init];
  self.docTypeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
  self.docTypeLabel.textAlignment = NSTextAlignmentCenter;
  self.docTypeLabel.textColor = [UIColor whiteColor];
  self.docTypeLabel.translatesAutoresizingMaskIntoConstraints = false;

  self.captureButton = [[SmartIDCaptureButton alloc] init];
  [[self captureButton] setAnimationDuration:0.3];

  self.camera = [[SmartIDCameraManager alloc] initWithBestDevice:self.bestCameraDevice WithLockCamera:self.lockCamera];

  self.videoPreview = [[SmartIDVideoPreviewView alloc] init];
  self.quadrangleView = [[SmartIDQuadrangleView alloc] init];
  [self.quadrangleView configureWithMode:QuadrangleAnimationModeDefault];
  self.roiView = [[SmartIDRoiView alloc] init];

  [[self camera] configurePreview:[self videoPreview]];
  _camDevice = [self.camera getCaptureDevice];

  structureInitialized = YES;
}

- (instancetype) init {
  if (self = [super init]) {
    _lockOrientation = NO;
    _torchOnByDefault = NO;
    _displayroi = NO;
    if (!structureInitialized) {
      [self commonInitialize];
    }
  }
  return self;
}

- (instancetype) initWithLockedOrientation:(BOOL)lockOrientation  {
  if (self = [super init]) {
    _lockOrientation = lockOrientation;
    _torchOnByDefault = NO;
    _bestCameraDevice = NO;
    _lockCamera = NO;
    if (!structureInitialized) {
      [self commonInitialize];
    }
  }
  return self;
}

- (instancetype) initWithLockedOrientation:(BOOL)lockOrientation WithTorch:(BOOL)torchOnByDefault  {
  if (self = [super init]) {
    _lockOrientation = lockOrientation;
    _torchOnByDefault = torchOnByDefault;
    _bestCameraDevice = NO;
    _lockCamera = NO;
    if (!structureInitialized) {
      [self commonInitialize];
    }
  }
  return self;
}

- (instancetype) initWithLockedOrientation:(BOOL)lockOrientation
                                 WithTorch:(BOOL)torchOnByDefault
                            WithBestDevice:(BOOL)bestDevice{
   if (self = [super init]) {
     _lockOrientation = lockOrientation;
     _torchOnByDefault = torchOnByDefault;
     _bestCameraDevice = bestDevice;
     _lockCamera = NO;
    if (!structureInitialized) {
      [self commonInitialize];
    }
  }
  return self;
}

- (instancetype) initWithLockedOrientation:(BOOL)lockOrientation
                                 WithTorch:(BOOL)torchOnByDefault
                            WithBestDevice:(BOOL)bestDevice
                            WithLockCamera:(BOOL)lockCamera{
   if (self = [super init]) {
     _lockOrientation = lockOrientation;
     _torchOnByDefault = torchOnByDefault;
     _bestCameraDevice = bestDevice;
     _lockCamera = lockCamera;
    if (!structureInitialized) {
      [self commonInitialize];
    }
  }
  return self;
}

- (void) attachEngineInstance:(nonnull __weak SmartCodeEngineInstance *)instance {
  self.engineInstance = instance;
  __weak __typeof(self) weakSelf = self;
  [self.engineInstance setEngineDelegate:weakSelf];
  [self.engineInstance resetSessionSettings];
}

- (void) makeLayout {
  self.videoPreview.translatesAutoresizingMaskIntoConstraints = NO;
  self.quadrangleView.translatesAutoresizingMaskIntoConstraints = NO;
  self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.roiView.translatesAutoresizingMaskIntoConstraints = NO;
  self.captureButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.camFocus.translatesAutoresizingMaskIntoConstraints = NO;
  // uncomment to add torch button
  self.torchButton.translatesAutoresizingMaskIntoConstraints = NO;

  NSArray *videoPreviewLayout = @[[NSLayoutConstraint
                                   constraintWithItem:self.videoPreview
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1.0f
                                   constant:0.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.videoPreview
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.videoPreview
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeBottom
                                   multiplier:1.0f
                                   constant:0.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.videoPreview
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeTop
                                   multiplier:1.0f
                                   constant:0.f]
                                  ];

  NSArray *roiLayout = @[[NSLayoutConstraint
                                   constraintWithItem:self.roiView
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1.0f
                                   constant:0.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.roiView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.roiView
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeBottom
                                   multiplier:1.0f
                                   constant:0.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.roiView
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeTop
                                   multiplier:1.0f
                                   constant:0.f]
                                  ];

  NSArray *quadrangleViewLayout = @[[NSLayoutConstraint
                                   constraintWithItem:self.quadrangleView
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1.0f
                                   constant:0.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.quadrangleView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.quadrangleView
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeBottom
                                   multiplier:1.0f
                                   constant:0.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.quadrangleView
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeTop
                                   multiplier:1.0f
                                   constant:0.f]
                                  ];


  NSArray *captureButtonLayout = @[
                                  [NSLayoutConstraint
                                   constraintWithItem:self.captureButton
                                   attribute:NSLayoutAttributeCenterX
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeCenterX
                                   multiplier:1.0f
                                   constant:0.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.captureButton
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeBottom
                                   multiplier:1.0f
                                   constant:-25.f]
                                  ];

  NSArray *captureButtonConstants = @[
                                     [NSLayoutConstraint
                                      constraintWithItem:self.captureButton
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1.0f
                                      constant:60.f],
                                     [NSLayoutConstraint
                                      constraintWithItem:self.captureButton
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1.0f
                                      constant:60.f]
                                     ];

  NSArray *cancelButtonLayout = @[
                                  [NSLayoutConstraint
                                   constraintWithItem:self.cancelButton
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1.0f
                                   constant:-25.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.cancelButton
                                   attribute:NSLayoutAttributeCenterY
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.captureButton
                                   attribute:NSLayoutAttributeCenterY
                                   multiplier:1.0f
                                   constant:0.f]
                                    ];

  NSArray *cancelButtonConstants = @[
                                     [NSLayoutConstraint
                                      constraintWithItem:self.cancelButton
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1.0f
                                      constant:50.f],
                                     [NSLayoutConstraint
                                      constraintWithItem:self.cancelButton
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1.0f
                                      constant:50.f]
                                     ];

  NSArray *docTypeLabelLayout = @[[NSLayoutConstraint
                                   constraintWithItem:self.docTypeLabel
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1.0f
                                   constant:0.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.docTypeLabel
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.docTypeLabel
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeTop
                                   multiplier:1.0f
                                   constant:50.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.docTypeLabel
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                   multiplier:1.0f
                                   constant:50.f]
                                  ];

  NSArray *torchButtonLayout = @[
                                  [NSLayoutConstraint
                                   constraintWithItem:self.torchButton
                                   attribute:NSLayoutAttributeCenterY
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.captureButton
                                   attribute:NSLayoutAttributeCenterY
                                   multiplier:1.0f
                                   constant:0.f],
                                  [NSLayoutConstraint
                                   constraintWithItem:self.torchButton
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:30.f]
                                    ];

  NSArray *torchButtonConstants = @[
                                     [NSLayoutConstraint
                                      constraintWithItem:self.torchButton
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1.0f
                                      constant:60.f],
                                     [NSLayoutConstraint
                                      constraintWithItem:self.torchButton
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1.0f
                                      constant:30.f]
                                      ];

  [[self view] addConstraints:videoPreviewLayout];
  [[self view] addConstraints:quadrangleViewLayout];
  [[self view] addConstraints:cancelButtonLayout];
  [[self view] addConstraints:roiLayout];
  [[self view] addConstraints:captureButtonLayout];
  [[self view] addConstraints:docTypeLabelLayout];
  [[self view] addConstraints:torchButtonLayout];

  [[self captureButton] addConstraints:captureButtonConstants];
  [[self cancelButton] addConstraints:cancelButtonConstants];
  [[self torchButton] addConstraints:torchButtonConstants];

}

- (void) setShouldDisplayRoi:(BOOL)shouldDisplayRoi {
  _shouldDisplayRoi = shouldDisplayRoi;
  [[self roiView] setHidden:!_shouldDisplayRoi];
}

- (void) viewDidLoad {
  [super viewDidLoad];
  __weak __typeof(self) weakSelf = self;
  [[self camera] setSampleBufferDelegate:weakSelf];
  if (!_lockOrientation){
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(rotated:)
                                                   name:UIDeviceOrientationDidChangeNotification
                                                 object:nil];
  }


  [[self view] addSubview:[self videoPreview]];
  [[self view] addSubview:[self quadrangleView]];
  [[self view] addSubview:[self roiView]];
  [[self view] addSubview:[self cancelButton]];
  [[self view] addSubview:[self captureButton]];
  [[self view] addSubview:[self docTypeLabel]];
  [[self view] addSubview:[self torchButton]];

  [self makeLayout];

  UITapGestureRecognizer* gestureRecognizer =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(focusButtonTapped:)];
  gestureRecognizer.numberOfTapsRequired = 1;
  [[self view] addGestureRecognizer:gestureRecognizer];
}

- (void) configureDocumentTypeLabel:(NSString*) label {
  self.docTypeLabel.text = label;
}

- (void) configurePreviewView {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIInterfaceOrientation statusBarOrientation;
    if (@available(iOS 13, *)) {
      statusBarOrientation = self.view.window.windowScene.interfaceOrientation;
    } else {
      statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    }
    AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
    if (!self.lockOrientation) {
      if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
        initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
      }
    } else {
      self.lastOrientation = UIDeviceOrientationPortrait;
      [self interfaceOrDeviceOrientationDidChange];
    }
    self.videoPreview.videoPreviewLayer.connection.videoOrientation = initialVideoOrientation;
  });
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self rotated:nil];
  [[self captureButton] restoreState];
  if (!UIDeviceOrientationIsPortrait(self.lastOrientation) &&
      !UIDeviceOrientationIsLandscape(self.lastOrientation)) {
    self.lastOrientation = UIDeviceOrientationPortrait;
  }
  if ([self enableOnTapFocus]) {
    int flags = NSKeyValueObservingOptionNew;
    [_camDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
  }

  [self.camera updateCaptureSessionPreset];

  [self updateRoi];
  [self configurePreviewView];
  [self.camera startCaptureSession];
  if (self.torchOnByDefault)
    [self.camera turnTorchOnWithLevel:1.0];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[self engineInstance] dismissVideoSession];
  if ([self enableOnTapFocus]) {
    [_camDevice removeObserver:self forKeyPath:@"adjustingFocus"];
  }
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [[self camera] stopCaptureSession];
}

// callback
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([self enableOnTapFocus]) {
    if( [keyPath isEqualToString:@"adjustingFocus"] ){
      _obsIsAdjustingFocus = [ [change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
      if (!_obsIsAdjustingFocus) {
        [_camFocus removeFromSuperview];
      }
      //Focus information
      //NSLog(@"Is adjusting focus? %@", _obsIsAdjustingFocus ? @"YES" : @"NO" );
      //NSLog(@"Change dictionary: %@", change);
    }
  }
}

#pragma mark - roi

- (void) setRoiWithOffsetX:(CGFloat)offsetX
                      andY:(CGFloat)offsetY
               orientation:(UIDeviceOrientation)orientation
                displayRoi:(BOOL)displayroi {
  [[self rois] setObject:@[@(offsetX), @(offsetY)] forKey:@(orientation)];
  _displayroi = displayroi;
  [self updateRoi];
}

- (void) updateRoi {
  NSArray *offsets = [[self rois] objectForKey:@(self.lastOrientation)];
  UIInterfaceOrientation currentUIIO;
  if (@available(iOS 13, *)) {
    currentUIIO = self.view.window.windowScene.interfaceOrientation;
  } else {
    currentUIIO = [UIApplication sharedApplication].statusBarOrientation;
  }

  if (UIInterfaceOrientationIsLandscape(currentUIIO)) {
    self.roiView.offsetY = [[offsets objectAtIndex:0] floatValue];
    self.roiView.offsetX = [[offsets objectAtIndex:1] floatValue];
  } else {
    self.roiView.offsetX = [[offsets objectAtIndex:0] floatValue];
    self.roiView.offsetY = [[offsets objectAtIndex:1] floatValue];
  }
  self.roiView.displayRoi = _displayroi;
  [self.roiView setNeedsDisplay];
  self.currentRoi = [SmartIDRoiView calculateRoiWith:self.lastOrientation
                                            viewSize:self.view.frame.size
                                         orientation:currentUIIO
                                          cameraSize:[[self camera] videoSize]
                                          andOffsets:CGSizeMake([[offsets objectAtIndex:0] floatValue],
                                                                [[offsets objectAtIndex:1] floatValue])
                                          displayRoi:_displayroi];
}

#pragma mark - video processing

- (void) startRecognition {
  [self stopRecognition];
  [[self engineInstance] initVideoSession];
}

- (void) stopRecognition {
  [[self engineInstance] dismissVideoSession];
}

- (void) stopSessionRunning {
  [[self engineInstance] dismissVideoSessionRunning];
}

- (void) captureOutput:(AVCaptureOutput *)output
 didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
        fromConnection:(AVCaptureConnection *)connection {
  if (self.engineInstance.videoSessionRunning) {
    [[self engineInstance] processFrame:sampleBuffer
                        withOrientation:self.lastOrientation
                                 andRoi:self.currentRoi];
  }
}

- (void) SmartCodeEngineObtainedSingleImageResult:(SECodeEngineResult *)result {
  if (self.smartCodeDelegate) {
    if ([[self smartCodeDelegate] respondsToSelector:@selector(smartCodeViewControllerDidRecognizeSingleImage:)]) {
      [[self smartCodeDelegate] smartCodeViewControllerDidRecognizeSingleImage:result];
    }
  }
}

- (void) SmartCodeEngineObtainedResult:(SECodeEngineResult *)result
                 fromFrameWithBuffer:(CMSampleBufferRef)buffer
                           processTime:(NSTimeInterval)time{
  if (self.smartCodeDelegate) {
    if ([self.smartCodeDelegate respondsToSelector:@selector(smartCodeViewControllerDidRecognize:fromBuffer:processTime:)]) {
      [self.smartCodeDelegate smartCodeViewControllerDidRecognize:result fromBuffer:buffer processTime:time];
    }
  }
  if ([[result getRef] isTerminal]) {
    [self stopRecognition];
  }
}

- (void) SmartCodeEngineObtainedFeedback:(SECodeEngineFeedbackContainer *)feedback {
  if ([self displayProcessingFeedback]) {
    SECommonQuadranglesMapIterator* quadsEnd = [[feedback getRef] quadranglesEnd];
    for (SECommonQuadranglesMapIterator* it = [[feedback getRef] quadranglesBegin];
         ![it isEqualToIter:quadsEnd];
         [it advance]) {
      SECommonQuadrangle* quad = [it getValue];
      UIInterfaceOrientation ifaceOrientation;
      if (@available(iOS 13, *)) {
        ifaceOrientation = self.view.window.windowScene.interfaceOrientation;
      } else {
        ifaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
      }
      UIColor *color = [self quadranglesColor];
      NSString *key = [it getKey];
      if ([key containsString:@"roi"]) {
        color = [self roiQuadranglesColor];
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        [[self quadrangleView] animateQuadrangle:quad
                                           color:color
                                           width:[self quadranglesWidth]
                                           alpha:[self quadranglesAlpha]
                                         offsetX:[self currentRoi].origin.x
                                         offsetY:[self currentRoi].origin.y
                               deviceOrientation:[self lastOrientation]
                            interfaceOrientation:ifaceOrientation
                                      sourceSize:[[self camera] videoSize]
                                         isFront:self.camera.getCaptureDevice.position == AVCaptureDevicePositionFront];
      });
    }
  }
}

#pragma mark - capture button

- (void) setCaptureButtonDelegate:(id<SmartIDCameraButtonDelegate>)captureButtonDelegate {
  _captureButtonDelegate = captureButtonDelegate;
  [[self captureButton] setDelegate:_captureButtonDelegate];
}

- (void) SmartIDCameraButtonTapped:(SmartIDCaptureButton *)sender {
  if (!self.engineInstance.videoSessionRunning) {
    [self startRecognition];
  } else {
    if ([self.smartCodeDelegate respondsToSelector:@selector(smartCodeViewControllerDidStop:processTime:)]) {
      [self stopSessionRunning];
      [self.smartCodeDelegate smartCodeViewControllerDidStop:
          [[self.engineInstance.videoSession getCurrentResult] clone] processTime:engineInstance.processTime];
    }
    [self stopRecognition];
  }
}

#pragma mark - cancel button

- (UIButton *) cancelButton {
  if (!_cancelButton) {
    _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_cancelButton setTitle:@"X" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:40.0f]];
    [_cancelButton addTarget:self
                      action:@selector(cancelButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
  }
  return _cancelButton;
}

- (void) cancelButtonTapped {
  if (self.engineInstance.videoSessionRunning) {
    [self stopRecognition];
  }
  if (self.smartCodeDelegate) {
    if ([self.smartCodeDelegate respondsToSelector:@selector(smartCodeViewControllerDidCancel)]) {
      [self.smartCodeDelegate smartCodeViewControllerDidCancel];
    }
  }
}

#pragma mark - torch button

- (UIButton *) torchButton {
  if (!_torchButton) {
    _torchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_torchButton addTarget:self
                      action:@selector(torchButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
    [_torchButton setTintColor:[UIColor whiteColor]];

    UIImage *btnImage = (self.torchOnByDefault) ? [UIImage imageNamed:@"torch_on.png"] : [UIImage imageNamed:@"torch_off.png"];

    [_torchButton setImage:btnImage forState:UIControlStateNormal];
  }
  return _torchButton;
}

- (void) torchButtonTapped {
  if ([self.camera isTorchOn]) {
    [self.camera turnTorchOff];
    UIImage *btnImage = [UIImage imageNamed:@"torch_off.png"];
    [_torchButton setImage:btnImage forState:UIControlStateNormal];
  } else {
    [self.camera turnTorchOnWithLevel:1.0];
    UIImage *btnImage = [UIImage imageNamed:@"torch_on.png"];
    [_torchButton setImage:btnImage forState:UIControlStateNormal];
  }
}


#pragma mark - focus button

- (void) focusButtonTapped:(id)sender {
  if ([self enableOnTapFocus]) {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
      UITapGestureRecognizer* senderAsGesture = (UITapGestureRecognizer *)sender;
      CGPoint location = [senderAsGesture locationInView:[self view]];
      [[self camera] focusAtPoint:location completionHandler:nil];

      if (_camFocus) {
        [_camFocus removeFromSuperview];
      }
      _camFocus = [[CameraFocusSquare alloc]initWithFrame:CGRectMake(location.x-40, location.y-40, 80, 80)];
      [_camFocus setBackgroundColor:[UIColor clearColor]];
      [[self view] addSubview:[self camFocus]];
      [_camFocus setNeedsDisplay];

      [UIView animateWithDuration: 1.5 animations:^{
          [self.camFocus setAlpha:0.0];
      } completion:^(BOOL finished){
      }];
    }
  }
}

#pragma mark - orientation handling

- (void) viewWillTransitionToSize:(CGSize)size
        withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
  if (UIDeviceOrientationIsPortrait(deviceOrientation) ||
      UIDeviceOrientationIsLandscape(deviceOrientation)) {
    self.lastOrientation = deviceOrientation;
    [self interfaceOrDeviceOrientationDidChange];
    self.videoPreview.videoPreviewLayer.connection.videoOrientation =
        (AVCaptureVideoOrientation)deviceOrientation;
  }
}

- (void) rotated:(NSNotification *)notification {
  UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
  if (UIDeviceOrientationIsPortrait(deviceOrientation) ||
      UIDeviceOrientationIsLandscape(deviceOrientation)) {
    self.lastOrientation = deviceOrientation;
    [self interfaceOrDeviceOrientationDidChange];
  }
}

- (void) interfaceOrDeviceOrientationDidChange {
  [self updateRoi];
}

- (CGSize) cameraSize {
  return [[self camera] videoSize];
}

- (CGRect) getCurrentRoi {
  return [self currentRoi];
}

- (void) setDefaultOrientation:(UIDeviceOrientation)orientation {
  _defaultOrientation = orientation;
}

- (UIDeviceOrientation) lastOrientation {
  if (_defaultOrientation != UIDeviceOrientationUnknown) {
    return _defaultOrientation;
  } else {
    return _lastOrientation;
  }
}

- (void) processImageFile:(nonnull NSString*)filePath {
  __weak __typeof(self) weaksef = self;
  [self.engineInstance setEngineDelegate:weaksef];
  [self.engineInstance processSingleImageFromFile:filePath];
}

- (void) processUIImage:(UIImage *)image {
  __weak __typeof(self) weakself = self;
  [self.engineInstance setEngineDelegate:weakself];
  [self.engineInstance processSingleImageFromUIImage:image];
}

- (nonnull SECodeEngineSessionSettings *) sessionSettings {
  return [self.engineInstance sessionSettings];
}

@end
