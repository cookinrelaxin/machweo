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
    
    Biome currentBiome;
    
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


-(Biome)calculateNextBiome{
    int chance = arc4random_uniform(10);
    if (chance == 0) {
        //for now just pick savanna
        //return @"savanna";
        return savanna;
    }
    //else{
    return currentBiome;
    //}
    
    //return nil;
}

-(void)loadChunkWithXOffset:(float)xOffset andDistance:(NSUInteger)distance andTimeOfDay:(TimeOfDay)timeOfDay{
    Biome biome = [self calculateNextBiome];
    NSUInteger difficulty = [self calculateDifficultyFromDistance:distance];
    NSString* obstacleSet = [self calcuateObstacleSetForDifficulty:difficulty];
    NSString* decorationSet = [self calculateDecorationSetForTimeOfDay:timeOfDay andBiome:biome];
    
    ChunkLoader *obstacleSetParser = [[ChunkLoader alloc] initWithFile:obstacleSet];
    [obstacleSetParser loadWorld:_world withObstacles:_obstacles andDecorations:_decorations andBucket:_bucket withinView:_view andLines:_lines andTerrainPool:_terrainPool withXOffset:0];
    
    ChunkLoader *decorationSetParser = [[ChunkLoader alloc] initWithFile:decorationSet];
    [decorationSetParser loadWorld:_world withObstacles:_obstacles andDecorations:_decorations andBucket:_bucket withinView:_view andLines:_lines andTerrainPool:_terrainPool withXOffset:0];
    
}

-(NSString*)calcuateObstacleSetForDifficulty:(NSUInteger)difficulty{
    NSMutableArray* difficultyArray = [constants.OBSTACLE_SETS valueForKey:[NSString stringWithFormat:@"%lu", (unsigned long)difficulty]];
    NSUInteger chance = arc4random_uniform((uint)difficultyArray.count);
    NSString* obstacleSet = [difficultyArray objectAtIndex:chance];
    return obstacleSet;
}

-(NSString*)calculateDecorationSetForTimeOfDay:(TimeOfDay)timeOfDay andBiome:(Biome)biome{
    NSMutableDictionary* biomeDict = [constants.BIOMES valueForKey:[self biomeToString:biome]];
    NSMutableArray* timeOfDayArray = [biomeDict valueForKey:[self timeOfDayToString:timeOfDay]];
    NSUInteger chance = arc4random_uniform((uint)timeOfDayArray.count);
    NSString* decorationSet = [timeOfDayArray objectAtIndex:chance];
    return decorationSet;
}

-(NSString*)biomeToString:(Biome)biome{
    switch (biome) {
        case savanna:
            return @"savanna";
        case sahara:
            return @"sahara";
    }
    NSLog(@"unknown biome. cannot convert to string");
    return nil;
}

-(NSString*)timeOfDayToString:(TimeOfDay)timeOfDay{
    switch (timeOfDay) {
        case AM_12:
            return @"AM_12";
        case AM_1:
            return @"AM_1";
        case AM_2:
            return @"AM_2";
        case AM_3:
            return @"AM_3";
        case AM_4:
            return @"AM_4";
        case AM_5:
            return @"AM_5";
        case AM_6:
            return @"AM_6";
        case AM_7:
            return @"AM_7";
        case AM_8:
            return @"AM_8";
        case AM_9:
            return @"AM_9";
        case AM_10:
            return @"AM_10";
        case AM_11:
            return @"AM_11";
        case PM_12:
            return @"AM_12";
        case PM_1:
            return @"PM_1";
        case PM_2:
            return @"PM_2";
        case PM_3:
            return @"PM_3";
        case PM_4:
            return @"PM_4";
        case PM_5:
            return @"PM_5";
        case PM_6:
            return @"PM_6";
        case PM_7:
            return @"PM_7";
        case PM_8:
            return @"PM_8";
        case PM_9:
            return @"PM_9";
        case PM_10:
            return @"PM_10";
        case PM_11:
            return @"PM_11";
            
    }
    NSLog(@"unknown time of day. cannot convert to string");
    return nil;
}



-(NSUInteger)calculateDifficultyFromDistance:(NSUInteger)distance{
 
    
    //for now just return 0
    return 0;
}
                                      
                                      
                                      
                                      
                                      
                                    

@end
