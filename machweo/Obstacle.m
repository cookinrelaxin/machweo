//
//  Obstacle.m
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 11/8/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "Obstacle.h"

@implementation Obstacle

+(instancetype)obstacleWithTextureAndPhysicsBody:(SKTexture *)texture{
    Obstacle* obstacle = [Obstacle spriteNodeWithTexture:texture];
    return obstacle;
}

@end
