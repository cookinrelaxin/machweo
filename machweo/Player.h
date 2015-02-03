//
//  Player.h
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 10/23/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "Constants.h"

@interface Player : SKSpriteNode

@property (nonatomic) CGVector velocity;

@property (nonatomic) float yCoordinateOfBottomSide;
@property (nonatomic) float yCoordinateOfTopSide;
@property (nonatomic) float xCoordinateOfLeftSide;
@property (nonatomic) float xCoordinateOfRightSide;
@property (nonatomic) float currentSlope;
//@property (nonatomic) bool roughlyOnLine;
@property (nonatomic) bool touchesEnded;
//@property (nonatomic) float minYPosition;
//@property (nonatomic) BOOL endOfLine;
@property (nonatomic) float currentRotationSpeed;

+(instancetype)playerAtPoint:(CGPoint)point;
//-(void)initAtPoint:(CGPoint)point;
-(void)updateEdges;
//-(void)resetMinsAndMaxs;
@end



