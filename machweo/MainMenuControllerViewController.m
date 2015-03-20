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
#import "PopupView.h"

@interface MainMenuControllerViewController ()

@end

@implementation MainMenuControllerViewController{
    BOOL gameLoaded;
    BOOL observersLoaded;
    PopupView* currentPopup;
    CGSize defaultPopupSize;
}


- (void) lightUp{
    _effectsView.layer.backgroundColor = [[UIColor clearColor] CGColor];
    CABasicAnimation *lightUp = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    lightUp.fromValue = (id)[[UIColor blackColor] CGColor];
    lightUp.toValue = (id)[[UIColor clearColor] CGColor];
    lightUp.duration = 3.0f;
    [_effectsView.layer addAnimation:lightUp forKey:@"backgroundColor"];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!gameLoaded) {
        NSLog(@"gameLoaded = true");
        gameLoaded = true;
        _gameSceneView.frame = self.view.bounds;
        [self.view sendSubviewToBack:_gameSceneView];
        _gameSceneView.ignoresSiblingOrder = YES;
        _gameSceneView.showsFPS = YES;
        _effectsView.layer.opacity = 1;
        [self setUpObservers];
        [self initGame];
        [self lightUp];


    }
    
}


-(void)setUpObservers{
    //__weak MainMenuControllerViewController *weakSelf = self;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserverForName:@"end game"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         
         [CATransaction begin]; {
         [CATransaction setCompletionBlock:^{
             [self initGame];
             [self lightUp];

         }];
             _effectsView.layer.opacity = 1;
             _effectsView.layer.backgroundColor = [[UIColor blackColor] CGColor];
             CABasicAnimation *darken = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
             darken.fromValue = (id)[[UIColor clearColor] CGColor];
             darken.toValue = (id)[[UIColor blackColor] CGColor];
             darken.duration = 1.0f;
             [_effectsView.layer addAnimation:darken forKey:@"backgroundColor"];
             
             
         } [CATransaction commit];
     }];
    
    [center addObserverForName:@"add popup"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         NSString* text = [notification.userInfo objectForKey:@"popup text"];
         CGPoint position = ((NSValue*)[notification.userInfo objectForKey:@"popup position"]).CGPointValue;
         //BOOL shouldAutomaticallyDismiss = ((NSNumber*)[notification.userInfo objectForKey:@"automatically dismiss"]).boolValue;
         
         //text.length
         
         //float popupViewWidth = 200;
         //float popupViewHeight = 100;
         CGSize popupSize = [self choosePopupSizeForString:text];
         
         currentPopup = [[PopupView alloc] initWithFrame:CGRectMake(position.x - (popupSize.width / 2), position.y, popupSize.width, popupSize.height)];
         [UIView animateWithDuration:0.5
              animations:^{
                  //CGRect frame = v.frame;
                  
                  //frame.size.height += 90.0;
                  //frame.size.width += 30.0;
                  //v.frame = frame;
                  currentPopup.frame = CGRectMake(currentPopup.frame.origin.x, currentPopup.frame.origin.y, currentPopup.desiredFrameSize.width, currentPopup.desiredFrameSize.height + 2);
              }
              completion:^(BOOL finished){
                  
                  currentPopup.frame = CGRectMake(currentPopup.frame.origin.x, currentPopup.frame.origin.y, currentPopup.desiredFrameSize.width, currentPopup.desiredFrameSize.height);
                  currentPopup.textLabel.text = text;
                  currentPopup.textLabel.numberOfLines = 3;
                  //v.textLabel.font =
                  currentPopup.textLabel.hidden = false;
                  //if (shouldAutomaticallyDismiss) {
                      //dispatch_after(2 * NSEC_PER_SEC, dispatch_get_main_queue(), ^{
                          //[[NSNotificationCenter defaultCenter] postNotificationName:@"remove popup" object:nil];
                      //});
                      //return ;
                //}
                [[NSNotificationCenter defaultCenter] postNotificationName:@"allow dismiss popup" object:nil];
            }];
         
         
         [self.view addSubview:currentPopup];
     }];
    
    [center addObserverForName:@"remove popup"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         [UIView animateWithDuration:0.5
              animations:^{
                  [currentPopup.textLabel removeFromSuperview];
                  currentPopup.frame = CGRectMake(currentPopup.frame.origin.x, currentPopup.frame.origin.y, currentPopup.frame.size.width, 0);
              }
              completion:^(BOOL finished){
                  [currentPopup removeFromSuperview];
                 
         }];

     }];
    

}

-(CGSize)choosePopupSizeForString:(NSString*)string{
    Constants* constants = [Constants sharedInstance];
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

-(void)initGame{
    GameScene *newScene = [[GameScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height) withinView:_gameSceneView];
    NSLog(@"presentScene");
    [_gameSceneView presentScene: newScene];
}

@end
