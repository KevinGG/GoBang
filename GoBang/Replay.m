//
//  Replay.m
//  GoBang
//
//  Created by KangNing on 8/9/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "Replay.h"
@interface Replay()

@end


@implementation Replay



+(instancetype)replayTool{
    static Replay *replayTool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        replayTool = [[Replay alloc]init];
    });
    return replayTool;
}




@end
