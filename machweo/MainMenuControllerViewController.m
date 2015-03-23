//
//  MainMenuControllerViewController.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/12/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "MainMenuControllerViewController.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "GameScene.h"
#import "LoadingScene.h"
#import "PopupView.h"
#import "Constants.h"
#import "GameDataManager.h"
#import "LevelParser.h"
#import "SpritePreloader.h"
#import "AnimationComponent.h"

@interface MainMenuControllerViewController ()

@end

@implementation MainMenuControllerViewController{
    BOOL gameLoaded;
    BOOL observersLoaded;
    PopupView* currentPopup;
    CGSize defaultPopupSize;
    BOOL menuSetUp;
    Constants* constants;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!gameLoaded) {
        constants = [Constants sharedInstance];
        NSLog(@"gameLoaded = true");
        gameLoaded = true;
        _gameSceneView.ignoresSiblingOrder = YES;
        _gameSceneView.showsFPS = YES;
        _menuView.hidden = true;
        [self setUpObservers];
        [self initGame];
    }
}


-(void)setUpMenu{
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
        NSLog(@"lose game");
         NSUInteger score = ((NSNumber*)[[notification userInfo] valueForKey:@"distance"]).integerValue;
        [self showMenuWithScore:score];

     }];
    
    [center addObserverForName:@"pause"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         
        NSLog(@"pause and go to menu");
         //NSUInteger score = ((NSNumber*)[[notification userInfo] valueForKey:@"distance"]).integerValue;
         [self showMenuWithScore:0];
     }];

    [center addObserverForName:@"add popup"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         NSLog(@"add popup");
         NSString* text = [notification.userInfo objectForKey:@"popup text"];
         CGPoint position = ((NSValue*)[notification.userInfo objectForKey:@"popup position"]).CGPointValue;
         [self addPopupWithText:text andPosition:position];
     }];
    
    [center addObserverForName:@"remove popup"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         NSLog(@"remove popup");
         [self removeCurrentPopup];
     }];
    

}

-(void)addPopupWithText:(NSString*)text andPosition:(CGPoint)position{
    CGSize popupSize = [self choosePopupSizeForString:text];
    currentPopup = [[PopupView alloc] initWithFrame:CGRectMake(position.x - (popupSize.width / 2), position.y, popupSize.width, popupSize.height) andIsMenu:NO];
    [UIView animateWithDuration:0.5
         animations:^{
             currentPopup.frame = CGRectMake(currentPopup.frame.origin.x, currentPopup.frame.origin.y, currentPopup.desiredFrameSize.width, currentPopup.desiredFrameSize.height + 2);
         }
         completion:^(BOOL finished){
             
             currentPopup.frame = CGRectMake(currentPopup.frame.origin.x, currentPopup.frame.origin.y, currentPopup.desiredFrameSize.width, currentPopup.desiredFrameSize.height);
             currentPopup.textLabel.text = text;
             currentPopup.textLabel.numberOfLines = 3;
             currentPopup.textLabel.hidden = false;
             [[NSNotificationCenter defaultCenter] postNotificationName:@"allow dismiss popup" object:nil];
         }];
    [self.view addSubview:currentPopup];
}

-(void)removeCurrentPopup{
    [UIView animateWithDuration:0.5
         animations:^{
             [currentPopup.textLabel removeFromSuperview];
             currentPopup.frame = CGRectMake(currentPopup.frame.origin.x, currentPopup.frame.origin.y, currentPopup.frame.size.width, 0);
         }
         completion:^(BOOL finished){
             [currentPopup removeFromSuperview];
             
    }];
}

-(void)showMenuWithScore:(NSUInteger)score{
        _menuView.hidden = false;
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
    //[menu removeFromSuperview];
    [UIView animateWithDuration:0.5
         animations:^{
             _menuView.frame = CGRectMake(_menuView.frame.origin.x, _menuView.frame.origin.y - _menuView.frame.size.height, _menuView.frame.size.width, _menuView.frame.size.height);
         }
              completion:^(BOOL finished){
                _menuView.hidden = true;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"unpause" object:nil];
              }
     ];
    
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
    NSLog(@"closeMenuPressed");
    [self closeMenu];
}
- (IBAction)leaderboardsPressed:(id)sender {
    NSLog(@"leaderboardsPressed");

}
- (IBAction)sharePressed:(id)sender {
    NSLog(@"sharePressed");

}

-(void)initGame{
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
        dispatch_sync(dispatch_get_main_queue(), ^(void){
//            GameScene *newScene = [[GameScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height) withinView:_gameSceneView];
            NSLog(@"present gameplay scene");
            [self setUpMenu];
            [_gameSceneView presentScene: newScene transition:[SKTransition fadeWithDuration:1]];
        });
    });
    
    LoadingScene* loadingScene = [[LoadingScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
    [_gameSceneView presentScene:loadingScene];
        
   
}

@end
