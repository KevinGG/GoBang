//
//  Paint.m
//  GoBang
//
//  Created by KangNing on 7/16/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "Paint.h"

@interface Paint()

@property (nonatomic) CGContextRef ctx;

@end

@implementation Paint


- (instancetype)initWithCtx:(CGContextRef)ctx{
    self = [super init];
    
    if (self) {
        self.ctx=ctx;
    }
    
    return self;
}


- (void)drawLineFrom:(CGPoint)start to:(CGPoint)end withWidth:(int)width{
    const CGPoint points[] = {start,end};
    CGContextSetLineWidth(self.ctx, width);
    CGContextSetRGBStrokeColor(self.ctx, 0, 0, 0, 1);
    CGContextStrokeLineSegments(self.ctx, points, 2);
}

- (void)drawCircleAt:(CGPoint)point size:(int)r{
    CGContextFillEllipseInRect(self.ctx, CGRectMake(point.x-r/2, point.y-r/2, r, r));
}
@end
