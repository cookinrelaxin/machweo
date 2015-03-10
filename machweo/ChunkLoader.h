//
//  ChunkLoader.h
//  tgrrn
//
//  Created by John Feldcamp on 12/26/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface ChunkLoader : NSObject <NSXMLParserDelegate>

//-(void)loadWorld:(SKNode*)world withObstacles:(SKNode*)obstacles andDecorations:(SKNode*)decorations andBucket:(NSMutableArray*)bucket withinView:(SKView*)view andLines:(NSMutableArray*)lines andTerrainPool:(NSMutableArray*)terrainPool withXOffset:(float)xOffset;
//-(void)loadObstaclesInWorld:(SKNode*)world withObstacles:(SKNode*)obstacles andBucket:(NSMutableArray*)bucket withinView:(SKView*)view andTerrainPool:(NSMutableArray*)terrainPool withXOffset:(float)xOffset;
//-(void)loadDecorationsInWorld:(SKNode*)world withDecorations:(SKNode*)decorations andBucket:(NSMutableArray*)bucket withinView:(SKView*)view andTerrainPool:(NSMutableArray*)terrainPool withXOffset:(float)xOffset;

-(void)pourObstaclesIntoBucket:(NSMutableArray*)bucket;
-(void)pourDecorationsIntoBucket:(NSMutableArray*)bucket andTerrainPool:(NSMutableArray*)terrainPool;

-(instancetype)initWithFile:(NSString*)fileName;
@end
