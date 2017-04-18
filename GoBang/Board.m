//
//  Board.m
//  GoBang
//
//  Created by KangNing on 7/16/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "Board.h"
@interface Board()

@end

static id GameBoard = nil;

@implementation Board

@synthesize cells;


+ (id) GameBoard{
    
    if (!GameBoard) {
        GameBoard = [[super alloc]init];
        [GameBoard initBoard];
        [GameBoard initMoves];
    }
    
    return GameBoard;
}

- (NSMutableArray *)moves{
    if(!_moves){
        _moves = [[NSMutableArray alloc]init];
    }
    return _moves;
}

- (void)initBoard{
    if (GameBoard) {
        cells = [[NSMutableArray alloc]initWithCapacity:15];
        for (int i=0; i<15; i++) {
            cells[i] = [[NSMutableArray alloc]initWithCapacity:15];
        }
        for (int i=0; i<15; i++) {
            for (int j=0; j<15; j++) {
                cells[i][j]=@"e";
            }
        }
    }
}

//test if game over with 5 in line
- (Boolean)test5{
    for (int i=0; i<15; i++) {
        for (int j=0; j<15; j++) {
            if (![cells[i][j] isEqualToString:@"e"]) {
                int flag=1;
                //vertical
                if (i<=10) {
                    for (int k=1; k<=4; k++) {
                        if (![cells[i][j] isEqualToString:cells[i+k][j]]) {
                            flag=0;
                            break;
                        }
                    }
                    if (flag==1) {
                        return YES;
                    }else{
                        flag=1;
                    }
                }
                
                //horizontal
                if (j<=10) {
                    for (int k=1; k<=4; k++) {
                        if (![cells[i][j] isEqualToString:cells[i][j+k]]) {
                            flag=0;
                            break;
                        }
                    }
                    
                    if (flag==1) {
                        return YES;
                    }else{
                        flag=1;
                    }
                }
                
                //diagoal rightdown
                if (i<=10 && j<=10) {
                    for (int k=1; k<=4; k++) {
                        if (![cells[i][j] isEqualToString:cells[i+k][j+k]]) {
                            flag=0;
                            break;
                        }
                    }
                    if (flag==1) {
                        return YES;
                    }else{
                        flag=1;
                    }
                }
                
                //diagobal leftdown
                if (j>=4 && i<=10) {
                    for (int k=1; k<=4; k++) {
                        if (![cells[i][j] isEqualToString:cells[i+k][j-k]]) {
                            flag=0;
                            break;
                        }
                    }
                    if (flag==1) {
                        return YES;
                    }
                }
                
            }
        }
    }
    return NO;
}

//start a new game by init board
- (void)newGame{
    if (GameBoard) {
        [GameBoard initBoard];
    }
}

+ (void)initB{
    if (GameBoard) {
        [GameBoard initBoard];
    }
}

- (void)initMoves{
    if (_moves){
        [_moves removeAllObjects];
    }
}

@end
