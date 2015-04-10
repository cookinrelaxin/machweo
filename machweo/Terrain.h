//
//  TerrainSignifier.h
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 1/27/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "Constants.h"

@interface Terrain : SKNode
@property(nonatomic, strong) NSMutableArray* vertices;
@property(nonatomic) BOOL isClosed;
@property(nonatomic) BOOL permitDecorations;
@property(nonatomic) NSMutableArray* decos;
@property (nonatomic) BOOL complete;
@property (nonatomic) BOOL belowPlayer;
@property (nonatomic) BOOL shouldDeallocNodeArray;
@property (nonatomic) BOOL allowIntersections;
@property (nonatomic) CGPoint lastVertex;
-(instancetype)initWithSceneSize:(CGSize)size;
-(void)closeLoopAndFillTerrainInView:(SKView*)view withCurrentSunYPosition:(float)sunY minY:(float)minY andMaxY:(float)maxY;
-(void)generateDecorationAtVertex:(CGPoint)v inNode:(SKNode*)node andSlope:(float)slope andCurrentBiome:(Biome)biome;
-(void)changeDecorationPermissions:(CGPoint)currentPoint;
-(void)correctSpriteZsBeforeVertex:(CGPoint)vertex againstSlope:(BOOL)againstSlope;
-(void)fadeOutAndDelete;
@end
