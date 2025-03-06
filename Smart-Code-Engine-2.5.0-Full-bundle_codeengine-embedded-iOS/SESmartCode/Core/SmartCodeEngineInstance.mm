/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

#import "SmartCodeEngineInstance.h"

#pragma mark - ProxyWorkflowReporter

@interface ProxyWorkflowReporter : NSObject <SECodeEngineWorkflowFeedback>
@property (weak) SmartCodeEngineInstance* governor;

- (instancetype) initWithGovernor:(__weak SmartCodeEngineInstance *)initGovernor;


- (void) resultReceived:(nonnull SECodeEngineResultRef *)result;
- (void) sessionEnded;

@end

@implementation ProxyWorkflowReporter {
  BOOL transferFeedback;
}

@synthesize governor;

- (instancetype) initWithGovernor:(__weak SmartCodeEngineInstance *)initGovernor {
  if (self = [super init]) {
    governor = initGovernor;
    [self updateResponceFlags];
  }
  return self;
}

- (void) updateResponceFlags {
  transferFeedback = NO;
  if (self.governor.engineDelegate) {
    transferFeedback = [self.governor.engineDelegate respondsToSelector:@selector(SmartCodeEngineObtainedFeedback:)];
  }
}

- (void) resultReceived:(SECodeEngineResultRef *)result {
  NSLog(@"[Feedback called]: Result received (Obj count: %d)",
        [result getObjectCount]);
}

- (void) sessionEnded {
  NSLog(@"[Feedback called]: code session ended");
}

@end

#pragma mark - ProxyVisualizationReporter

@interface ProxyVisualizationReporter : NSObject <SECodeEngineVisualizationFeedback>
@property (weak) SmartCodeEngineInstance* governor;

- (instancetype) initWithGovernor:(__weak SmartCodeEngineInstance *)initGovernor;

- (void) feedbackReceived:(nonnull SECodeEngineFeedbackContainerRef *)feedback;

@end


@implementation ProxyVisualizationReporter {
  BOOL transferFeedback;
}

@synthesize governor;

- (instancetype) initWithGovernor:(__weak SmartCodeEngineInstance *)initGovernor {
  if (self = [super init]) {
    governor = initGovernor;
    [self updateResponceFlags];
  }
  return self;
}

- (void) updateResponceFlags {
  transferFeedback = NO;
  if (self.governor.engineDelegate) {
    transferFeedback = [self.governor.engineDelegate respondsToSelector:@selector(SmartCodeEngineObtainedFeedback:)];
  }
}

- (void) feedbackReceived:(SECodeEngineFeedbackContainerRef *)feedback {
  NSLog(@"[Feedback called]: feedback container received");
  if (transferFeedback) {
    SECodeEngineFeedbackContainer* feedbackCopy = [feedback clone];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.governor.engineDelegate SmartCodeEngineObtainedFeedback:feedbackCopy];
    });
  }
  if (self.governor.isCollectingQuadrangles) {
    if (self.governor.collectedQuadrangles == nil) {
      self.governor.collectedQuadrangles = [NSMutableArray array];
    }
    [self.governor.collectedQuadrangles addObject:[feedback clone]];
  }
}

@end

#pragma mark - SmartCodeEngineInstance

@interface SmartCodeEngineInstance () {
  ProxyWorkflowReporter* proxyWorkflowReporter;
  ProxyVisualizationReporter* proxyVisualizationReporter;
}

@property NSString* signature;


@property (weak, nonatomic, nullable, readwrite) id<SmartCodeEngineDelegate> engineDelegate;
@property (weak, nonatomic, nullable, readwrite) id<SmartCodeEngineInitializationDelegate> initializationDelegate;

@property (strong, nullable, readwrite) SECodeEngine* engine; // main configuration of Smart Code Engine
@property (strong, nullable, readwrite) SECodeEngineSession* videoSession; // current video recognition session

@property (readwrite) NSTimeInterval processTime;
@property (readwrite) int frameNumber;

@end

@implementation SmartCodeEngineInstance {
  BOOL delegateReceivesResults;
  BOOL delegateReceivesSingleImageResults;

  BOOL delegateReceivesInit;
  BOOL delegateReceivesSessionStarted;
  BOOL delegateReceivesSessionDismissed;
}

