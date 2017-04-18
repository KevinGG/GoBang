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

NSString *Gmode;
NSString *playerColor=@"b";
int AI1stFlg=1;

- (IBAction)goPvp:(id)sender {
    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"gameBoard"];
    Gmode = @"pvp";
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)goPve:(id)sender {
    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"gameBoard"];
    Gmode = @"pve";
    [self alert];
}

- (IBAction)goOl:(id)sender {
    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"gameBoard"];
    Gmode = @"ol";
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
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    //[self initMainMenuBtns];
}

- (void)initMainMenuBtns{
    [self.goOlTitle rotate360WithDuration:6.0 repeatCount:0];
    [UIImageView flipButton:self.goOlBtn duration:3.0 curve:UIViewAnimationCurveEaseInOut];
    [self.goPvpTitle rotate360WithDuration:6.0 repeatCount:0];
    [UIImageView flipButton:self.goPvpBtn duration:3.0 curve:UIViewAnimationCurveEaseInOut];
    [self.goPveTitle rotate360WithDuration:6.0 repeatCount:0];
    [UIImageView flipButton:self.goPveBtn duration:3.0 curve:UIViewAnimationCurveEaseInOut];
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
    [self initMainMenuBtns];
}

-(void)showAuthenticationViewController{
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [self presentViewController:gameKitHelper.authenticationViewController animated:YES completion:nil];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
