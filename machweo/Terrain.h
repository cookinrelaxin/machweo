//
//  TerrainSignifier.h
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 1/27/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Terrain : SKNode
@property(nonatomic, strong) NSMutableArray* lineVertices;

@property(nonatomic, strong) SKTexture* terrainTexture;
@property(nonatomic, strong) SKCropNode* cropNode;
@property(nonatomic) BOOL isClosed;
@property(nonatomic) BOOL permitDecorations;

-(instancetype)initWithTexture:(SKTexture*)terrainTexture;
-(void)closeLoopAndFillTerrainInView:(SKView*)view;
-(void)generateDecorationAtVertex:(CGPoint)v fromTerrainPool:(NSMutableArray*)terrainPool inNode:(SKNode*)node;
-(void)changeDecorationPermissions:(CGPoint)currentPoint;

@end
