//
//  AI.m
//  GoBang
//
//  Created by KangNing on 7/19/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "AI.h"
#import "Board.h"
@interface AI()

@end

@implementation AI

NSInteger get5=20000000;
NSInteger alive4=5000000;
NSInteger alive3=1000;
NSInteger dead4=500;
NSInteger dead3=100;
NSInteger alive2=50;
NSInteger dead2=5;
NSInteger o1=0;

//tmp array for storing scores
int ai[15][15];
int player[15][15];
int sum[15][15];
NSMutableArray *bestMoves;
Board *gb;

static NSString *AIColor;
static NSString *playerColor;

+(void)setAIColor:(NSString *)c{
    AIColor=c;
    playerColor=([AIColor isEqualToString:@"b"]?@"w":@"b");
}

//return the piece index Location of the AI move based on the gameboard situation
+(CGPoint)pieceLocation{
    gb=[Board GameBoard];
    [AI clearTmpArrays];
    CGFloat x = 0;
    CGFloat y = 0;
    int tmp=0;
    bestMoves =[[NSMutableArray alloc]init];
    for (int i=0; i<15; i++) {
        for (int j=0; j<15; j++) {
            ai[i][j]=[AI scoreAtX:i Y:j withColor:AIColor];
            player[i][j]=[AI scoreAtX:i Y:j withColor:playerColor];
            sum[i][j]=ai[i][j]+player[i][j];
            //the position closer to the center would get a better bonus score
            int positionXBonus = (i+1 > 6 && i+1 <10 && j+1 > 6 && j+1 < 10)?arc4random()%9+1:0;
            int positionYBonus = (i+1 > 6 && i+1 <10 && j+1 > 6 && j+1 < 10)?arc4random()%9+1:0;
            sum[i][j]+=positionXBonus+positionYBonus;
            
            if (sum[i][j]>=0 && sum[i][j]==tmp) {
                [bestMoves addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
            }else if(sum[i][j]>tmp){
                tmp=sum[i][j];
                [bestMoves removeAllObjects];
                [bestMoves addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
            }
        }
    }
    
    int numOfBestMoves = (int)[bestMoves count];
    int index=arc4random()%numOfBestMoves;
    x=[[bestMoves objectAtIndex:index] CGPointValue].x ;
    y=[[bestMoves objectAtIndex:index] CGPointValue].y ;
    return CGPointMake(x, y);
}


+(int)scoreAtX:(int)x Y:(int)y withColor:(NSString*)color{
    NSString *v=gb.cells[x][y];
    int score=0;
    if (![v isEqualToString:@"e"]) {
        score = -1;
    }else{
        score=[AI lookAroundAtX:x Y:y withColor:color];
    }
    
    return score;
}

+(int)lookAroundAtX:(int)x Y:(int)y withColor:(NSString*)color{
    int result=0;
    int left = y;
    int right = 14-y;
    int up = x;
    int down = 14-x;
    
    int i=1;
    int count = 1;//count for same color in a line: 1~5 or more
    int dCount = 0;//count for dead end in a line 0~2
    
    if (left==0) {
        dCount++;
    }
    if (right==0) {
        dCount++;
    }
    if (up==0) {
        dCount++;
    }
    if (down==0) {
        dCount++;
    }
    
    int alive3Count=0;
    int dead4Count=0;
    int alive4Flg=0;
    //up & down   verticle check
    while (i<=up) {
        NSString *v=gb.cells[x-i][y];
        if ([v isEqualToString:color]) {//same color
            count++;
        }else if(![v isEqualToString:@"e"]){//diff color == dead end
            dCount++;
            break;
        }else{//live end
            break;
        }
        if (count>=5) {
            break;
        }
        i++;
    }
    i=1;
    while (i<=down) {
        NSString *v=gb.cells[x+i][y];
        if ([v isEqualToString:color]) {
            count++;
        }else if(![v isEqualToString:@"e"]){
            dCount++;
            break;
        }else{
            break;
        }
        if (count>=5) {
            break;
        }
        i++;
    }
    i=1;
    if (count==3 && dCount==0) {
        alive3Count++;
    }else if(count==4 && dCount==1){
        dCount++;
    }
    result+=[AI getScoreBasedOnCount:count dCount:dCount withColor:color];
    
    
    count=1;
    dCount=0;
    //left&right horizontal check
    while (i<=left) {
        NSString *v=gb.cells[x][y-i];
        if ([v isEqualToString:color]) {//same color
            count++;
        }else if(![v isEqualToString:@"e"]){//diff color == dead end
            dCount++;
            break;
        }else{//live end
            break;
        }
        if (count>=5) {
            break;
        }
        i++;
    }
    i=1;
    while (i<=right) {
        NSString *v=gb.cells[x][y+i];
        if ([v isEqualToString:color]) {
            count++;
        }else if(![v isEqualToString:@"e"]){
            dCount++;
            break;
        }else{
            break;
        }
        if (count>=5) {
            break;
        }
        i++;
    }
    i=1;
    if (count==3 && dCount==0) {
        alive3Count++;
    }else if(count==4 && dCount==1){
        dCount++;
    }
    if (alive4Flg==0) {
        if (alive3Count>=2) {
            result+=alive4;
        }else if(alive3Count>=1 && dead4Count>=1){
            result+=alive4;
        }
        alive4Flg=1;
    }
    result+=[AI getScoreBasedOnCount:count dCount:dCount withColor:color];
    
    
    count=1;
    dCount=0;
    //leftUp & rightDown check
    while (i<=left && i<=up) {
        NSString *v=gb.cells[x-i][y-i];
        if ([v isEqualToString:color]) {//same color
            count++;
        }else if(![v isEqualToString:@"e"]){//diff color == dead end
            dCount++;
            break;
        }else{//live end
            break;
        }
        if (count>=5) {
            break;
        }
        i++;
    }
    i=1;
    while (i<=right && i<=down) {
        NSString *v=gb.cells[x+i][y+i];
        if ([v isEqualToString:color]) {
            count++;
        }else if(![v isEqualToString:@"e"]){
            dCount++;
            break;
        }else{
            break;
        }
        if (count>=5) {
            break;
        }
        i++;
    }
    i=1;
    if (count==3 && dCount==0) {
        alive3Count++;
    }else if(count==4 && dCount==1){
        dCount++;
    }
    if (alive4Flg==0) {
        if (alive3Count>=2) {
            result+=alive4;
        }else if(alive3Count>=1 && dead4Count>=1){
            result+=alive4;
        }
        alive4Flg=1;
    }
    result+=[AI getScoreBasedOnCount:count dCount:dCount withColor:color];

    count=1;
    dCount=0;
    //rightUp & leftDown check
    while (i<=right && i<=up) {
        NSString *v=gb.cells[x-i][y+i];
        if ([v isEqualToString:color]) {//same color
            count++;
        }else if(![v isEqualToString:@"e"]){//diff color == dead end
            dCount++;
            break;
        }else{//live end
            break;
        }
        if (count>=5) {
            break;
        }
        i++;
    }
    i=1;
    while (i<=left && i<=down) {
        NSString *v=gb.cells[x+i][y-i];
        if ([v isEqualToString:color]) {
            count++;
        }else if(![v isEqualToString:@"e"]){
            dCount++;
            break;
        }else{
            break;
        }
        if (count>=5) {
            break;
        }
        i++;
    }
    i=1;
    if (count==3 && dCount==0) {
        alive3Count++;
    }else if(count==4 && dCount==1){
        dCount++;
    }
    if (alive4Flg==0) {
        if (alive3Count>=2) {
            result+=alive4;
        }else if(alive3Count>=1 && dead4Count>=1){
            result+=alive4;
        }
        alive4Flg=1;
    }
    result+=[AI getScoreBasedOnCount:count dCount:dCount withColor:color];
    
    return result;
}


+ (NSInteger)getScoreBasedOnCount:(int)count dCount:(int)dCount withColor:(NSString*)color{
    NSInteger score=0;
    if (dCount==2) {
        score=o1;
    }else if (count==5) {
        score=get5;
        if (![color isEqualToString:AIColor]) {
            score=get5/2+1;
        }
    }else if(count==4 && dCount==0){
        score=alive4;
        if (![color isEqualToString:AIColor]) {
            score=alive4/2+1;
        }
    }else if(count==3 && dCount==0){
        score=alive3;
        if (![color isEqualToString:AIColor]) {
            score=alive3/2+1;
        }
    }else if(count==4 && dCount==1){
        score=dead4;
    }else if(count==3 && dCount==1){
        score=dead3;
    }else if(count==2 && dCount==0){
        score=alive2;
    }else if(count==2 && dCount==1){
        score=dead2;
    }else{
        score=o1;
    }
    return score;
}



+(void)clearTmpArrays{
    for (int i=0; i<15; i++) {
        for (int j=0; j<15; j++) {
            ai[i][j]=0;
            player[i][j]=0;
        }
    }
}



@end
