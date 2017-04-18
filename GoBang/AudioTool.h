//
//  AudioTool.h
//  GoBang
//
//  Created by KangNing on 8/12/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@interface AudioTool : NSObject
+(instancetype)sharedAudioTool;

-(void)playAudioWithPath: (NSString *)path ofType:(NSString *)type times:(int)times;
@end
