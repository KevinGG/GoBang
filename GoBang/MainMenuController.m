//
//  MainMenuController.m
//  GoBang
//
//  Created by KangNing on 7/17/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "MainMenuController.h"
#import "ViewController.h"
#import "MyView.h"
#import "AI.h"
#import "GameKitHelper.h"
#import "UIImageView+Rotate.h"

@interface MainMenuController ()
@property (weak, nonatomic) IBOutlet UIButton *goPvpBtn;
@property (weak, nonatomic) IBOutlet UIButton *goPveBtn;
@property (weak, nonatomic) IBOutlet UIButton *goOlBtn;
@property (weak, nonatomic) IBOutlet UIImageView *goOlTitle;
@property (weak, nonatomic) IBOutlet UIImageView *goPvpTitle;
@property (weak, nonatomic) IBOutlet UIImageView *goPveTitle;

@end

extern NSString *const PresentAuthenticationViewController;

@implementation MainMenuController
ViewController *viewController;
CGFloat const SCALE = 1.0 / 4.5; // scale of UI elements to screen size

NSString *Gmode;
NSString *playerColor=@"b";
int AI1stFlg=1;

- (IBAction)goPvp:(id)sender {
    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"gameBoard"];
    Gmode = @"pvp";
    [self initGameViewItems];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)goPve:(id)sender {
    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"gameBoard"];
    Gmode = @"pve";
    [self initGameViewItems];
    [self alert];
}

- (IBAction)goOl:(id)sender {
    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"gameBoard"];
    Gmode = @"ol";
    [self initGameViewItems];
    [viewController initExternVariables];
    [(MyView*)viewController.view invisibleReGameBtn];
    [(MyView*)viewController.view invisibleWithdrawBtn];
    [self presentViewController:viewController animated:YES completion:nil];
}

//pvp who 1st? Player or AI
- (void)alert{
    NSString *message = @"Black goes first!";
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Pick Your Color"
                          message:message delegate:self cancelButtonTitle:@"Black (you go first!)" otherButtonTitles:@"White (AI goes first!)",nil];
    [alert show];
}

