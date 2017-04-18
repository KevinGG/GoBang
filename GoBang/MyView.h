//
//  MyView.h
//  GoBang
//
//  Created by KangNing on 7/12/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Paint.h"
#import "ViewController.h"

@interface MyView : UIView

//invisiblize the regame btn for general usage
- (void)invisibleReGameBtn;
- (void)invisibleWithdrawBtn;


//called when move data received
- (void)olOppoMove;

//called when olend data received
- (void)olAlert:(NSString *)winner Alias: (NSString*) winnerId defeat:(NSString *)loser Alias: (NSString *)loserId;

//called when
- (void)reMatchInit;


@end
