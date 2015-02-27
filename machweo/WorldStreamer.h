//
//  WorldStreamer.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/25/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "Constants.h"

@interface WorldStreamer : NSObject

-(instancetype)initWithWorld:(SKScene*)world withObstacles:(SKNode*)obstacles andDecorations:(SKNode*)decorations andBucket:(NSMutableArray*)bucket withinView:(SKView *)view andLines:(NSMutableArray*)lines andTerrainPool:(NSMutableArray*)terrainPool withXOffset:(float)xOffset;

//-(NSString*)calculateNextBiome;
//-(void)loadChunkWithXOffset:(float)xOffset andDistance:(NSUInteger)distance andTimeOfDay:(TimeOfDay)timeOfDay;

//-(void)checkForLastObstacleWithDistance:(NSUInteger)distance andTimeOfDay:(TimeOfDay)timeOfDay;
-(void)decideToLoadChunksWithPlayerDistance:(NSUInteger)playerDistance andTimeOfDay:(TimeOfDay)timeOfDay;





@end
