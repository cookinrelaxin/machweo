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
int THRESHOLD_FOR_PARSING_NEW_OBSTACLE_SET = 3;
int THRESHOLD_FOR_PARSING_NEW_DECORATION_SET = 3;


@implementation WorldStreamer{
    SKScene* _world;
    SKNode* _obstacles;
    SKNode* _decorations;
    SKView* _view;
    NSMutableArray* _lines;
    NSMutableArray* _terrainPool;
    Biome currentBiome;
    Constants* constants;
    BOOL chunkLoading;
    
    NSMutableArray* unused_obstacle_pool;
    NSMutableArray* in_use_obstacle_pool;
    NSMutableArray* unused_deco_pool;
    NSMutableArray* in_use_deco_pool;
    

    
    
    
    
    
}

-(instancetype)initWithWorld:(SKScene *)world withObstacles:(SKNode *)obstacles andDecorations:(SKNode *)decorations withinView:(SKView *)view andLines:(NSMutableArray *)lines andTerrainPool:(NSMutableArray *)terrainPool withXOffset:(float)xOffset{
    if (self = [super init]) {
        _world = world;
        _obstacles = obstacles;
        _decorations = decorations;
        _view = view;
        _lines = lines;
        _terrainPool = terrainPool;
        
        unused_obstacle_pool = [NSMutableArray array];
        in_use_obstacle_pool = [NSMutableArray array];
        unused_deco_pool = [NSMutableArray array];
        in_use_deco_pool = [NSMutableArray array];
        
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

-(void)preloadObstacleChunkWithDistance:(NSUInteger)distance{
    NSUInteger difficulty = [self calculateDifficultyFromDistance:distance];
    NSString* obstacleSet = [self calcuateObstacleSetForDifficulty:difficulty];
    ChunkLoader *obstacleSetParser = [[ChunkLoader alloc] initWithFile:obstacleSet];
    [obstacleSetParser pourObstaclesIntoBucket:unused_obstacle_pool];
}

-(void)loadNextObstacleWithXOffset:(float)xOffset{
    
    Obstacle* newObstacle = [unused_obstacle_pool objectAtIndex:0];
    [unused_obstacle_pool removeObject:newObstacle];
    
    newObstacle.position = CGPointMake((newObstacle.position.x * constants.SCALE_COEFFICIENT.dy), newObstacle.position.y * constants.SCALE_COEFFICIENT.dy);
    newObstacle.position = [_obstacles convertPoint:newObstacle.position fromNode:_world];
    newObstacle.position = CGPointMake(newObstacle.position.x + xOffset, newObstacle.position.y);

    newObstacle.zPosition = constants.OBSTACLE_Z_POSITION;
    [_obstacles addChild:newObstacle];
    [in_use_obstacle_pool addObject:newObstacle];
    
}

-(void)preloadDecorationChunkWithTimeOfDay:(TimeOfDay)timeOfDay{
    Biome biome = [self calculateNextBiome];
    NSString* decorationSet = [self calculateDecorationSetForTimeOfDay:timeOfDay andBiome:biome];
    ChunkLoader *decorationSetParser = [[ChunkLoader alloc] initWithFile:decorationSet];
    [decorationSetParser pourDecorationsIntoBucket:unused_deco_pool];
}

-(void)loadNextDecoWithXOffset:(float)xOffset andMinimumZPosition:(float)minimumZPosition{
    
    SKSpriteNode* decoToLoad;
    for (SKSpriteNode* newDeco in unused_deco_pool) {
        if (newDeco.zPosition >= minimumZPosition) {
            decoToLoad = newDeco;
            break;
        }
    }
    [unused_deco_pool removeObject:decoToLoad];
    
    decoToLoad.size = CGSizeMake(decoToLoad.size.width * constants.SCALE_COEFFICIENT.dy, decoToLoad.size.height * constants.SCALE_COEFFICIENT.dy);
    decoToLoad.position = CGPointMake((decoToLoad.position.x * constants.SCALE_COEFFICIENT.dy), decoToLoad.position.y * constants.SCALE_COEFFICIENT.dy);
    decoToLoad.position = [_decorations convertPoint:decoToLoad.position fromNode:_world];
    decoToLoad.position = CGPointMake(decoToLoad.position.x + xOffset, decoToLoad.position.y);

    [_decorations addChild:decoToLoad];
    [in_use_deco_pool addObject:decoToLoad];

}

-(float)checkForOldDecos{
    NSMutableArray* trash = [NSMutableArray array];
    
    float maxZposition = 0;
    
    for (SKSpriteNode* deco in in_use_deco_pool) {
        CGPoint decoPositionInWorld = [_world convertPoint:deco.position fromNode:_obstacles];
        CGPoint decoPositionInView = [_view convertPoint:decoPositionInWorld fromScene:_world];
        
        if (decoPositionInView.x < (_view.bounds.size.width - (deco.size.width / 2))){
            [trash addObject:deco];
        }
    }
    
    for (Obstacle* deco in trash) {
        if (deco.zPosition > maxZposition) {
            maxZposition = deco.zPosition;
        }
        [deco removeFromParent];
        [in_use_deco_pool removeObject:deco];
    }
    
    trash = nil;
    return maxZposition;
    
}

-(BOOL)checkForOldObstacles{
    BOOL areThereAnyOldObstacles = false;
    
    NSMutableArray* trash = [NSMutableArray array];

    for (Obstacle* obs in in_use_obstacle_pool) {
        CGPoint obsPositionInWorld = [_world convertPoint:obs.position fromNode:_obstacles];
        CGPoint obsPositionInView = [_view convertPoint:obsPositionInWorld fromScene:_world];
        
        if (obsPositionInView.x < (_view.bounds.size.width - (obs.size.width / 2))){
            [trash addObject:obs];
        }
    }
    
    for (Obstacle* obs in trash) {
        areThereAnyOldObstacles = true;
        [obs removeFromParent];
        [in_use_obstacle_pool removeObject:obs];
    }

    trash = nil;
    return areThereAnyOldObstacles;

}

-(BOOL)shouldParseNewObstacleSet{
    if (unused_obstacle_pool.count < THRESHOLD_FOR_PARSING_NEW_OBSTACLE_SET) {
        return true;
    }
    return false;
}

-(BOOL)shouldParseNewDecorationSet{
    if (unused_deco_pool.count < THRESHOLD_FOR_PARSING_NEW_DECORATION_SET) {
        return true;
    }
    return false;
}

-(void)updateWithPlayerDistance:(NSUInteger)playerDistance andTimeOfDay:(TimeOfDay)timeOfDay{
    
    if([self checkForOldDecos]){
        [self preloadDecorationChunkWithTimeOfDay:timeOfDay];
    }
    if([self checkForOldObstacles]){
        [self preloadObstacleChunkWithDistance:playerDistance];
    }
    
    //what the hell should our xOffsets be?
    float xOffset = 0;

    float minimumZpositionToLoad = [self checkForOldDecos];
    if (minimumZpositionToLoad > 0) {
        [self loadNextDecoWithXOffset:xOffset andMinimumZPosition:minimumZpositionToLoad];
    }
    
    if ([self checkForOldObstacles]) {
        [self loadNextObstacleWithXOffset:xOffset];
        
    }
    
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


-(NSUInteger)calculateDifficultyFromDistance:(NSUInteger)distance{
 
    
    //for now just return 0
    return 1;
}

//-(void)checkForLastObstacleWithDistance:(NSUInteger)distance{
//    if (!chunkLoading) {
//
//        Obstacle* lastObstacle = [_obstacles.children lastObject];
//        if (!lastObstacle) {
//            [self loadObstacleChunkWithXOffset:_view.bounds.size.width andDistance:0];
//            
//            return;
//        }
//        CGPoint lastObstaclePosInSelf = [_world convertPoint:lastObstacle.position fromNode:_obstacles];
//
//        CGPoint lastObstaclePosInView = [_view convertPoint:lastObstaclePosInSelf fromScene:_world];
//          if (lastObstaclePosInView.x < _view.bounds.size.width) {
//                NSLog(@"load next chunk");
//                    NSMutableArray* trash = [NSMutableArray array];
//                    for (SKSpriteNode* sprite in _bucket) {
//                        if (![sprite isKindOfClass:[Obstacle class]]) {
//                            continue;
//                        }
//                        CGPoint posInSelf = [_world convertPoint:CGPointMake(sprite.position.x + (sprite.size.width / 2), sprite.position.y) fromNode:sprite.parent];
//                        if (posInSelf.x > 0) {
//                            continue;
//                        }
//
//                        [sprite removeFromParent];
//                        [trash addObject:sprite];
//                    }
//                    for (SKSpriteNode* sprite in trash) {
//                        [_bucket removeObject:sprite];
//                    }
//                    trash = nil;
////                }
////                chunkLoading = true;
////                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
////                    ChunkLoader *cl = [[ChunkLoader alloc] initWithFile:nextChunk];
////                    dispatch_sync(dispatch_get_main_queue(), ^{
////                        [cl loadWorld:self withObstacles:_obstacles andDecorations:_decorations andBucket:previousChunks withinView:self.view andLines:arrayOfLines andTerrainPool:terrainPool withXOffset:lastObstaclePosInSelf.x];
////                        chunkLoading = false;
////                    });
////                });
//              
//              [self loadObstacleChunkWithXOffset:lastObstaclePosInSelf.x + ((lastObstacle.size.width / 2) * (arc4random_uniform(3) + 1)) andDistance:distance];
//
//
//                //[self winGame];
//            }
//        else{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopScrolling" object:nil];
//
////                stopScrolling = true;
//        }
//
//    }
//}
//
//-(void)checkForLastDecorationWithTimeOfDay:(TimeOfDay)timeOfDay{
//    if (!chunkLoading) {
//        
//        SKSpriteNode* lastDeco = [_decorations.children lastObject];
//        if (!lastDeco) {
//            [self loadDecorationChunkWithXOffset:0 andTimeOfDay:timeOfDay];
//            
//            return;
//        }
//        CGPoint lastDecoPosInSelf = [_world convertPoint:lastDeco.position fromNode:_decorations];
//        
//        CGPoint lastDecoPosInView = [_view convertPoint:lastDecoPosInSelf fromScene:_world];
//        if (lastDecoPosInView.x < _view.bounds.size.width) {
//            NSLog(@"load next chunk");
//            NSMutableArray* trash = [NSMutableArray array];
//            for (SKSpriteNode* sprite in _bucket) {
//                if ([sprite isKindOfClass:[Obstacle class]]) {
//                    continue;
//                }
//                CGPoint posInSelf = [_world convertPoint:CGPointMake(sprite.position.x + (sprite.size.width / 2), sprite.position.y) fromNode:sprite.parent];
//                if (posInSelf.x > 0) {
//                    SKAction* fadeOut = [SKAction fadeAlphaTo:0.0f duration:.5];
//                    [sprite runAction:fadeOut completion:^{
//                        [sprite removeFromParent];
//                    }];
//                    continue;
//                }
//                
//                [sprite removeFromParent];
//                [trash addObject:sprite];
//            }
//            for (SKSpriteNode* sprite in trash) {
//                [_bucket removeObject:sprite];
//            }
//            trash = nil;
//            //                }
//            //                chunkLoading = true;
//            //                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
//            //                    ChunkLoader *cl = [[ChunkLoader alloc] initWithFile:nextChunk];
//            //                    dispatch_sync(dispatch_get_main_queue(), ^{
//            //                        [cl loadWorld:self withObstacles:_obstacles andDecorations:_decorations andBucket:previousChunks withinView:self.view andLines:arrayOfLines andTerrainPool:terrainPool withXOffset:lastObstaclePosInSelf.x];
//            //                        chunkLoading = false;
//            //                    });
//            //                });
//            
//            [self loadDecorationChunkWithXOffset:lastDecoPosInSelf.x + (lastDeco.size.width / 2) andTimeOfDay:timeOfDay];
//            
//            
//            //[self winGame];
//        }
////        else{
////            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopScrolling" object:nil];
////            
////            //                stopScrolling = true;
////        }
//        
//    }
//}


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

                                      
                                      
                                      
                                      
                                      
                                    

@end
