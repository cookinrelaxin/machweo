//
//  Line.h
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 12/1/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Terrain.h"

@interface Line : NSObject
@property (nonatomic) BOOL complete;
@property (nonatomic) BOOL belowPlayer;
@property (nonatomic) BOOL shouldDeallocNodeArray;
@property (nonatomic) BOOL shouldDraw;
@property (nonatomic) BOOL allowIntersections;
@property (nonatomic) NSMutableArray* terrainArray;
@property (nonatomic) NSMutableArray *nodeArray;

@property (nonatomic) CGPoint origin;
-(instancetype)initWithTerrainNode:(SKNode*)node :(CGSize)sceneSize;
-(void)generateConnectingLinesInTerrainNode:(SKNode*)node andDecoNode:(SKNode*)decorations :(BOOL)generateDecorations;
@end
