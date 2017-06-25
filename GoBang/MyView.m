//
//  MyView.m
//  GoBang
//
//  Created by KangNing on 7/12/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "MyView.h"
#import "Board.h"
#import "MainMenuController.h"
#import "AI.h"
#import "GameKitHelper.h"
#import "ViewController.h"
#import "AudioTool.h"

@interface MyView()

@property (nonatomic, strong) Board *GameBoard;
@property (nonatomic, readwrite) NSString *currentPlayer;
@property (weak, nonatomic) IBOutlet UILabel *turnLabel;
@property (weak, nonatomic) IBOutlet UIButton *reGame;
@property (weak, nonatomic) IBOutlet UIImageView *cpImg;
@property (strong, nonatomic)NSString *gameMode;
@property (weak, nonatomic) IBOutlet UIButton *withdrawBtn;
@property (weak, nonatomic) IBOutlet UILabel *yourTurnLabel;
@property (weak, nonatomic) IBOutlet UIButton *reOlMatchBtn;
@property (weak, nonatomic) IBOutlet UIButton *mainMenuBtn;

@end
@implementation MyView{
    CGFloat cellSize;
}

int gameStatus=2;
NSString *const pvpMode = @"pvp";
NSString *const pveMode = @"pve";
NSString *const olMode = @"ol";

// extern from mainmenu controller
extern NSString * Gmode;
extern NSString * playerColor;
extern int AI1stFlg;

// extern from view controller
extern GameState olGameState;
extern BOOL _isBlack;
extern CGPoint olMove;

int px;//click position
int py;//click position

// index of board logic
int ix;
int iy;

- (NSString *)gameMode{
    if (!_gameMode) {
        _gameMode = Gmode;
    }
    return _gameMode;
}

- (CGFloat) cellSize{
    if(!cellSize){
        cellSize = screenHeight() / (CELL_NUM + 1);
    }
    return cellSize;
}

- (Board *)GameBoard{
    if (!_GameBoard) {
        _GameBoard = [Board GameBoard];
        gameStatus = 1;
    }
    return _GameBoard;
}

- (NSString *)currentPlayer{
    if(!_currentPlayer){
        _currentPlayer = @"b";
    }
    return _currentPlayer;
}

- (UIImageView *)cpImg{
    if(!_cpImg){
        return [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"black"]];
    }
    return _cpImg;
}

- (UIImage *)imgCurrentPlayer:(NSString *)cp{
    if ([self.currentPlayer isEqualToString:@"b"]) {
        return [UIImage imageNamed:@"black.png"];
    }else{
        return [UIImage imageNamed:@"white.png"];
    }
}

#pragma mark recording system
- (void)recordMoveAtX:(int)x Y:(int)y{
    CGPoint p = CGPointMake(x, y);
    NSValue *v = [NSValue valueWithCGPoint:p];
    [self.GameBoard.moves addObject:v];
}

- (IBAction)withDraw:(id)sender {
    if(![self.gameMode isEqualToString:olMode] && gameStatus != 0 && (([self.GameBoard.moves count]>0 && ![self.gameMode isEqualToString:pveMode]) || (AI1stFlg != 0 && [self.gameMode isEqualToString:pveMode] && [self.GameBoard.moves count]>2) )){
        [self withDrawLastMove];
        //AI mode move back twice
        if([self.gameMode isEqualToString:pveMode]){
            [self withDrawLastMove];
        }
    }
}

- (void)withDrawLastMove{
    CGPoint p = [[self.GameBoard.moves lastObject]CGPointValue];
    [self.GameBoard.moves removeLastObject];
    NSLog(@"%lu", (unsigned long)[self.GameBoard.moves count]);
    self.GameBoard.cells[(int)p.x][(int)p.y]=@"e";
    //change current player back
    [self.currentPlayer isEqualToString:@"b"]?(self.currentPlayer=@"w"):(self.currentPlayer=@"b");//change cp
    [self.currentPlayer isEqualToString:@"b"]?(self.turnLabel.textColor = [UIColor blackColor] ):(self.turnLabel.textColor = [UIColor whiteColor]);
    self.cpImg.image = [self imgCurrentPlayer:self.currentPlayer];
    [self setNeedsDisplay];

}

