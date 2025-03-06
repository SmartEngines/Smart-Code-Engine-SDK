/*
 Copyright (c) 2016-2024, Smart Engines Service LLC
 All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "CameraFocusSquare.h"
#import <QuartzCore/QuartzCore.h>

const float squareLength = 80.0f;
@implementation CameraFocusSquare

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setBorderWidth:2.0];
        [self.layer setCornerRadius:4.0];
        [self.layer setBorderColor:[UIColor whiteColor].CGColor];

        CABasicAnimation* selectionAnimation = [CABasicAnimation
                                                animationWithKeyPath:@"borderColor"];
        selectionAnimation.toValue = (id)[UIColor blueColor].CGColor;
        selectionAnimation.repeatCount = 16;
        [self.layer addAnimation:selectionAnimation
                          forKey:@"selectionAnimation"];

    }
    return self;
}
@end

