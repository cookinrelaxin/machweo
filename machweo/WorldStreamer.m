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
#import "Decoration.h"

const int SWITCH_BIOMES_DENOM = 10;
const int THRESHOLD_FOR_PARSING_NEW_OBSTACLE_SET = 10;
//const int THRESHOLD_FOR_PARSING_NEW_DECORATION_SET = 20;
const int MAX_IN_USE_DECO_POOL_COUNT = 60;
const int MAX_UNUSED_DECO_POOL_COUNT = 60;

// get it as high as possible
const int MAX_DIFFICULTY = 5;

const int STADE_LENGTH = 250;


const int MAX_NUM_DECOS_TO_LOAD = MAX_IN_USE_DECO_POOL_COUNT;

const Biome INITIAL_BIOME = savanna;




@implementation WorldStreamer{
    SKScene* _world;
    SKNode* _obstacles;
    SKNode* _decorations;
    SKView* _view;
    NSMutableArray* _lines;
    NSMutableArray* _terrainPool;
    Biome currentBiome;
    Biome previousBiome;

    Constants* constants;
    BOOL chunkLoading;
    BOOL cleaningUpOldDecos;
    
    NSMutableDictionary* obstacle_pool;
    NSMutableArray* unused_deco_pool;
    NSMutableArray* in_use_deco_pool;
    
    NSUInteger numberOfDecosToLoad;
    
    NSMutableDictionary* IDDictionary;
   
}

-(instancetype)initWithWorld:(SKScene *)world withObstacles:(SKNode *)obstacles andDecorations:(SKNode *)decorations withinView:(SKView *)view andLines:(NSMutableArray *)lines withXOffset:(float)xOffset andTimeOfDay:(TimeOfDay)timeOfDay{
    if (self = [super init]) {
        constants = [Constants sharedInstance];

        _world = world;
        _obstacles = obstacles;
        _decorations = decorations;
        _view = view;
        _lines = lines;
        _terrainPool = [NSMutableArray array];
        
        obstacle_pool = constants.OBSTACLE_POOL;
        unused_deco_pool = [NSMutableArray array];
        in_use_deco_pool = [NSMutableArray array];
        IDDictionary = [NSMutableDictionary dictionary];
        
        currentBiome = savanna;
        //[self calculateNextBiomeWithDistance:0];
        
        // for double the fun
        [self preloadDecorationChunkWithTimeOfDay:timeOfDay andDistance:0 asynchronous:NO];
        [self preloadDecorationChunkWithTimeOfDay:timeOfDay andDistance:0 asynchronous:NO];

        for (int i = 0; i < unused_deco_pool.count; i ++) {
            [self loadNextDecoWithXOffset:0];
        }
        //numberOfDecosToLoad = unused_deco_pool.count;
        //numberOfDecosToLoad = MAX_IN_USE_DECO_POOL_COUNT;
        
        
        
    }
    
    return  self;
    
}

-(NSMutableArray*)getTerrainPool{
    return _terrainPool;
}


-(Biome)calculateNextBiomeWithDistance:(NSUInteger)distance{
    previousBiome = currentBiome;
    NSUInteger roundedDistance = RoundDownTo(distance, STADE_LENGTH);
    //NSLog(@"roundedDistance: %lu", (unsigned long)roundedDistance);
//    if (distance == 0) {
//        currentBiome = INITIAL_BIOME;
//        return INITIAL_BIOME;
//    }
//    if ((roundedDistance % (STADE_LENGTH * 3)) == 0) {
//        currentBiome = savanna;
//        return savanna;
//    }
//    if ((roundedDistance % (STADE_LENGTH * 2)) == 0) {
//        currentBiome = jungle;
//        return jungle;
//    }
//    if ((roundedDistance % STADE_LENGTH) == 0) {
//        currentBiome = sahara;
//        return sahara;
//    }
//    else return currentBiome;
    return jungle;
    
}