@synthesize engine, videoSession, sessionSettings;

- (instancetype) init {
  NSException* exc = [NSException
        exceptionWithName:@"SignatureError"
        reason:@"SmartCodeEngineInstance must be created with signature (use initWithSignature:)"
        userInfo:nil];
  @throw exc;
}

- (instancetype) initWithSignature:(NSString *)inputSignature {
  if (self = [super init]) {
    // Storing signature
    self.signature = inputSignature;

    self.engineInitialized = NO;
    self.videoSessionRunning = NO;

    // Initializing proxy reporter
    __weak __typeof(self) weakSelf = self;
    proxyWorkflowReporter = [[ProxyWorkflowReporter alloc] initWithGovernor:weakSelf];
    proxyVisualizationReporter = [[ProxyVisualizationReporter alloc] initWithGovernor:weakSelf];
    // Initializing delegates cache
    delegateReceivesResults = NO;
    delegateReceivesSingleImageResults = NO;
    delegateReceivesInit = NO;
    delegateReceivesSessionStarted = NO;
    delegateReceivesSessionDismissed = NO;


  }

  return self;
}

- (void) setEngineDelegate:(nullable __weak id<SmartCodeEngineDelegate>)delegate {
  _engineDelegate = delegate;
  delegateReceivesResults = NO;
  delegateReceivesSingleImageResults = NO;
  if (self.engineDelegate) {
    delegateReceivesResults =
        [self.engineDelegate respondsToSelector:@selector(SmartCodeEngineObtainedResult:fromFrameWithBuffer:processTime:)];
    delegateReceivesSingleImageResults =
        [self.engineDelegate respondsToSelector:@selector(SmartCodeEngineObtainedSingleImageResult:)];

    [proxyWorkflowReporter updateResponceFlags];
    [proxyVisualizationReporter updateResponceFlags];
  }
}

- (void) setInitializationDelegate:(nullable __weak id<SmartCodeEngineInitializationDelegate>)delegate {
  _initializationDelegate = delegate;
  delegateReceivesInit = NO;
  delegateReceivesSessionStarted = NO;
  delegateReceivesSessionDismissed = NO;
  if (self.initializationDelegate) {
    delegateReceivesInit =
        [self.initializationDelegate respondsToSelector:@selector(SmartCodeEngineInitialized)];
    delegateReceivesSessionStarted =
        [self.initializationDelegate respondsToSelector:@selector(SmartCodeEngineVideoSessionStarted)];
    delegateReceivesSessionDismissed =
        [self.initializationDelegate respondsToSelector:@selector(SmartCodeEngineVideoSessionDismissed)];
  }
}

- (void) initializeEngine:(NSString*_Nullable) bundlePath {
  self.engine = [[SECodeEngine alloc] initFromFile:bundlePath
                                        withLazyInit:YES];
  self.defaultSessionSettings = [self.engine getDefaultSessionSettings];
  [self resetSessionSettings];
  // Logging supported document types
  NSLog(@"Supported codeengine settings:");
  SECommonStringsMapIterator* settingsEnd = [self.sessionSettings settingsEnd];
  for (SECommonStringsMapIterator* it = [self.sessionSettings settingsBegin];
       ![it isEqualToIter:settingsEnd];
       [it advance]) {
    NSLog(@" --> %@: %@", [it getKey], [it getValue]);
  }
    
  self.videoSession = nil;
  self.videoSessionRunning = NO;

  self.engineInitialized = YES;

  if (delegateReceivesInit) {
    [self.initializationDelegate SmartCodeEngineInitialized];
  }
}

- (void) initializeEngine {
  self.engine = [[SECodeEngine alloc] initEmbeddedWithLazyInit:YES];
  self.defaultSessionSettings = [self.engine getDefaultSessionSettings];
  [self resetSessionSettings];
  // Logging supported document types
  NSLog(@"Supported codeengine settings:");
  SECommonStringsMapIterator* settingsEnd = [self.sessionSettings settingsEnd];
  for (SECommonStringsMapIterator* it = [self.sessionSettings settingsBegin];
       ![it isEqualToIter:settingsEnd];
       [it advance]) {
    NSLog(@" --> %@: %@", [it getKey], [it getValue]);
  }
    
  self.videoSession = nil;
  self.videoSessionRunning = NO;

  self.engineInitialized = YES;

  if (delegateReceivesInit) {
    [self.initializationDelegate SmartCodeEngineInitialized];
  }
}

