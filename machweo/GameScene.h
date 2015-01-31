//
//  GameScene.h
//  tgrrn
//

//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Constants.h"

@interface GameScene : SKScene
//@property (nonatomic, strong) SKNode* lines;
@property (nonatomic, strong) SKNode* obstacles;
@property (nonatomic, strong) SKNode* terrain;
@property (nonatomic, strong) SKNode* decorations;
@property (nonatomic, strong) Constants *constants;
@property (nonatomic) BOOL shangoBrokeHisBack;

-(instancetype)initWithSize:(CGSize)size forLevel:(NSString *)levelName withinView:(SKView*)view;
    @end
