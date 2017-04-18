//
//  ViewController.m
//  GoBang
//
//  Created by KangNing on 7/12/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "ViewController.h"
#import "MainMenuController.h"
#import "Board.h"
#import "GameKitHelper.h"
#import "MyView.h"

//extern from MainMenuController
extern NSString *Gmode;
extern NSString *const LocalPlayerIsAuthenticated;

extern NSString *playerColor;

//extern for MyView
GameState olGameState;
BOOL _isBlack, _receivedAllRandomNumbers;
CGPoint olMove;


@interface ViewController()<GameKitHelperDelegate>
@property (weak, nonatomic) IBOutlet UIButton *rematchBtn;
@property (weak, nonatomic) IBOutlet UILabel *YouLabel;

@end

@implementation ViewController{
}

int olRandomNum = 0;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgBoard.png"]]];
}


-(void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticateLocalPlayerForMatching) name:LocalPlayerIsAuthenticated object:nil];

    if ([Gmode isEqualToString:@"ol"]) {
        [self visibleRematchBtn];
        NSLog(@"in");
        [[GameKitHelper sharedGameKitHelper]authenticateLocalPlayerForMatching];
    }
    [self initYouLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backMain:(id)sender {
    [Board initB];
    MainMenuController *mainMenuController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainMenu"];
    [self presentViewController:mainMenuController animated:YES completion:^{[mainMenuController initMainMenuBtns];}];
}

- (IBAction)rematch:(id)sender {
    [(MyView *)self.view reMatchInit];
    [[GameKitHelper sharedGameKitHelper]authenticateLocalPlayerForMatching];
}


-(void)authenticateLocalPlayerForMatching{
    [[GameKitHelper sharedGameKitHelper] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self delegate:self];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


#pragma mark InitOlVar

- (void) initExternVariables{
    olGameState = olGameWaitingForMatch;
}

# pragma mark viewObject
- (void)visibleRematchBtn{
    self.rematchBtn.hidden = NO;
}

- (void)disableRematchBtn{
    [self.rematchBtn setEnabled:NO];
}

- (void)enableRematchBtn{
    [self.rematchBtn setEnabled:YES];
}

- (void)initYouLabel{
    NSString *color = [playerColor isEqualToString:@"w"]?@"White":@"Black";
    UIColor *textColor = [playerColor isEqualToString:@"w"]?[UIColor whiteColor]:[UIColor blackColor];
    if ([Gmode isEqualToString:@"pvp"]) {
        self.YouLabel.text = @" ";
    }else if([Gmode isEqualToString:@"pve"] || [Gmode isEqualToString:@"ol"]){
        self.YouLabel.text = [@"You get " stringByAppendingString:color];
    }
    self.YouLabel.textColor = textColor;
}




#pragma mark MultiplayerNetworking
-(void)sendData:(NSData*)data{
    NSError *error;
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    
    BOOL success = [gameKitHelper.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    
    if (!success) {
        NSLog(@"Error sending data: %@", error.localizedDescription);
        [gameKitHelper.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    }
}




#pragma mark GameKitHelperDelegate

- (void)matchStarted {
    NSLog(@"Match started");
    olGameState = olGameWaitingForRandomNumber;
    [self sendRandomNum];
}

- (void)sendRandomNum{
    MessageRandomNumber message;
    message.message.messageType=mtRandomNumber;
    olRandomNum = arc4random()%100000+1;
    NSLog(@"Generated Random Number: %d", olRandomNum);
    message.randomNumber=olRandomNum;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
    [self sendData:data];
}

- (void)tryStartGame{
    if(_isBlack && olGameState == olGameWaitingForStart){
        olGameState = olGamePlaying;
        [self sendStart];
    }
    [self disableRematchBtn];
}

- (void)sendStart{
    MessageStart message;
    message.message.messageType = mtGameSart;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageStart)];
    [self sendData:data];
}


- (void)matchEnded {
    NSLog(@"Match ended");
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    Message *message = (Message*)[data bytes];
    if(message->messageType == mtRandomNumber){
        MessageRandomNumber *messageRandomNumber = (MessageRandomNumber *)[data bytes];
        NSLog(@"Received random number: %d", messageRandomNumber->randomNumber);
        if(messageRandomNumber->randomNumber !=0){
            if (olRandomNum > messageRandomNumber->randomNumber) {
                _isBlack = YES;
                playerColor = @"b";
                [self initYouLabel];
                NSLog(@"MyColor: %@",playerColor);
                olGameState = olGameWaitingForStart;
                [self tryStartGame];
            }else if(olRandomNum < messageRandomNumber->randomNumber){
                _isBlack = NO;
                playerColor = @"w";
                [self initYouLabel];
                NSLog(@"MyColor: %@",playerColor);
                olGameState = olGameWaitingForStart;
            }else{
                [self sendRandomNum];
            }
        }
    }else if(message->messageType == mtGameSart){
        olGameState = olGamePlaying;
        [self disableRematchBtn];
    }else if(message->messageType == mtMove){
        MessageMove *messageMove = (MessageMove *)[data bytes];
        olMove = messageMove->oneMove;
        [(MyView *)self.view olOppoMove];
    }else if(message->messageType == mtGameEnd){
        MessageEnd *messageEnd = (MessageEnd *)[data bytes];
        olGameState = olGameEnded;
        GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
        NSArray *players = [gameKitHelper.playersDict allValues];
        NSArray *playerIds = [gameKitHelper.playersDict allKeys];
        NSMutableArray *playerAliases = [[NSMutableArray alloc]initWithCapacity:2];
        for (int i = 0; i < players.count; i++) {
            [playerAliases addObject:[[players objectAtIndex:i]alias]];
        }
        NSString *localPlayerId = [GKLocalPlayer localPlayer].playerID;
        NSString *localPlayerAlias = [GKLocalPlayer localPlayer].alias;
        
        NSString *otherPlayerId = playerID;
        NSString *otherPlayerAlias = [[gameKitHelper.playersDict objectForKey:otherPlayerId] alias];
        
        
        NSLog(@"%@", players);
        NSLog(@"%@", playerIds);
        NSLog(@"%@", playerAliases);
        
        if((_isBlack && messageEnd->blackWon) || (!_isBlack && !messageEnd->blackWon)){
            [(MyView *)self.view olAlert:localPlayerId Alias:localPlayerAlias defeat:otherPlayerId Alias:otherPlayerAlias];
        }else{
            [(MyView *)self.view olAlert:otherPlayerId Alias:otherPlayerAlias defeat:localPlayerId Alias:localPlayerAlias];
        }
        [self enableRematchBtn];
    }
    
}
@end