- (void) resetSessionSettings {
  self.sessionSettings = [engine getDefaultSessionSettings];
}

- (void) resetQuadrangles {
  self.collectedQuadrangles = nil;
  NSLog(@"collectedQuadrangles are nil");
}

- (NSMutableArray<SECodeEngineFeedbackContainer *> *) getQuadrangles {
  return self.collectedQuadrangles;
}

- (bool) isCollectingQuadrangles {
  return self.collectingQuadrangles;
}

- (void) initVideoSession {
  if (!self.engineInitialized) {
    NSException* exc = [NSException
          exceptionWithName:@"SmartCodeEngineInstanceError"
          reason:@"SmartCodeEngineInstance cannot initialize video session while engine is not yet initialized"
          userInfo:nil];
    @throw exc;
  }
  
  SECommonStringsMapIterator* settingsEnd = [self.sessionSettings settingsEnd];
  for (SECommonStringsMapIterator* it = [self.sessionSettings settingsBegin];
       ![it isEqualToIter:settingsEnd];
       [it advance]) {
    NSLog(@" --> %@: %@", [it getKey], [it getValue]);
  }

  @synchronized (self.videoSession) {
    self.videoSession = [self.engine
                         spawnSessionWithSettings:self.sessionSettings
                         withSignature:self.signature
                         withWorkflowFeedback:proxyWorkflowReporter
                         withVisualizationFeedback:proxyVisualizationReporter];
    self.videoSessionRunning = YES;
  }

  if (delegateReceivesSessionStarted) {
    [self.initializationDelegate SmartCodeEngineVideoSessionStarted];
  }
}

- (void) dismissVideoSession {
  @synchronized (self.videoSession) {
    self.videoSessionRunning = NO;
    self.videoSession = nil;
    self.frameNumber = 0;
    self.processTime = 0;
  }

  if (delegateReceivesSessionDismissed) {
    [self.initializationDelegate SmartCodeEngineVideoSessionDismissed];
  }
}

- (void) dismissVideoSessionRunning {
  @synchronized (self.videoSession) {
    self.videoSessionRunning = NO;
  }
}

#pragma mark - frame processing

int getCodeRotationsByOrientation(UIDeviceOrientation orientation) {
  int rotations = 0;
  if (orientation == UIDeviceOrientationPortrait) {
    rotations = 1;
  } else if (orientation == UIDeviceOrientationLandscapeRight) {
    rotations = 2;
  } else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
    rotations = 3;
  }
  return rotations;
}

- (void) processFrameImage:(SECommonImageRef *)image
                fromBuffer:(CMSampleBufferRef)buffer {
  if (self.videoSessionRunning) {
    SECodeEngineResult* result = nil;
    
    @synchronized (self.videoSession) {
      NSDate *start = [NSDate date];
      [self.videoSession process:image];
      NSDate *end = [NSDate date];
      
     
      SECodeEngineResultRef* currentResult = [self.videoSession getCurrentResult];
      if ([currentResult getObjectCount] > 0 and self.frameNumber == 0){
        self.processTime = [end timeIntervalSinceDate:start];
        NSLog(@"process time = %f", self.processTime);
        self.frameNumber = 1;
      }
      result = [currentResult clone];
//      NSLog(@"Total objects count: %d", [[result getRef] getObjectCount]);
//      NSLog(@"Result terminal:           %@",
//            [[result getRef] isTerminal] ? @" [+] " : @" [-] ");
    }

//    if (self.videoSessionRunning) { // sending callbacks only if the session is still running here
      // processing is performed on video queue so forcing main queue
      if ([NSThread isMainThread]) {
        if (delegateReceivesResults) {
          [self.engineDelegate SmartCodeEngineObtainedResult:result fromFrameWithBuffer:buffer processTime:self.processTime];
        }
      } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
          if (delegateReceivesResults) {
            [self.engineDelegate SmartCodeEngineObtainedResult:result fromFrameWithBuffer:buffer processTime:self.processTime];
          }
        });
      }
