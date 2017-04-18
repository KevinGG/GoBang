//
//  AudioTool.m
//  GoBang
//
//  Created by KangNing on 8/12/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "AudioTool.h"
@interface AudioTool()
@property (nonatomic, strong)AVAudioPlayer *player;
@end
@implementation AudioTool
+(instancetype)sharedAudioTool{
    static AudioTool *audioTool;
    if(!audioTool){
        audioTool = [[AudioTool alloc]init];
    }
    return audioTool;
}

-(void)playAudioWithPath: (NSString *)path ofType:(NSString *)type times:(int)times{
    NSString *soundFilePath = @"dropPiece.mp3";
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    self.player.numberOfLoops = times; //-1 as Infinite
    [self.player play];
}
@end
