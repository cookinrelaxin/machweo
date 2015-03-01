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

typedef enum MotionType
{
    motionTypeNone,
    motionTypeUpAndDown,
    motionTypeLeftAndRight,
    motionTypeRotatesClockwise,
    motionTypeRotatesCounterclockwise
} Motion;

typedef enum SpeedType
{
    speedTypeSlowest,
    speedTypeSlower,
    speedTypeSlow,
    speedTypeFast,
    speedTypeFaster,
    speedTypeFastest
} Speed;


@interface Obstacle : SKSpriteNode

@property (nonatomic) Motion currentMotionType;
@property (nonatomic) Speed currentSpeedType;
@property (nonatomic, strong) NSString* uniqueID;


+(instancetype)obstacleWithTextureAndPhysicsBody:(SKTexture *)texture;

-(NSString*)stringValueOfCurrentMotionType;
-(NSString*)stringValueOfCurrentSpeedType;
-(void)move;

@end
