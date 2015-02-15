//
//  MainMenuControllerViewController.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/12/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface MainMenuControllerViewController : UIViewController
@property (weak, nonatomic) IBOutlet SKView *gameSceneView;
@property (weak, nonatomic) IBOutlet UIView *logoView;

@property (nonatomic, strong) CALayer *logoAnimationLayer;
@property (nonatomic, strong) CAShapeLayer *pathLayer;
@property (nonatomic, strong) CAShapeLayer *pathSubLayer;

@end
