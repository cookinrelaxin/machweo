//
//  WorldStreamer.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/25/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "WorldStreamer.h"
#import "ChunkLoader.h"

int SWITCH_BIOMES_DENOM = 10;

@implementation WorldStreamer{
    SKNode* _world;
    SKNode* _obstacles;
    SKNode* _decorations;
    NSMutableArray* _bucket;
    SKView* _view;
    NSMutableArray* _lines;
    NSMutableArray* _terrainPool;
    
    NSString* currentBiome;
    
    Constants* constants;
    
    
}

-(instancetype)initWithWorld:(SKNode *)world withObstacles:(SKNode *)obstacles andDecorations:(SKNode *)decorations andBucket:(NSMutableArray *)bucket withinView:(SKView *)view andLines:(NSMutableArray *)lines andTerrainPool:(NSMutableArray *)terrainPool withXOffset:(float)xOffset{
    if (self = [super init]) {
        _world = world;
        _obstacles = obstacles;
        _decorations = decorations;
        _bucket = bucket;
        _view = view;
        _lines = lines;
        _terrainPool = terrainPool;
        
        constants = [Constants sharedInstance];
        
        
    }
    
    return  self;
    
}


-(NSString*)calculateNextBiome{
    int chance = arc4random_uniform(10);
    if (chance == 0) {
        //for now just pick savanna
        return @"savanna";
    }
    else{
        return currentBiome;
    }
    
    return nil;
}

-(void)loadChunkWithXOffset:(float)xOffset andDistance:(NSUInteger)distance andTimeOfDay:(TimeOfDay)timeOfDay
    NSString* biome = [self calculateNextBiome];
    NSUInteger difficulty = [self calculateDifficultyFromDistance:distance];
    NSString* obstacleSet = [self calcuateObstacleSetForDifficulty:difficulty];
    NSString* decorationSet = [self calculateDecorationSetForDifficulty:<#(NSUInteger)#>]
    
    
    
    
    ChunkLoader *obstacleSetParser = [[ChunkLoader alloc] initWithFile:];
    [cl loadWorld:self withObstacles:_obstacles andDecorations:_decorations andBucket:previousChunks withinView:view andLines:arrayOfLines andTerrainPool:terrainPool withXOffset:0];
    
}

-(NSString*)calcuateObstacleSetForDifficulty:(NSUInteger)difficulty{
    NSMutableArray* difficultyArray = [constants.OBSTACLE_SETS valueForKey:[NSString stringWithFormat:@"%lu", (unsigned long)difficulty]];
    NSUInteger chance = arc4random_uniform((uint)difficultyArray.count);
    NSString* obstacleSet = [difficultyArray objectAtIndex:chance];
    return obstacleSet;
}

-(NSString*)calculateDecorationSetForTimeOfDay{
    NSMutableArray* difficultyArray = [constants.OBSTACLE_SETS valueForKey:[NSString stringWithFormat:@"%lu", (unsigned long)difficulty]];
    NSUInteger chance = arc4random_uniform((uint)difficultyArray.count);
    NSString* obstacleSet = [difficultyArray objectAtIndex:chance];
    return obstacleSet;
}

-(NSUInteger)calculateDifficultyFromDistance:(NSUInteger)distance{
 
    
    //for now just return 0
    return 0;
}


@end
