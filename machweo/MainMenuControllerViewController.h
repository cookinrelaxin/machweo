//
//  MainMenuControllerViewController.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/12/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>
#import <iAd/iAd.h>

@interface MainMenuControllerViewController : UIViewController <GKGameCenterControllerDelegate, ADInterstitialAdDelegate>
@property (weak, nonatomic) IBOutlet SKView *gameSceneView;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (weak, nonatomic) IBOutlet UILabel *scoreTitleLabel;
@end