//    }
  }
}

- (void) processFrame:(CMSampleBufferRef)sampleBuffer
      withOrientation:(UIDeviceOrientation)deviceOrientation {
  if (self.videoSessionRunning) {
    int rotations = getCodeRotationsByOrientation(deviceOrientation);

    SECommonImage* imageSource = [[SECommonImage alloc] initFromSampleBuffer:sampleBuffer];

    SECommonImageRef* image = [imageSource getMutableRef];
    if (rotations > 0) {
      [image rotate90:rotations];
    }

    [self processFrameImage:image fromBuffer:sampleBuffer];
  }
}

- (void) processFrame:(CMSampleBufferRef)sampleBuffer
      withOrientation:(UIDeviceOrientation)deviceOrientation
               andRoi:(CGRect)roi {
  if (self.videoSessionRunning) {
    int rotations = getCodeRotationsByOrientation(deviceOrientation);

    SECommonImage* imageSource = [[SECommonImage alloc] initFromSampleBuffer:sampleBuffer];

    SECommonImageRef* image = [imageSource getMutableRef];
    if (rotations > 0) {
      [image rotate90:rotations];
    }
  
    SECommonRectangle* proxyRoi = [[SECommonRectangle alloc] initWithX:roi.origin.x
                                                                 withY:roi.origin.y
                                                             withWidth:roi.size.width
                                                            withHeight:roi.size.height];
    SECommonImage* croppedImage = [image cloneCroppedToRectangleShallow:proxyRoi];
    
    [self processFrameImage:[croppedImage getRef] fromBuffer:sampleBuffer];
  }
}