-(void)preloadDecorationChunkWithTimeOfDay:(TimeOfDay)timeOfDay andDistance:(NSUInteger)distance asynchronous:(BOOL)async{
    Biome biome = [self calculateNextBiomeWithDistance:distance];
    if (async) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            if (previousBiome != currentBiome) {
                NSLog(@"clear old biome");
                [unused_deco_pool removeAllObjects];
                [_terrainPool removeAllObjects];
                for (Decoration* deco in in_use_deco_pool) {
                    if ((deco.position.x - deco.size.width) > _view.bounds.size.width) {
                        [deco removeFromParent];
                        //NSLog(@"((deco.position.x - deco.size.width) > _view.bounds.size.width)");
                    }
                }
            }
            //});
            //dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
            NSString* decorationSet = [self calculateDecorationSetForTimeOfDay:timeOfDay andBiome:biome];
            ChunkLoader *decorationSetParser = [[ChunkLoader alloc] initWithFile:decorationSet];
            [decorationSetParser pourDecorationsIntoBucket:unused_deco_pool andTerrainPool:_terrainPool];
            chunkLoading = false;
        });
    }
    else{
        if (previousBiome != currentBiome) {
            NSLog(@"clear old biome");
            [unused_deco_pool removeAllObjects];
            [_terrainPool removeAllObjects];
            for (Decoration* deco in in_use_deco_pool) {
                if ((deco.position.x - deco.size.width) > _view.bounds.size.width) {
                    [deco removeFromParent];
                    //NSLog(@"((deco.position.x - deco.size.width) > _view.bounds.size.width)");
                }
            }
        }
        //});
        //dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        NSString* decorationSet = [self calculateDecorationSetForTimeOfDay:timeOfDay andBiome:biome];
        ChunkLoader *decorationSetParser = [[ChunkLoader alloc] initWithFile:decorationSet];
        [decorationSetParser pourDecorationsIntoBucket:unused_deco_pool andTerrainPool:_terrainPool];
        chunkLoading = false;
    }
    
    

    
}

-(void)loadNextDecoWithXOffset:(float)xOffset{
    if (unused_deco_pool.count > 0) {
        //NSMutableArray* trash = [NSMutableArray array];
        
        //for (Decoration* decoToLoad in unused_deco_pool) {
        Decoration* decoToLoad = [unused_deco_pool firstObject];
            NSString* toLoadID = decoToLoad.uniqueID;
            BOOL skip = NO;
            if ((currentBiome == savanna) || (currentBiome == jungle)) {
                if ([IDDictionary valueForKey:toLoadID]) {
                    skip = YES;

                }
            }
            if (skip) {
                [unused_deco_pool removeObject:decoToLoad];
                [self loadNextDecoWithXOffset:xOffset];
                return;
            }
            [in_use_deco_pool addObject:decoToLoad];
            [unused_deco_pool removeObject:decoToLoad];
            //decoToLoad.size = CGSizeMake(decoToLoad.size.width * constants.SCALE_COEFFICIENT.dy, decoToLoad.size.height * constants.SCALE_COEFFICIENT.dy);
            decoToLoad.position = CGPointMake((decoToLoad.position.x * constants.SCALE_COEFFICIENT.dy), decoToLoad.position.y * constants.SCALE_COEFFICIENT.dy);
            decoToLoad.position = [_decorations convertPoint:decoToLoad.position fromNode:_world];
            decoToLoad.position = CGPointMake(decoToLoad.position.x + xOffset, decoToLoad.position.y);
            [_decorations addChild:decoToLoad];
            [IDDictionary setValue:@"lol" forKey:decoToLoad.uniqueID];
        }

}

-(void)cleanUpOldDecos{
    if (!cleaningUpOldDecos) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
            cleaningUpOldDecos = true;
            NSMutableArray* trash = [NSMutableArray array];
            
            //for (Decoration* deco in in_use_deco_pool) {
            for (int i = 0; i < in_use_deco_pool.count; i++) {
                Decoration* deco = [in_use_deco_pool objectAtIndex:i];
                if (!deco){
                    continue;
                }
            
                CGPoint decoPositionInWorld = [_world convertPoint:deco.position fromNode:_decorations];
                CGPoint decoPositionInView = [_view convertPoint:decoPositionInWorld fromScene:_world];
                
                if (decoPositionInView.x < (0 - (deco.size.width / 2))){
                    //NSLog(@"[trash addObject:deco];");
                    [trash addObject:deco];
                }
            }

            dispatch_sync(dispatch_get_main_queue(), ^{
                //numberOfDecosToLoad = 0;
                for (Decoration* deco in trash) {
                    //numberOfDecosToLoad ++;
                    [deco removeFromParent];
                    [in_use_deco_pool removeObject:deco];
                    [IDDictionary removeObjectForKey:deco.uniqueID];
                }
                cleaningUpOldDecos = false;
                //trash = nil;
            });
        });
    }
    
    
}

-(BOOL)checkForOldObstacles{
    BOOL areThereAnyOldObstacles = false;
    
    NSMutableArray* phoenices = [NSMutableArray array];

    for (Obstacle* obs in _obstacles.children) {
        CGPoint obsPositionInWorld = [_world convertPoint:obs.position fromNode:_obstacles];
        CGPoint obsPositionInView = [_view convertPoint:obsPositionInWorld fromScene:_world];
        
        if (obsPositionInView.x < (0 - (obs.size.width / 2))){
            [phoenices addObject:obs];
        }
    }
    
    for (Obstacle* obs in phoenices) {
        areThereAnyOldObstacles = true;
        [obs removeFromParent];
        NSMutableArray* obstacleTypeArray = [obstacle_pool valueForKey:obs.name];
        [obstacleTypeArray addObject:obs];
        //NSLog(@"obstacleTypeArray: %@", obstacleTypeArray);
        //NSLog(@"add %@ from obstacle pool", obs.name);

        //[obs removeFromParent];
        //[in_use_obstacle_pool removeObject:obs];
        
    }

    phoenices = nil;
    return areThereAnyOldObstacles;

}


