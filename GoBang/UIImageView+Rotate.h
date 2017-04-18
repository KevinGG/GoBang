//
//  UIImageView+Rotate.h
//  GoBang
//
//  Created by KangNing on 8/11/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

@interface UIImageView(Rotate)
- (void)rotate360WithDuration:(CGFloat)duration repeatCount:(float)repeatCount;

- (void)pauseAnimations;
- (void)resumeAnimations;
- (void)stopAllAnimations;


+(void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration
             curve:(int)curve degrees:(CGFloat)degrees;

+ (void)flipButton:(UIButton *)image duration:(NSTimeInterval)duration curve:(int)curve;

@end