#pragma mark player and AI moves in 3 modes

//---fired when the user finger(s) touches the screen---
-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event{
    [self setNeedsDisplay];
    if ([self.gameMode isEqualToString:pvpMode]) {
        [self pvp:touches];
        [[AudioTool sharedAudioTool] playAudioWithPath:@"dropPiece" ofType:@"mp3" times:1];
    }else if([self.gameMode isEqualToString:pveMode]){
        [self pve:touches];
        [[AudioTool sharedAudioTool] playAudioWithPath:@"dropPiece" ofType:@"mp3" times:1];
    }else if([self.gameMode isEqualToString:olMode]){
        //NSLog(@"olTouched");
        [self ol:touches];
        [[AudioTool sharedAudioTool] playAudioWithPath:@"dropPiece" ofType:@"mp3" times:1];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([self.gameMode isEqualToString:pveMode]) {
        [self AIMove];
        [[AudioTool sharedAudioTool] playAudioWithPath:@"dropPiece" ofType:@"mp3" times:1];
        [NSThread sleepForTimeInterval:0.1];
    }
}

- (void) pve: (NSSet *)touches{
    if (gameStatus!=0 && self.currentPlayer==playerColor) {
        [self playerMove:touches];
    }
}

- (void) pvp: (NSSet *)touches{
    [self playerMove:touches];
}

- (void) ol: (NSSet *)touches{
    if (gameStatus!=0 && self.currentPlayer==playerColor && olGameState == olGamePlaying) {
        [self playerMove:touches];
    }
}

- (void) playerMove: (NSSet *)touches{
    CGPoint moveTobeSent;
    if (gameStatus!=0) {
        const int CELL_SIZE = [self cellSize];
        const int TOUCHABLE_UPPERBOUND = screenHeight() - CELL_SIZE / 2;
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        if (point.x>=CELL_SIZE/2 && point.x<=TOUCHABLE_UPPERBOUND && point.y>=CELL_SIZE && point.y<=TOUCHABLE_UPPERBOUND) {
            int tpx = (int)point.x%CELL_SIZE>CELL_SIZE/2? (int)point.x/CELL_SIZE*CELL_SIZE+CELL_SIZE: (int)point.x/CELL_SIZE*CELL_SIZE;
            int tpy = (int)point.y%CELL_SIZE>CELL_SIZE/2? (int)point.y/CELL_SIZE*CELL_SIZE+CELL_SIZE: (int)point.y/CELL_SIZE*CELL_SIZE;
            ix = tpx/CELL_SIZE-1;
            iy = tpy/CELL_SIZE-1;
            ix = (ix>=CELL_NUM)?ix--:ix;
            iy = (iy>=CELL_NUM)?iy--:iy;
            if ([self.GameBoard.cells[ix][iy] isEqualToString:@"e"]) {
                moveTobeSent = CGPointMake(ix, iy);
                px=tpx;
                py=tpy;
                self.GameBoard.cells[ix][iy] = self.currentPlayer;
                [self recordMoveAtX:ix Y:iy];
                [self.currentPlayer isEqualToString:@"b"]?(self.currentPlayer=@"w"):(self.currentPlayer=@"b");
                //if olMode, send move
                if([self.gameMode isEqualToString:olMode]){
                    [self sendMove:moveTobeSent];
                }
            }
        }
        [self.currentPlayer isEqualToString:@"b"]?(self.turnLabel.textColor = [UIColor blackColor] ):(self.turnLabel.textColor = [UIColor whiteColor]);
        self.cpImg.image = [self imgCurrentPlayer:self.currentPlayer];
        
        [self gameOver];
        [self setNeedsDisplay];
    }
}


- (void) AIMove{
    if (gameStatus!=0 && self.currentPlayer!=playerColor) {
        CGPoint aiMove = [AI pieceLocation];
        ix = aiMove.x;
        iy = aiMove.y;
        
        if ([self.GameBoard.cells[ix][iy] isEqualToString:@"e"]) {
            self.GameBoard.cells[ix][iy] = self.currentPlayer;
            [self recordMoveAtX:ix Y:iy];
            [self.currentPlayer isEqualToString:@"b"]?(self.currentPlayer=@"w"):(self.currentPlayer=@"b");
        }
        [self.currentPlayer isEqualToString:@"b"]?(self.turnLabel.textColor = [UIColor blackColor] ):(self.turnLabel.textColor = [UIColor whiteColor]);
        self.cpImg.image = [self imgCurrentPlayer:self.currentPlayer];
        [self gameOver];
        [self setNeedsDisplay];
    }
}

- (void) olOppoMove{
    ix = olMove.x;
    iy = olMove.y;
    
    self.GameBoard.cells[ix][iy] = self.currentPlayer;//set the move
    [self recordMoveAtX:ix Y:iy];
    [self.currentPlayer isEqualToString:@"b"]?(self.currentPlayer=@"w"):(self.currentPlayer=@"b");//change cp
    
    [self.currentPlayer isEqualToString:@"b"]?(self.turnLabel.textColor = [UIColor blackColor] ):(self.turnLabel.textColor = [UIColor whiteColor]);
    self.cpImg.image = [self imgCurrentPlayer:self.currentPlayer];
    [self gameOver];
    [self setNeedsDisplay];

}

- (void) gameOver{
    if(gameStatus!=0 && [self.GameBoard test5]){
        if (![self.gameMode isEqualToString:olMode]) {
            [self alert];
        }
        if (olGameState == olGamePlaying) {
            olGameState = olGameEnded;
            [self sendEnd];
        }
        gameStatus=0;
        self.cpImg.image = [UIImage imageNamed:@"gameover.png"];
        self.turnLabel.text = @" ";
        self.currentPlayer = @"b";
        if ([playerColor isEqualToString:@"w"]) {
            AI1stFlg=0;
        }else{
            AI1stFlg=1;
        }
    }
    [self setNeedsDisplay];
}

- (void) sendEnd{
    MessageEnd messageEnd;
    messageEnd.message.messageType = mtGameEnd;
    messageEnd.blackWon = ([self.currentPlayer isEqualToString:@"w"]?YES:NO);
    NSData *data = [NSData dataWithBytes:&messageEnd length:sizeof(MessageEnd)];
    [self sendData:data];
}

CGPoint pointsUp[15];
CGPoint pointsDown[15];
CGPoint pointsLeft[15];
CGPoint pointsRight[15];

- (void)alert{
    NSString *cp;
    if ([self.currentPlayer isEqualToString:@"w"]) {
        cp=@"Black";
    }else{
        cp=@"White";
    }
    NSString *message = [cp stringByAppendingString:@" Wins"];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Game Over"
                          message:message delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:nil,nil];
    [alert show];
}

