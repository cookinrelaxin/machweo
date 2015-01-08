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
   // CGVector scaleCoefficient = [Constants sharedInstance].SCALE_COEFFICIENT;
    //texture.size = CGSizeMake(0, 0);
    //texture.size = CGSizeMake(texture.size.width * scaleCoefficient.dy, texture.size.height * scaleCoefficient.dy);
    Obstacle* obstacle = [Obstacle spriteNodeWithTexture:texture];
//    obstacle.physicsBody = [SKPhysicsBody bodyWithTexture:texture size:texture.size];
//    obstacle.physicsBody.categoryBitMask = [Constants sharedInstance].OBSTACLE_HIT_CATEGORY;
//    obstacle.physicsBody.contactTestBitMask = [Constants sharedInstance].PLAYER_HIT_CATEGORY;
//    //obstacle.physicsBody.collisionBitMask = 3;
//    
//   // NSLog(@"obstacle.physicsBody.categoryBitMask: %d", obstacle.physicsBody.categoryBitMask);
//   // NSLog(@"obstacle.physicsBody.contactTestBitMask: %d", obstacle.physicsBody.contactTestBitMask);
//    
//    obstacle.physicsBody.dynamic = false;
    
    return obstacle;
}

@end
