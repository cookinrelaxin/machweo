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

//@property(nonatomic, strong) SKColor* color;
@property(nonatomic, strong) SKShapeNode* textureShapeNode;
@property(nonatomic) BOOL isClosed;
@property(nonatomic) BOOL permitDecorations;
@property(nonatomic) NSMutableArray* decos;


-(instancetype)initWithImage:(UIImage*)image forSceneSize:(CGSize)size;
-(void)closeLoopAndFillTerrainInView:(SKView*)view withCurrentSunYPosition:(float)sunY minY:(float)minY andMaxY:(float)maxY;
-(void)generateDecorationAtVertex:(CGPoint)v inNode:(SKNode*)node withZposition:(float)zPos andSlope:(float)slope andCurrentBiome:(Biome)biome;
-(void)changeDecorationPermissions:(CGPoint)currentPoint;
-(void)correctSpriteZsBeforeVertex:(CGPoint)vertex againstSlope:(BOOL)againstSlope;
//-(void)removeLastSprite;
@end