- (void)olAlert:(NSString *)winnerId Alias: (NSString*) winner defeat:(NSString *)loserId Alias: (NSString *)loser{
    NSString *winStr;
    NSString *loseStr;
    NSString *message;
    if ([[GKLocalPlayer localPlayer].playerID isEqualToString:winnerId]) {
        winStr = [@"You - " stringByAppendingString:winner];
        loseStr = [@"Opponent - " stringByAppendingString:loser];
    }else{
        winStr = [@"Opponent - " stringByAppendingString:winner];
        loseStr = [@"You - " stringByAppendingString:loser];
    }
   
    message = [[winStr stringByAppendingString:@"\r\n Defeated \r\n"] stringByAppendingString:loseStr];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Game Over"
                          message:message delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:nil,nil];
    [alert show];
}


- (IBAction)reGame:(UIButton *)sender {
    [self.GameBoard initMoves];
    [self.GameBoard newGame];
    gameStatus = 1;
    self.currentPlayer = @"b";
    self.cpImg.image = [self imgCurrentPlayer:self.currentPlayer];
    self.turnLabel.text = @"TURN";
    self.turnLabel.textColor = [UIColor blackColor];
    if ([playerColor isEqualToString:@"w"]) {
        AI1stFlg=0;
    }else{
        AI1stFlg=1;
    }
    [self setNeedsDisplay];
}

