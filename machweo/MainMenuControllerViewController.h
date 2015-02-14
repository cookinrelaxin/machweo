//
//  MainMenuControllerViewController.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/12/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextView.h"

@interface MainMenuControllerViewController : UIViewController
@property (strong, nonatomic) IBOutlet TextView *textView;


@property (nonatomic, strong) CALayer *animationLayer;
@property (nonatomic, strong) CAShapeLayer *pathLayer;
@property (nonatomic, strong) CAShapeLayer *pathSubLayer;
@property (nonatomic, strong) CALayer *sunLayer;
@property (nonatomic, strong) CALayer *logoLayer;


@end
