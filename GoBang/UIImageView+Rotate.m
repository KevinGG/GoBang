//
//  UIImageView+Rotate.m
//  GoBang
//
//  Created by KangNing on 8/11/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "UIImageView+Rotate.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImageView(Rotate)
- (void)rotate360WithDuration:(CGFloat)duration repeatCount:(float)repeatCount
{
    
	CABasicAnimation *fullRotation;
	fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	fullRotation.fromValue = [NSNumber numberWithFloat:0];
	fullRotation.toValue = [NSNumber numberWithFloat:((360 * M_PI) / 180)];
	fullRotation.duration = duration;
	if (repeatCount == 0)
		fullRotation.repeatCount = MAXFLOAT;
	else
		fullRotation.repeatCount = repeatCount;
    
	[self.layer addAnimation:fullRotation forKey:@"360"];
}

- (void)stopAllAnimations
{
    
	[self.layer removeAllAnimations];
};

- (void)pauseAnimations
{
	[self pauseLayer:self.layer];
}

- (void)resumeAnimations
{
	[self resumeLayer:self.layer];
}

- (void)pauseLayer:(CALayer *)layer
{
    
	CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
	layer.speed = 0.0;
	layer.timeOffset = pausedTime;
}

- (void)resumeLayer:(CALayer *)layer
{
    
	CFTimeInterval pausedTime = [layer timeOffset];
	layer.speed = 1.0;
	layer.timeOffset = 0.0;
	layer.beginTime = 0.0;
	CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
	layer.beginTime = timeSincePause;
}


#pragma mark lower Way
+ (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration
              curve:(int)curve degrees:(CGFloat)degrees
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationRepeatCount:INFINITY];
    
    // The transform matrix
    CGAffineTransform transform =
    CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
    image.transform = transform;
    
    // Commit the changes
    [UIView commitAnimations];
}

+ (void)flipButton:(UIButton *)image duration:(NSTimeInterval)duration curve:(int)curve
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationRepeatCount:INFINITY];
    CGAffineTransform transform;
    // The transform matrix
    transform = CGAffineTransformMakeScale(-1, 1);
    image.transform = transform;
    // Commit the changes
    [UIView commitAnimations];
}

@end