- (nonnull NSArray*) processSingleImage:(nonnull SECommonImageRef *)image {
  _collectingQuadrangles = YES;
  SECodeEngineSession* imageSession = [self.engine spawnSessionWithSettings:self.sessionSettings
                                                              withSignature:self.signature
                                                       withWorkflowFeedback:proxyWorkflowReporter
                                                  withVisualizationFeedback:proxyVisualizationReporter];
  SECommonStringsMapIterator* settingsEnd = [self.sessionSettings settingsEnd];
  for (SECommonStringsMapIterator* it = [self.sessionSettings settingsBegin];
       ![it isEqualToIter:settingsEnd];
       [it advance]) {
    NSLog(@" --> %@: %@", [it getKey], [it getValue]);
  }
  
  NSDate *start = [NSDate date];
  [imageSession process:image];
  NSDate *end = [NSDate date];
  self.processTime = [end timeIntervalSinceDate:start];
  NSLog(@"process time = %f", self.processTime);
  SECodeEngineResultRef* currentResult = [imageSession getCurrentResult];
  //debug
//  NSLog(@"Total objects count: %d", [currentResult getObjectCount]);
//  for (SECodeObjectsMapIterator *it = [currentResult objectsBegin];
//       ![it isEqualToIter:[currentResult objectsEnd]];[it advance]) {
//    SECodeObjectRef *code_object = [it getValue];
//    NSLog(@"%s: Accepted%@Terminal%@ (%4.3lf) ID:%d",
//          [[code_object getTypeStr] UTF8String],
//          [code_object isAccepted] ? @" [+] " : @" [-] ",
//          [code_object getIsTerminal] ? @" [+] " : @" [-] ",
//          [code_object getConfidence], [code_object getID]);
//    NSLog(@"    Detected frames: first %d, last %d",
//          [code_object getFirstDetectedFrame],
//          [code_object getLastUpdatedFrame]);
//
//    if ([code_object hasQuadrangle]) {
//      NSLog(@"    Quad = { (%4.1lf, %4.1lf), (%4.1lf, %4.1lf), (%4.1lf, "
//            @"%4.1lf), (%4.1lf, %4.1lf) }",
//            [[code_object getQuadrangle] getPointAt:0].x,
//            [[code_object getQuadrangle] getPointAt:0].y,
//            [[code_object getQuadrangle] getPointAt:1].x,
//            [[code_object getQuadrangle] getPointAt:1].y,
//            [[code_object getQuadrangle] getPointAt:2].x,
//            [[code_object getQuadrangle] getPointAt:2].y,
//            [[code_object getQuadrangle] getPointAt:3].x,
//            [[code_object getQuadrangle] getPointAt:3].y);
//    }
//
//    if ([code_object hasImage]) {
//      NSLog(@"    Image W: %d H: %d", [[code_object getImage] getWidth],
//            [[code_object getImage] getHeight]);
//    }
//
//    NSLog(@"    Fields:");
//    for (SECodeFieldsMapIterator *it_field = [code_object fieldsBegin];
//         ![it_field isEqualToIter:[code_object fieldsEnd]];[it_field advance]) {
//      SECodeFieldRef *code_field = [it_field getValue];
//
//      NSLog(@"      %-21s%@ (%4.3lf)", [[code_field name] UTF8String],
//            [code_field isAccepted] ? @" [+] " : @" [-] ",
//            [code_field getConfidence]);
//
//      if ([code_field hasBinaryRepresentation]) {
//        NSLog(@"        Base64 BinaryRepresentation: %s",
//              [[[code_field getBinaryRepresentation] getBase64String]
//               UTF8String]);
//        NSLog(@"        HexStr BinaryRepresentation: %s",
//              [[[code_field getBinaryRepresentation] getHexString] UTF8String]);
//      }
//
//      if ([code_field hasOcrStringRepresentation]) {
//        NSLog(@"        Ocr string representation: %s",
//              [[[code_field getOcrString] getFirstString] UTF8String]);
//      }
//    }
//    NSLog(@"    Components:");
//    for (SECommonQuadranglesMapIterator *it_comp = [code_object componentsBegin];
//         ![it_comp isEqualToIter:[code_object componentsEnd]];
//             [it_comp advance]) {
//      NSLog(@"      %s = { (%4.0lf, %lf), (%4.0lf, %lf), (%4.0lf, %lf), "
//            @"(%4.0lf, %4.0lf) }",
//            [[it_comp getKey] UTF8String], [[it_comp getValue] getPointAt:0].x,
//            [[it_comp getValue] getPointAt:0].y,
//            [[it_comp getValue] getPointAt:1].x,
//            [[it_comp getValue] getPointAt:1].y,
//            [[it_comp getValue] getPointAt:2].x,
//            [[it_comp getValue] getPointAt:2].y,
//            [[it_comp getValue] getPointAt:3].x,
//            [[it_comp getValue] getPointAt:3].y);
//    }
//
//    NSLog(@"    Attributes:");
//    for (SECommonStringsMapIterator *it_attr = [code_object attributesBegin];
//         ![it_attr isEqualToIter:[code_object attributesEnd]];
//             [it_attr advance]) {
//      NSLog(@"      %s: %s", [[it_attr getKey] UTF8String],
//            [[it_attr getValue] UTF8String]);
//    }
//  }
//  NSLog(@"Result terminal:           %@",
//        [currentResult isTerminal] ? @" [+] " : @" [-] ");
  //debug end
  SECodeEngineResult* result = [currentResult clone];
  _collectingQuadrangles = NO;
//   processing is performed on video queue so forcing main queue
  if ([NSThread isMainThread]) {
    if (delegateReceivesSingleImageResults) {
      [self.engineDelegate SmartCodeEngineObtainedSingleImageResult:result];
    }
  } else {
    dispatch_sync(dispatch_get_main_queue(), ^{
      if (delegateReceivesResults) {
        [self.engineDelegate SmartCodeEngineObtainedSingleImageResult:result];
      }
    });
  }

//  return result;
  return [NSArray arrayWithObjects:result, @(self.processTime), nil];
}

- (nonnull NSArray*) processSingleImageFromFile:(nonnull NSString *)filePath {
  SECommonImage* image = [[SECommonImage alloc] initFromFile:filePath
                                                 withMaxSize:nil];
  return [self processSingleImage:[image getRef]];
}

- (nonnull NSArray*) processSingleImageFromUIImage:(nonnull UIImage *)image {
  SECommonImage* proxyImage = [[SECommonImage alloc] initFromUIImage:image];
  return [self processSingleImage:[proxyImage getRef]];
}

@end

