//
//  Board.h
//  GoBang
//
//  Created by KangNing on 7/16/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Board : NSObject

+ (id) GameBoard;

- (Boolean)test5;

- (void)newGame;

+ (void)initB;

- (void)initMoves;

@property(nonatomic, readwrite)NSMutableArray *cells;
@property(nonatomic, readwrite)NSMutableArray *moves;

@end
