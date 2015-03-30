//
//  MainMenuControllerViewController.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/12/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "MainMenuControllerViewController.h"
#import <UIKit/UIKit.h>
#import "GKHelper.h"
#import "GameScene.h"
#import "LoadingScene.h"
#import "PopupView.h"
#import "Constants.h"
#import "GameDataManager.h"
#import "LevelParser.h"
#import "SpritePreloader.h"
#import "AnimationComponent.h"
#import "PopupMessage.h"

@implementation MainMenuControllerViewController{
    BOOL gameLoaded;
    BOOL observersLoaded;
    PopupView* popupView;
    CGSize defaultPopupSize;
    NSMutableArray* popupQueue;
    BOOL messageBeingPresented;
    BOOL menuSetUp;
    Constants* constants;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!gameLoaded) {
        constants = [Constants sharedInstance];
        popupQueue = [NSMutableArray array];
      //  NSLog(@"gameLoaded = true");
        gameLoaded = true;
        _gameSceneView.ignoresSiblingOrder = YES;
        //_gameSceneView.showsFPS = YES;
        _menuView.hidden = true;
        [self setUpObservers];
        [self initGame];
    }
}

-(void)viewDidLayoutSubviews{
    NSString* fontName = constants.LOGO_LABEL_FONT_NAME;
    for (UIButton* button in _buttons) {
        UIFont *currentFont = button.titleLabel.font;
        button.titleLabel.font = [UIFont fontWithName:fontName size:currentFont.pointSize];
        //NSLog(@"button.titleLabel.font: %@", button.titleLabel.font);
    }
    for (UILabel* label in _labels) {
        label.font = [UIFont fontWithName:fontName size:label.font.pointSize];
        //NSLog(@"label.font.pointsize: %f", label.font.pointSize);
    }
    //_scoreTitleLabel.text = @"New highscore:";
    
}


-(void)setUpMenu{
    {
//        _menuView.layer.shadowColor = [UIColor grayColor].CGColor;
//        _menuView.layer.shadowRadius = 10.0f;
//        _menuView.layer.shadowOpacity = 1;
//        _menuView.layer.shadowOffset = CGSizeZero;
//        _menuView.layer.masksToBounds = NO;
        _menuView.layer.cornerRadius = 20;
        _menuView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        _menuView.layer.borderWidth = 10.0f;
    }
    
    _menuView.frame = CGRectMake(_menuView.frame.origin.x, _menuView.frame.origin.y - _menuView.frame.size.height, _menuView.frame.size.width, _menuView.frame.size.height);
    UIColor *rawColor = constants.LOGO_LABEL_FONT_COLOR;
    CGFloat r, g, b, a;
    [rawColor getRed: &r green:&g blue:&b alpha:&a];
    _menuView.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:.9];
}


-(void)setUpObservers{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserverForName:@"lose game"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
       // NSLog(@"lose game");
         NSUInteger score = ((NSNumber*)[[notification userInfo] valueForKey:@"distance"]).integerValue;
        [self showMenuWithScore:score];

     }];
    
    [center addObserverForName:@"pause"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         
       // NSLog(@"pause and go to menu");
         //NSUInteger score = ((NSNumber*)[[notification userInfo] valueForKey:@"distance"]).integerValue;
         [self showMenuWithScore:0];
     }];

    [center addObserverForName:@"add popup"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
       //  NSLog(@"add popup");
         NSString* text = [notification.userInfo objectForKey:@"popup text"];
         CGPoint position = ((NSValue*)[notification.userInfo objectForKey:@"popup position"]).CGPointValue;
         [self addPopupMessageWithText:text andPosition:position];
     }];
    
    [center addObserverForName:@"remove message"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
      //   NSLog(@"remove message");
         [self removeCurrentMessage];
     }];
}

-(void)addPopupMessageWithText:(NSString*)text andPosition:(CGPoint)position{
    PopupMessage *pm = [[PopupMessage alloc] initWithText:text andPosition:position];
    [popupQueue addObject:pm];
    if (!messageBeingPresented) {
        messageBeingPresented = true;
        [self presentMessage];
    }
}

-(void)presentMessage{
    PopupMessage *thisMessage = [popupQueue firstObject];
    //NSLog(@"popupQueue: %@", popupQueue);
    
    CGSize popupSize = [self choosePopupSizeForString:thisMessage.text];
    if (!popupView) {
        popupView = [[PopupView alloc] initWithFrame:CGRectMake(thisMessage.position.x - (popupSize.width / 2), thisMessage.position.y, popupSize.width, popupSize.height) andIsMenu:NO];
        [self.view addSubview:popupView];
    }
    [UIView animateWithDuration:0.5
         animations:^{
             popupView.frame = CGRectMake(popupView.frame.origin.x, popupView.frame.origin.y, popupView.desiredFrameSize.width, popupView.desiredFrameSize.height + 2);
         }
         completion:^(BOOL finished){
             
             popupView.frame = CGRectMake(popupView.frame.origin.x, popupView.frame.origin.y, popupView.desiredFrameSize.width, popupView.desiredFrameSize.height);
             popupView.textLabel.text = thisMessage.text;
             popupView.textLabel.numberOfLines = 3;
             popupView.textLabel.hidden = false;
             [[NSNotificationCenter defaultCenter] postNotificationName:@"allow dismiss popup" object:nil];
         }];
}

