//
//  WorldStreamer.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/25/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "WorldStreamer.h"
#import "ChunkLoader.h"
#import "Obstacle.h"

int SWITCH_BIOMES_DENOM = 10;

@implementation WorldStreamer{
    SKScene* _world;
    SKNode* _obstacles;
    SKNode* _decorations;
    NSMutableArray* _bucket;
    SKView* _view;
    NSMutableArray* _lines;
    NSMutableArray* _terrainPool;
    
    Biome currentBiome;
    
    Constants* constants;
    
    BOOL chunkLoading;
    
    
}

-(instancetype)initWithWorld:(SKScene *)world withObstacles:(SKNode *)obstacles andDecorations:(SKNode *)decorations andBucket:(NSMutableArray *)bucket withinView:(SKView *)view andLines:(NSMutableArray *)lines andTerrainPool:(NSMutableArray *)terrainPool withXOffset:(float)xOffset{
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

-(void)loadObstacleChunkWithXOffset:(float)xOffset andDistance:(NSUInteger)distance{
    chunkLoading = true;
    NSUInteger difficulty = [self calculateDifficultyFromDistance:distance];
    //NSLog(@"difficulty: %lu", (unsigned long)difficulty);
    NSString* obstacleSet = [self calcuateObstacleSetForDifficulty:difficulty];
    //NSLog(@"obstacleSet: %@", obstacleSet);

    
    NSLog(@"xOffset: %f", xOffset);
    ChunkLoader *obstacleSetParser = [[ChunkLoader alloc] initWithFile:obstacleSet];
    //[obstacleSetParser loadWorld:_world withObstacles:_obstacles andDecorations:_decorations andBucket:_bucket withinView:_view andLines:_lines andTerrainPool:_terrainPool withXOffset:xOffset];
    [obstacleSetParser loadObstaclesInWorld:_world withObstacles:_obstacles andBucket:_bucket withinView:_view andTerrainPool:_terrainPool withXOffset:xOffset];
    
    chunkLoading = false;
    
}

-(void)loadDecorationChunkWithXOffset:(float)xOffset andTimeOfDay:(TimeOfDay)timeOfDay{
    chunkLoading = true;
    Biome biome = [self calculateNextBiome];
    //NSLog(@"biome: %@", [self biomeToString:biome]);
    //NSLog(@"timeOfDay: %@", [self timeOfDayToString:timeOfDay]);
    NSString* decorationSet = [self calculateDecorationSetForTimeOfDay:timeOfDay andBiome:biome];
    //NSLog(@"decorationSet: %@", decorationSet);
    
    ChunkLoader *decorationSetParser = [[ChunkLoader alloc] initWithFile:decorationSet];
    [decorationSetParser loadDecorationsInWorld:_world withDecorations:_decorations andBucket:_bucket withinView:_view andTerrainPool:_terrainPool withXOffset:xOffset];
    
    chunkLoading = false;
    
}

-(NSString*)calcuateObstacleSetForDifficulty:(NSUInteger)difficulty{
    NSMutableArray* difficultyArray = [constants.OBSTACLE_SETS valueForKey:[NSString stringWithFormat:@"%lu", (unsigned long)difficulty]];
    NSUInteger chance = arc4random_uniform((uint)difficultyArray.count);
    NSString* obstacleSet = [difficultyArray objectAtIndex:chance];
    return obstacleSet;
}

-(NSString*)calculateDecorationSetForTimeOfDay:(TimeOfDay)timeOfDay andBiome:(Biome)biome{
    NSMutableDictionary* biomeDict = [constants.BIOMES valueForKey:[self biomeToString:biome]];
    //NSLog(@"biomeDict: %@", biomeDict);
    NSMutableArray* timeOfDayArray = [biomeDict valueForKey:[self timeOfDayToString:timeOfDay :NO]];
    //NSLog(@"timeOfDayArray: %@", timeOfDayArray);
    NSUInteger chance = arc4random_uniform((uint)timeOfDayArray.count);
    NSString* decorationSet = [timeOfDayArray objectAtIndex:chance];
    //NSLog(@"decorationSet: %@", decorationSet);

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

-(NSUInteger)calculateDifficultyFromDistance:(NSUInteger)distance{
 
    
    //for now just return 0
    return 1;
}

-(void)checkForLastObstacleWithDistance:(NSUInteger)distance{
    if (!chunkLoading) {

        Obstacle* lastObstacle = [_obstacles.children lastObject];
        if (!lastObstacle) {
            [self loadObstacleChunkWithXOffset:0 andDistance:0];
            
            return;
        }
        CGPoint lastObstaclePosInSelf = [_world convertPoint:lastObstacle.position fromNode:_obstacles];

        CGPoint lastObstaclePosInView = [_view convertPoint:lastObstaclePosInSelf fromScene:_world];
          if (lastObstaclePosInView.x < _view.bounds.size.width) {
                NSLog(@"load next chunk");
                    NSMutableArray* trash = [NSMutableArray array];
                    for (SKSpriteNode* sprite in _bucket) {
                        if (![sprite isKindOfClass:[Obstacle class]]) {
                            continue;
                        }
                        CGPoint posInSelf = [_world convertPoint:CGPointMake(sprite.position.x + (sprite.size.width / 2), sprite.position.y) fromNode:sprite.parent];
                        if (posInSelf.x > 0) {
                            continue;
                        }

                        [sprite removeFromParent];
                        [trash addObject:sprite];
                    }
                    for (SKSpriteNode* sprite in trash) {
                        [_bucket removeObject:sprite];
                    }
                    trash = nil;
//                }
//                chunkLoading = true;
//                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
//                    ChunkLoader *cl = [[ChunkLoader alloc] initWithFile:nextChunk];
//                    dispatch_sync(dispatch_get_main_queue(), ^{
//                        [cl loadWorld:self withObstacles:_obstacles andDecorations:_decorations andBucket:previousChunks withinView:self.view andLines:arrayOfLines andTerrainPool:terrainPool withXOffset:lastObstaclePosInSelf.x];
//                        chunkLoading = false;
//                    });
//                });
              
              [self loadObstacleChunkWithXOffset:lastObstaclePosInSelf.x andDistance:distance];


                //[self winGame];
            }
        else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopScrolling" object:nil];

//                stopScrolling = true;
        }

    }
}

-(void)checkForLastDecorationWithTimeOfDay:(TimeOfDay)timeOfDay{
    if (!chunkLoading) {
        
        SKSpriteNode* lastDeco = [_decorations.children lastObject];
        if (!lastDeco) {
            [self loadDecorationChunkWithXOffset:0 andTimeOfDay:timeOfDay];
            return;
        }
        CGPoint lastDecoPosInSelf = [_world convertPoint:lastDeco.position fromNode:_decorations];
        
        CGPoint lastDecoPosInView = [_view convertPoint:lastDecoPosInSelf fromScene:_world];
        if (lastDecoPosInView.x < _view.bounds.size.width) {
            NSLog(@"load next chunk");
            NSMutableArray* trash = [NSMutableArray array];
            for (SKSpriteNode* sprite in _bucket) {
                if (![sprite isKindOfClass:[Obstacle class]]) {
                    continue;
                }
                CGPoint posInSelf = [_world convertPoint:CGPointMake(sprite.position.x + (sprite.size.width / 2), sprite.position.y) fromNode:sprite.parent];
                if (posInSelf.x > 0) {
                    continue;
                }
                
                [sprite removeFromParent];
                [trash addObject:sprite];
            }
            for (SKSpriteNode* sprite in trash) {
                [_bucket removeObject:sprite];
            }
            trash = nil;
            //                }
            //                chunkLoading = true;
            //                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            //                    ChunkLoader *cl = [[ChunkLoader alloc] initWithFile:nextChunk];
            //                    dispatch_sync(dispatch_get_main_queue(), ^{
            //                        [cl loadWorld:self withObstacles:_obstacles andDecorations:_decorations andBucket:previousChunks withinView:self.view andLines:arrayOfLines andTerrainPool:terrainPool withXOffset:lastObstaclePosInSelf.x];
            //                        chunkLoading = false;
            //                    });
            //                });
            
            [self loadDecorationChunkWithXOffset:lastDecoPosInSelf.x andTimeOfDay:timeOfDay];
            
            
            //[self winGame];
        }
//        else{
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopScrolling" object:nil];
//            
//            //                stopScrolling = true;
//        }
        
    }
}

-(void)decideToLoadChunksWithPlayerDistance:(NSUInteger)playerDistance andTimeOfDay:(TimeOfDay)timeOfDay{
    [self checkForLastObstacleWithDistance:playerDistance];
    [self checkForLastDecorationWithTimeOfDay:timeOfDay];
}


-(NSString*)timeOfDayToString:(TimeOfDay)timeOfDay :(BOOL)exact{
    switch (timeOfDay) {
        case AM_12:{
            if (exact) {
                return @"AM_12";
            }
            return @"night";
        }
        case AM_1:{
            if (exact) {
                return @"AM_1";
            }
            return @"night";
        }
        case AM_2:{
            if (exact) {
                return @"AM_2";
            }
            return @"night";
        }
        case AM_3:{
            if (exact) {
                return @"AM_3";
            }
            return @"night";
        }
        case AM_4:{
            if (exact) {
                return @"AM_4";
            }
            return @"night";
        }
        case AM_5:{
            if (exact) {
                return @"AM_5";
            }
            return @"night";
        }
        case AM_6:{
            if (exact) {
                return @"AM_6";
            }
            return @"day";
        }
        case AM_7:{
            if (exact) {
                return @"AM_7";
            }
            return @"day";
        }
        case AM_8:{
            if (exact) {
                return @"AM_8";
            }
            return @"day";
        }
        case AM_9:{
            if (exact) {
                return @"AM_9";
            }
            return @"day";
        }
        case AM_10:{
            if (exact) {
                return @"AM_10";
            }
            return @"day";
        }
        case AM_11:{
            if (exact) {
                return @"AM_11";
            }
            return @"day";
        }
        case PM_12:{
            if (exact) {
                return @"PM_12";
            }
            return @"day";
        }
        case PM_1:{
            if (exact) {
                return @"PM_1";
            }
            return @"day";
        }
        case PM_2:{
            if (exact) {
                return @"PM_2";
            }
            return @"day";
        }
        case PM_3:{
            if (exact) {
                return @"PM_3";
            }
            return @"day";
        }
        case PM_4:{
            if (exact) {
                return @"PM_4";
            }
            return @"day";
        }
        case PM_5:{
            if (exact) {
                return @"PM_5";
            }
            return @"day";
        }
        case PM_6:{
            if (exact) {
                return @"PM_6";
            }
            return @"day";
        }
        case PM_7:{
            if (exact) {
                return @"PM_7";
            }
            return @"night";
        }
        case PM_8:{
            if (exact) {
                return @"PM_8";
            }
            return @"night";
        }
        case PM_9:{
            if (exact) {
                return @"PM_9";
            }
            return @"night";
        }
        case PM_10:{
            if (exact) {
                return @"PM_10";
            }
            return @"night";
        }
        case PM_11:{
            if (exact) {
                return @"PM_11";
            }
            return @"night";
        }
            
    }
    NSLog(@"unknown time of day. cannot convert to string");
    return nil;
}

                                      
                                      
                                      
                                      
                                      
                                    

@end
