//
//  Obstacle.h
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 11/8/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "Constants.h"

@interface Obstacle : SKSpriteNode

+(instancetype)obstacleWithTextureAndPhysicsBody:(SKTexture *)texture;

@end
