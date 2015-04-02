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
-(void)calculatePlayerVelocity:(Player*)player;
-(void)calculatePlayerPosition:(Player *)player withTerrainArray:(NSMutableArray*)terrainArray;
-(void)reset;
-(instancetype)initWithSceneSize:(CGSize)size;

@end
