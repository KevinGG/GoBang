//
//  Paint.h
//  GoBang
//
//  Created by KangNing on 7/16/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Paint : NSObject
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
- (instancetype)initWithCtx:(CGContextRef)ctx;
- (void)drawLineFrom:(CGPoint)start to:(CGPoint)end withWidth:(int)width;
- (void)drawCircleAt:(CGPoint)point size:(int)r;
@end