//pick color for player vs AI.
- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        playerColor = @"w";
        AI1stFlg=0;
        [AI setAIColor:@"b"];
        [self presentViewController:viewController animated:YES completion:nil];
    }else if (buttonIndex == 0){
        playerColor = @"b";
        AI1stFlg=1;
        [AI setAIColor:@"w"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    [self initMainMenuBtns];
}

- (void)initMainMenuBtns{
    CGFloat const WIDTH = screenWidth();
    CGFloat const HEIGHT = screenHeight();
    CGFloat const INNER_BTN_SCALE = 0.8;
    CGFloat const TITLE_R = WIDTH * SCALE / 2.0;
    CGFloat const INNER_BTN_R = TITLE_R * INNER_BTN_SCALE;
    CGFloat const FIRST_LINE = HEIGHT / 3.0 * 2.0;
    CGFloat const SECOND_LINE = HEIGHT / 3.0;
    
    [self.goOlTitle setFrame:CGRectMake(WIDTH / 2.0 - TITLE_R, FIRST_LINE - TITLE_R, TITLE_R * 2, TITLE_R * 2)];
    [self.goOlBtn setFrame:CGRectMake(WIDTH / 2.0 - INNER_BTN_R, FIRST_LINE - INNER_BTN_R, INNER_BTN_R * 2, INNER_BTN_R * 2)];
    [self.goOlTitle rotate360WithDuration:6.0 repeatCount:0];
    
    [self.goPvpTitle setFrame:CGRectMake(WIDTH / 3.0 - TITLE_R, SECOND_LINE - TITLE_R, TITLE_R * 2, TITLE_R * 2)];
    [self.goPvpBtn setFrame:CGRectMake(WIDTH / 3.0 - INNER_BTN_R, SECOND_LINE - INNER_BTN_R, INNER_BTN_R * 2, INNER_BTN_R * 2)];
    [self.goPvpTitle rotate360WithDuration:6.0 repeatCount:0];
    
    [self.goPveTitle setFrame:CGRectMake(WIDTH / 3.0 * 2.0 - TITLE_R, SECOND_LINE - TITLE_R, TITLE_R * 2, TITLE_R * 2)];
    [self.goPveBtn setFrame:CGRectMake(WIDTH / 3.0 * 2.0 - INNER_BTN_R, SECOND_LINE - INNER_BTN_R, INNER_BTN_R * 2, INNER_BTN_R * 2)];
    [self.goPveTitle rotate360WithDuration:6.0 repeatCount:0];
}

- (void)initGameViewItems{
    CGFloat const CELL_HEIGHT = screenHeight() / 9.0;
    CGFloat const CELL_WIDTH = screenWidth() * SCALE;
    CGFloat const MINOR_CELL_HEIGHT = CELL_HEIGHT / 3.0;
    CGFloat const HORIZON_MARGIN = screenHeight();
    
    CGFloat const HORIZON_BACKWARD_PADDING = CELL_WIDTH / 4.0;
    CGFloat const YOUR_TURN_LABEL_INDEX = 1.8;
    CGFloat const CURRENT_PLAYER_LABEL_INDEX = 2.0;
    CGFloat const TURN_LABEL_INDEX = 2.8;
    
    CGFloat const REDO_LAST_BTN_INDEX = 4.0;
    
    CGFloat const NEW_GAME_BTN_INDEX = 6.5;
    CGFloat const REMATCH_BTN_INDEX = 6.5;
    
    CGFloat const MAIN_MENU_LABEL_INDEX = 7.5;
    
    [(MyView*)viewController.view initYourTurnLabel:CGRectMake(HORIZON_MARGIN, CELL_HEIGHT * YOUR_TURN_LABEL_INDEX, CELL_WIDTH, MINOR_CELL_HEIGHT)];
    [(MyView*)viewController.view initCurrentPlayerLabel:CGRectMake(HORIZON_MARGIN, CELL_HEIGHT * CURRENT_PLAYER_LABEL_INDEX, CELL_WIDTH, CELL_HEIGHT)];
    [(MyView*)viewController.view initTurnLabel:CGRectMake(HORIZON_MARGIN + CELL_WIDTH - HORIZON_BACKWARD_PADDING, CELL_HEIGHT * TURN_LABEL_INDEX, CELL_WIDTH, MINOR_CELL_HEIGHT)];
    
    [(MyView*)viewController.view initRedoLastMoveLabel:CGRectMake(HORIZON_MARGIN, CELL_HEIGHT * REDO_LAST_BTN_INDEX, CELL_WIDTH, MINOR_CELL_HEIGHT)];
    
    [(MyView*)viewController.view initNewGameBtn:CGRectMake(HORIZON_MARGIN, CELL_HEIGHT * NEW_GAME_BTN_INDEX, CELL_WIDTH, MINOR_CELL_HEIGHT)];
    [(MyView*)viewController.view initRematchBtn:CGRectMake(HORIZON_MARGIN, CELL_HEIGHT * REMATCH_BTN_INDEX, CELL_WIDTH, MINOR_CELL_HEIGHT)];
    [(MyView*)viewController.view initMainMenuLabel:CGRectMake(HORIZON_MARGIN, CELL_HEIGHT * MAIN_MENU_LABEL_INDEX, CELL_WIDTH, MINOR_CELL_HEIGHT)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationViewController) name:PresentAuthenticationViewController object:nil];

    [[GameKitHelper sharedGameKitHelper]authenticateLocalPlayer];

    [UIImageView flipButton:self.goOlBtn duration:3.0 curve:UIViewAnimationCurveEaseInOut];
    [UIImageView flipButton:self.goPvpBtn duration:3.0 curve:UIViewAnimationCurveEaseInOut];
    [UIImageView flipButton:self.goPveBtn duration:3.0 curve:UIViewAnimationCurveEaseInOut];
}

-(void)showAuthenticationViewController{
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [self presentViewController:gameKitHelper.authenticationViewController animated:YES completion:nil];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
