//
//  ButsuLiKi.h
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 10/23/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "Player.h"

@interface ButsuLiKi : NSObject
//@property (nonatomic, strong) Constants *constants;

//-(void)resolveCollisions:(Player*)player withPointArray:(NSMutableArray*)pointArray :(Constants*)constants;
-(void)calculatePlayerVelocity:(Player*)player;

-(void)calculatePlayerPosition:(Player *)player withLineArray:(NSMutableArray*)pointArrayArray;
//-(BOOL)resolveCollisionsAgainstObstacles:(Player*)player withObstacleArray:(NSArray*)obstacleArray;

@end