-(void)removeCurrentMessage{
    [UIView animateWithDuration:0.5
         animations:^{
             //[popupView.textLabel hi];
             popupView.textLabel.hidden = true;
             //[popupQueue removeObject:<#(id)#>]
             popupView.frame = CGRectMake(popupView.frame.origin.x, popupView.frame.origin.y, popupView.frame.size.width, 0);
         }
         completion:^(BOOL finished){
             [popupQueue removeObject:popupQueue.firstObject];
             if (popupQueue.count >= 1) {
                 [self presentMessage];
             }
             else{
                 [popupView removeFromSuperview];
                 popupView = nil;
                 messageBeingPresented = false;
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"unpause" object:nil];
             }
             
    }];
}

-(void)showMenuWithScore:(NSUInteger)score{
    _menuView.hidden = false;
    _scoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)score];
    GKHelper *gkhelper = [GKHelper sharedInstance];
    if (gkhelper.gcEnabled) {
        [gkhelper reportScore:score];
    }
        //NSLog(@"_menuView: %@", _menuView);
        [UIView animateWithDuration:0.5
                         animations:^{
                             _menuView.frame = CGRectMake(_menuView.frame.origin.x, _menuView.frame.origin.y + _menuView.frame.size.height + 10, _menuView.frame.size.width, _menuView.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.1
                                              animations:^{
                                                  _menuView.frame = CGRectMake(_menuView.frame.origin.x, _menuView.frame.origin.y - 10, _menuView.frame.size.width, _menuView.frame.size.height);
                                              }];
                         }
         ];
}

-(void)closeMenu{
    [UIView animateWithDuration:0.1
                     animations:^{
                         _menuView.frame = CGRectMake(_menuView.frame.origin.x, _menuView.frame.origin.y + 15, _menuView.frame.size.width, _menuView.frame.size.height);
                     }
                     completion:^(BOOL finished){

                        [UIView animateWithDuration:0.5
                             animations:^{
                                 _menuView.frame = CGRectMake(_menuView.frame.origin.x, _menuView.frame.origin.y - _menuView.frame.size.height, _menuView.frame.size.width, _menuView.frame.size.height);
                             }
                                  completion:^(BOOL finished){
                                    _menuView.hidden = true;
                                      [self removeCurrentMessage];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"restart" object:nil];
                                  }
                         ];
    }];

    
}

-(CGSize)choosePopupSizeForString:(NSString*)string{
    NSUInteger length = string.length;
    float width = constants.DEFAULT_POPUP_WIDTH_TO_CHAR_RATIO * length;
    float height = constants.DEFAULT_POPUP_HEIGHT_TO_CHAR_RATIO * length;
    if (width < constants.MIN_POPUP_SIZE.width) {
        width = constants.MIN_POPUP_SIZE.width;
    }
    if (width > constants.MAX_POPUP_SIZE.width) {
        width = constants.MAX_POPUP_SIZE.width;
    }
    if (height < constants.MIN_POPUP_SIZE.height) {
        height = constants.MIN_POPUP_SIZE.height;
    }
    if (height > constants.MAX_POPUP_SIZE.height) {
        height = constants.MAX_POPUP_SIZE.height;
    }
    //NSLog(@"popup width: %f", width);
    //NSLog(@"popup height: %f", height);

    return CGSizeMake(width, height);

}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}
- (IBAction)closeMenuPressed:(id)sender {
   // NSLog(@"closeMenuPressed");
    [self closeMenu];
}
- (IBAction)leaderboardsPressed:(id)sender {
   // NSLog(@"leaderboardsPressed");
    [[GKHelper sharedInstance] showGameCenter];

}
- (IBAction)sharePressed:(id)sender {
   // NSLog(@"facebookPressed");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/machweogame"]];
}
- (IBAction)ratePressed:(id)sender {
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=<YOURAPPID>&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id956041188"]];
}





-(void)initGame{
   __block LoadingScene* loadingScene;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        LevelParser* parser = [[LevelParser alloc] init];
        SpritePreloader* spritePreloader = [[SpritePreloader alloc] init];
        
        [AnimationComponent sharedInstance];
        [Constants sharedInstance].OBSTACLE_SETS = parser.obstacleSets;
        [Constants sharedInstance].BIOMES = parser.biomes;
        [Constants sharedInstance].OBSTACLE_POOL = spritePreloader.getObstaclePool;
        [Constants sharedInstance].SKY_DICT = spritePreloader.getSkyPool;
        GameScene *newScene = [[GameScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height) withinView:_gameSceneView];
//
        //dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
        dispatch_sync(dispatch_get_main_queue(), ^(void){
        //dispatch_after(time, dispatch_get_main_queue(), ^(void){
//            GameScene *newScene = [[GameScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height) withinView:_gameSceneView];
       //     NSLog(@"present gameplay scene");
            GKHelper* gkhelper = [GKHelper sharedInstance];
            [gkhelper authenticateLocalPlayer];
            gkhelper.presentingVC = self;
            [self setUpMenu];
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [loadingScene fadeOut];
                [_gameSceneView presentScene: newScene transition:[SKTransition fadeWithDuration:1]];
                loadingScene = nil;
            });
        });
    });
    
    loadingScene = [[LoadingScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
    [_gameSceneView presentScene:loadingScene];
        
   
}


- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