- (void)reMatchInit{
    [self.GameBoard newGame];
    gameStatus = 1;
    self.currentPlayer = @"b";
    self.cpImg.image = [self imgCurrentPlayer:self.currentPlayer];
    self.turnLabel.text = @"TURN";
    self.turnLabel.textColor = [UIColor blackColor];
    [self setNeedsDisplay];
}

#pragma mark UI_CONTROL

- (void)invisibleReGameBtn{
    self.reGame.hidden = YES;
}

- (void)invisibleWithdrawBtn{
    self.withdrawBtn.hidden = YES;
}

- (void)initYourTurnLabel:(CGRect)rect{
    [self.yourTurnLabel setFrame:rect];
}

- (void)initCurrentPlayerLabel:(CGRect)rect{
    [self.cpImg setFrame:rect];
}

- (void)initTurnLabel:(CGRect)rect{
    [self.turnLabel setFrame:rect];
}

- (void)initRedoLastMoveLabel:(CGRect)rect{
    [self.withdrawBtn setFrame:rect];
}

- (void)initNewGameBtn:(CGRect)rect{
    [self.reGame setFrame:rect];
}

- (void)initRematchBtn:(CGRect)rect{
    [self.reOlMatchBtn setFrame:rect];
}

- (void)initMainMenuLabel:(CGRect)rect{
    [self.mainMenuBtn setFrame:rect];
}


- (void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self drawBoard:ctx];
}

- (void)drawBoard:(CGContextRef)ctx{
    if (AI1stFlg==0 && [self.gameMode isEqualToString:pveMode]) {
        [self AIMove];
        [[AudioTool sharedAudioTool] playAudioWithPath:@"dropPiece" ofType:@"mp3" times:1];
        AI1stFlg =1;
    }
    const int CELL_SIZE = [self cellSize];
    CGContextMoveToPoint(ctx, CELL_SIZE, CELL_SIZE);
    Paint *p = [[Paint alloc]initWithCtx:ctx];
    for (int i = 1; i <= CELL_NUM; i++) {
        pointsUp[i-1]=CGPointMake(CELL_SIZE*i,CELL_SIZE);
        pointsDown[i-1]=CGPointMake(CELL_SIZE*i, CELL_SIZE*CELL_NUM);
        pointsLeft[i-1]=CGPointMake(CELL_SIZE, CELL_SIZE*i);
        pointsRight[i-1]=CGPointMake(CELL_SIZE*CELL_NUM, CELL_SIZE*i);
    }
    
    for (int i = 0; i < CELL_NUM; i++){
        [p drawLineFrom:pointsUp[i] to:pointsDown[i] withWidth:1];
        [p drawLineFrom:pointsLeft[i] to:pointsRight[i] withWidth:1];
    }
    for (int i=0; i<CELL_NUM; i++) {
        for (int j=0; j<CELL_NUM; j++) {
            if ([self.GameBoard.cells[i][j] isEqualToString:@"b"]) {
                CGContextSetFillColorWithColor(ctx, [[UIColor blackColor]CGColor]);
                [p drawCircleAt:CGPointMake(CELL_SIZE*i+CELL_SIZE, CELL_SIZE*j+CELL_SIZE) size:CELL_SIZE-3];
            }else if([self.GameBoard.cells[i][j] isEqualToString:@"w"]){
                CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor]CGColor]);
                [p drawCircleAt:CGPointMake(CELL_SIZE*i+CELL_SIZE, CELL_SIZE*j+CELL_SIZE) size:CELL_SIZE-3];
            }
        }
    }
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

- (void)sendMove:(CGPoint)oneMove{
    MessageMove messageMove;
    messageMove.message.messageType = mtMove;
    messageMove.oneMove = oneMove;
    
    NSData *data = [NSData dataWithBytes:&messageMove length:sizeof(MessageMove)];
    [self sendData:data];
}

@end
