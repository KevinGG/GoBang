//
//  GameKitHelper.m
//  GoBang
//
//  Created by KangNing on 8/3/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "GameKitHelper.h"
#import "MainMenuController.h"
NSString *const LocalPlayerIsAuthenticated = @"local_player_authenticated";
NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";

@implementation GameKitHelper{
    BOOL _enableGameCenter;
    BOOL _matchStarted;
}

-(id)init{
    self = [super init];
    if (self) {
        _enableGameCenter = YES;
    }
    return self;
}

//singleton pattern
+(instancetype)sharedGameKitHelper{
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedGameKitHelper = [[GameKitHelper alloc]init];
    });
    return sharedGameKitHelper;
}

-(void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        [self setLastError:error];
        if (viewController !=nil) {
            [self setAuthenticationViewController:viewController];
            
        }else if([GKLocalPlayer localPlayer].isAuthenticated){
            _enableGameCenter = YES;
        }else {
            _enableGameCenter = NO;
        }
    };
}

-(void)authenticateLocalPlayerForMatching{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if(localPlayer.isAuthenticated){
        [[NSNotificationCenter defaultCenter]postNotificationName:LocalPlayerIsAuthenticated object:nil];
        return;
    }
}

- (void)lookupPlayers {
    NSLog(@"Looking up %lu players...", (unsigned long)_match.playerIDs.count);
    [GKPlayer loadPlayersForIdentifiers:_match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            _matchStarted = NO;
            [_delegate matchEnded];
        } else {
            // Populate players dict
            _playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count];
            for (GKPlayer *player in players) {
                NSLog(@"Found player: %@", player.alias);
                [_playersDict setObject:player forKey:player.playerID];
            }
            [_playersDict setObject:[GKLocalPlayer localPlayer] forKey:[GKLocalPlayer localPlayer].playerID];
            
            // Notify delegate match can begin
            _matchStarted = YES;
            [_delegate matchStarted];
        }
    }];
}

-(void)setLastError:(NSError *)error{
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper Error: %@", [[_lastError userInfo]description]);
    }
}

-(void)setAuthenticationViewController:(UIViewController *)authenticationViewController{
    if (authenticationViewController != nil) {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter]postNotificationName:PresentAuthenticationViewController object:self];
    }
}


- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController delegate:(id<GameKitHelperDelegate>)delegate{
    if(!_enableGameCenter){
        return;
    }
    _matchStarted = NO;
    self.match = nil;
    _delegate = delegate;
    //[viewController dismissViewControllerAnimated:NO completion:nil];
    
    GKMatchRequest *request = [[GKMatchRequest alloc]init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc]initWithMatchRequest:request];
    mmvc.matchmakerDelegate = self;
    
    
    [viewController presentViewController:mmvc animated:YES completion:nil];
}

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    self.match = match;
    match.delegate = self;
    if (!_matchStarted && match.expectedPlayerCount == 0) {
        NSLog(@"Ready to start match!");
        [self lookupPlayers];
    }
}

#pragma mark GKMatchDelegate

// The match received data sent from the player.
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    if (_match != match) return;
    
    [_delegate match:match didReceiveData:data fromPlayer:playerID];
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    if (_match != match) return;
    
    switch (state) {
        case GKPlayerStateConnected:
            // handle a new player connection.
            NSLog(@"Player connected!");
            
            if (!_matchStarted && match.expectedPlayerCount == 0) {
                NSLog(@"Ready to start match!");
                [self lookupPlayers];
            }
            
            break;
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            NSLog(@"Player disconnected!");
            _matchStarted = NO;
            [_delegate matchEnded];
            break;
    }
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)match connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    if (_match != match) return;
    
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    _matchStarted = NO;
    [_delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)match didFailWithError:(NSError *)error {
    
    if (_match != match) return;
    
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    _matchStarted = NO;
    [_delegate matchEnded];
}

@end
