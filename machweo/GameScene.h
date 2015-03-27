//
//  GameScene.h
//  tgrrn
//

//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Constants.h"

@interface GameScene : SKScene
@property (nonatomic, strong) SKNode* world;
@property (nonatomic, strong) SKNode* obstacles;
@property (nonatomic, strong) SKNode* terrain;
@property (nonatomic, strong) SKNode* cairns;
@property (nonatomic, strong) SKNode* decorations;
@property (nonatomic, strong) SKNode* skies;

@property (nonatomic, strong) SKNode* hud;


@property (nonatomic, strong) Constants *constants;
@property (nonatomic) BOOL allowDismissPopup;
@property (nonatomic) BOOL stopScrolling;

-(instancetype)initWithSize:(CGSize)size withinView:(SKView*)view;
    @end
