//
//  GameKitHelper.h
//  GoBang
//
//  Created by KangNing on 8/3/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GameKit;

@protocol GameKitHelperDelegate

- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;

@end

@interface GameKitHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate>

@property (nonatomic, strong) NSMutableDictionary *playersDict;

@property (nonatomic, strong)GKMatch *match;

@property (nonatomic, assign)id <GameKitHelperDelegate> delegate;

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController delegate:(id<GameKitHelperDelegate>)delegate;

@property (nonatomic, readonly)UIViewController *authenticationViewController;

@property (nonatomic, readonly)NSError *lastError;

+(instancetype)sharedGameKitHelper;

-(void)authenticateLocalPlayer;

-(void)authenticateLocalPlayerForMatching;

@end


extern NSString *const PresentAuthenticationViewController;
extern NSString *const LocalPlayerIsAuthenticated;