-(BOOL)shouldParseNewDecorationSet{

    if (((unused_deco_pool.count < MAX_UNUSED_DECO_POOL_COUNT) && (in_use_deco_pool.count < MAX_IN_USE_DECO_POOL_COUNT))) {
        return true;
    }
    return false;
}

-(void)updateWithPlayerDistance:(NSUInteger)playerDistance andTimeOfDay:(TimeOfDay)timeOfDay{
    if(!chunkLoading && [self shouldParseNewDecorationSet]){
//        //NSLog(@"[self preloadDecorationChunkWithTimeOfDay:timeOfDay]");
        chunkLoading = true;
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            [self preloadDecorationChunkWithTimeOfDay:timeOfDay andDistance:playerDistance asynchronous:YES];
//            //dispatch_sync(dispatch_get_main_queue(), ^{
//            chunkLoading = false;
//            //});
//        });
    }

    [self checkForOldObstacles];
    [self checkForLastObstacleWithDistance:playerDistance];
    
    float xOffset = _view.bounds.size.width;
    if (!chunkLoading) {
        [self cleanUpOldDecos];
    }
    //NSUInteger desiredNumDecosToLoad = MAX_NUM_DECOS_TO_LOAD;
   // numberOfDecosToLoad = desiredNumDecosToLoad;
    if (!chunkLoading) {
        //NSLog(@"unused_deco_pool.count: %lu", unused_deco_pool.count);
        //NSLog(@"in_use_deco_pool.count: %lu", in_use_deco_pool.count);
    }

    if (!chunkLoading) {
        [self loadNextDecoWithXOffset:xOffset];
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
    
    NSUInteger roundedDistance = RoundDownTo(distance, STADE_LENGTH);
    
    NSUInteger difficulty = (roundedDistance / STADE_LENGTH) + 1;
    if (difficulty > MAX_DIFFICULTY) {
        difficulty = MAX_DIFFICULTY;
    }
    //NSLog(@"difficulty: %lu", difficulty);
    
    return difficulty;
    
    //return 4;
}

-(void)loadObstacleChunkWithXOffset:(float)xOffset andDistance:(NSUInteger)distance{
    chunkLoading = true;
    NSUInteger difficulty = [self calculateDifficultyFromDistance:distance];
    //NSLog(@"difficulty: %lu", (unsigned long)difficulty);
    NSString* obstacleSet = [self calcuateObstacleSetForDifficulty:difficulty];
    //NSLog(@"obstacleSet: %@", obstacleSet);
    
    
    //NSLog(@"xOffset: %f", xOffset);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        ChunkLoader *obstacleSetParser = [[ChunkLoader alloc] initWithFile:obstacleSet];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [obstacleSetParser loadObstaclesInWorld:_world withObstacles:_obstacles withinView:_view andTerrainPool:_terrainPool withXOffset:xOffset];
            chunkLoading = false;
        });
    });
    
}

-(void)checkForLastObstacleWithDistance:(NSUInteger)distance{
    if (!chunkLoading) {
        
        Obstacle* lastObstacle = [_obstacles.children lastObject];
        if (!lastObstacle) {
            //NSLog(@"load first obstacle chunk");
            [self loadObstacleChunkWithXOffset:_view.bounds.size.width andDistance:0];
            
            return;
        }
        CGPoint lastObstaclePosInSelf = [_world convertPoint:lastObstacle.position fromNode:_obstacles];
        
        CGPoint lastObstaclePosInView = [_view convertPoint:lastObstaclePosInSelf fromScene:_world];
        if (lastObstaclePosInView.x < _view.bounds.size.width) {
            //NSLog(@"load next chunk");
            
            [self loadObstacleChunkWithXOffset:(lastObstaclePosInSelf.x + (lastObstacle.size.width / 2) + _view.bounds.size.width) andDistance:distance];
            
            
            //[self winGame];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopScrolling" object:nil];
            
        }
        
    }
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

-(NSString*)biomeToString:(Biome)biome{
    switch (biome) {
        case savanna:
            return @"savanna";
        case sahara:
            return @"sahara";
        case jungle:
            return @"jungle";
        case numBiomes:
            return @"error in biome to string!";
    }
    NSLog(@"unknown biome. cannot convert to string");
    return nil;
}

                                      
                                      
                                      
                                      
                                      
                                    

@end
