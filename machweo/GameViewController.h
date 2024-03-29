//
//  GameViewController.h
//  tgrrn
//

//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "ChapterCell.h"

@interface GameViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *restartButton;

@property (strong, nonatomic) NSString* levelToLoad;
@property (strong, nonatomic) ChapterCell* currentChapter;

@end
