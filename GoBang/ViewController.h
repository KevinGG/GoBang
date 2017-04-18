//
//  ViewController.h
//  GoBang
//
//  Created by KangNing on 7/12/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

//init extern variables for UIView
- (void)initExternVariables;

- (void)visibleRematchBtn;

@end

typedef NS_ENUM(NSUInteger, GameState){
    olGameWaitingForMatch = 0,
    olGameWaitingForRandomNumber,
    olGameWaitingForStart,
    olGamePlaying,
    olGameEnded
};


typedef NS_ENUM(NSUInteger, MessageType){
    mtRandomNumber = 1,
    mtGameSart,
    mtMove,
    mtGameEnd
};

typedef struct{
    MessageType messageType;
}Message;

typedef struct{
    Message message;
    int randomNumber;
}MessageRandomNumber;

typedef struct{
    Message message;
}MessageStart;

typedef struct{
    Message message;
    CGPoint oneMove;
}MessageMove;

typedef struct{
    Message message;
    BOOL blackWon;
}MessageEnd;


//extern
extern GameState olGameState;
extern BOOL _isBlack;
extern CGPoint olMove;