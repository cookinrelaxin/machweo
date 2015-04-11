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

int MAX_IN_USE_DECO_POOL_COUNT = 50;
int MAX_UNUSED_DECO_POOL_COUNT = 50;
const int MAX_DIFFICULTY = 20;
const int OBSTACLE_STADE_LENGTH = 150;
const int DECORATION_STADE_LENGTH = 400;
const float DELTA_TIME_THRESHOLD_FOR_UPDATE = 0.02f;

@implementation WorldStreamer{
    SKScene* _scene;
    SKNode* _obstacles;
    SKNode* _decorations;
    SKView* _view;
    NSMutableArray* _lines;
    Biome currentBiome;
    Biome previousBiome;
    Biome one_times_stade_biome;
    Biome two_times_stade_biome;
    Biome three_times_stade_biome;
    Constants* constants;
    BOOL chunkLoading;
    BOOL shouldLoadObstacles;
    BOOL cleaningUpOldDecos;
    NSMutableDictionary* obstacle_pool;
    NSMutableArray* unused_deco_pool;
    NSMutableArray* in_use_deco_pool;
    NSUInteger numberOfDecosToLoad;
    NSMutableDictionary* IDDictionary;
    NSUInteger total_previous_distance;
}

-(Biome)getCurrentBiome{
    return currentBiome;
}

-(instancetype)initWithScene:(SKScene *)scene withObstacles:(SKNode *)obstacles andDecorations:(SKNode *)decorations withinView:(SKView *)view andLines:(NSMutableArray *)lines withXOffset:(float)xOffset{
    if (self = [super init]) {
        constants = [Constants sharedInstance];
        _scene = scene;
        _obstacles = obstacles;
        _decorations = decorations;
        _view = view;
        _lines = lines;
        obstacle_pool = constants.OBSTACLE_POOL;
        unused_deco_pool = [NSMutableArray array];
        in_use_deco_pool = [NSMutableArray array];
        IDDictionary = [NSMutableDictionary dictionary];
        currentBiome = savanna;
        [self setMaxDecos];
        [self calculateInitialBiome];
    }
    return  self;
}

-(void)setMaxDecos{
    switch (constants.deviceType) {
        case iphone_4_5:
            MAX_IN_USE_DECO_POOL_COUNT = MAX_UNUSED_DECO_POOL_COUNT = 15;
            break;
        case iphone_6:
            MAX_IN_USE_DECO_POOL_COUNT = MAX_UNUSED_DECO_POOL_COUNT = 20;
            break;
        case iphone_6_plus:
            MAX_IN_USE_DECO_POOL_COUNT = MAX_UNUSED_DECO_POOL_COUNT = 30;
            break;
        case ipad:
            MAX_IN_USE_DECO_POOL_COUNT = MAX_UNUSED_DECO_POOL_COUNT = 15;
            break;
    }
    //NSLog(@"MAX_IN_USE_DECO_POOL_COUNT: %d", MAX_IN_USE_DECO_POOL_COUNT);
}
-(void)enableObstacles{
    shouldLoadObstacles = true;
}

-(void)resetWithFinalDistance:(NSUInteger)finalDistance{
    total_previous_distance += finalDistance;
    for (Obstacle *obs in _obstacles.children) {
        [obs runAction:[SKAction fadeAlphaTo:0 duration:.5] completion:^(void){
            obs.alpha = 1.0f;
            NSMutableArray* obstacleTypeArray = [obstacle_pool valueForKey:obs.name];
            [obstacleTypeArray addObject:obs];
            [obs removeFromParent];
        }];
    }
    shouldLoadObstacles = false;
}

-(Biome)calculateNextBiomeWithDistance:(NSUInteger)distance{
    previousBiome = currentBiome;
    NSUInteger roundedDistance = RoundDownTo(distance, DECORATION_STADE_LENGTH);
    if ((roundedDistance % (DECORATION_STADE_LENGTH * 3)) == 0) {
        currentBiome = three_times_stade_biome;
    }
    else if ((roundedDistance % (DECORATION_STADE_LENGTH * 2)) == 0) {
        currentBiome = two_times_stade_biome;
    }
    else if ((roundedDistance % DECORATION_STADE_LENGTH) == 0) {
        currentBiome = one_times_stade_biome;
    }
    return currentBiome;
}

-(Biome)calculateInitialBiome{
    one_times_stade_biome = arc4random_uniform(numBiomes);
    if (one_times_stade_biome == 0) {
        two_times_stade_biome = 1;
        three_times_stade_biome = 2;
    }
    else if (one_times_stade_biome == 1) {
        two_times_stade_biome = 2;
        three_times_stade_biome = 0;
    }
    else if (one_times_stade_biome == 2) {
        two_times_stade_biome = 0;
        three_times_stade_biome = 1;
    }
    return one_times_stade_biome;
}

-(void)preloadDecorationChunkWithDistance:(NSUInteger)distance asynchronous:(BOOL)async{
    chunkLoading = true;
    Biome biome = [self calculateNextBiomeWithDistance:distance];
        if (previousBiome != currentBiome) {
            [unused_deco_pool removeAllObjects];
            for (Decoration* deco in in_use_deco_pool) {
                if ((deco.position.x - deco.size.width) > _view.bounds.size.width) {
                    [deco removeFromParent];
                }
            }
        }
        NSString* decorationSet = [self calculateDecorationSetForBiome:biome];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        ChunkLoader *decorationSetParser = [[ChunkLoader alloc] initWithFile:decorationSet];
        [decorationSetParser pourDecorationsIntoBucket:unused_deco_pool];
        chunkLoading = false;
    });
}

-(void)loadNextDecoWithXOffset:(float)xOffset{
    chunkLoading = true;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        if (unused_deco_pool.count > 0) {
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
                decoToLoad.position = CGPointMake((decoToLoad.position.x * constants.SCALE_COEFFICIENT.dy), decoToLoad.position.y * constants.SCALE_COEFFICIENT.dy);
                decoToLoad.position = [_decorations convertPoint:decoToLoad.position fromNode:_scene];
                decoToLoad.position = CGPointMake(decoToLoad.position.x + xOffset, decoToLoad.position.y);
                [_decorations addChild:decoToLoad];
                [IDDictionary setValue:@"lol" forKey:decoToLoad.uniqueID];
            }
        chunkLoading = false;
    });
}

-(void)cleanUpOldDecos{
    if (!cleaningUpOldDecos) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
            cleaningUpOldDecos = true;
            NSMutableArray* trash = [NSMutableArray array];
            for (int i = 0; i < in_use_deco_pool.count; i++) {
                Decoration* deco = [in_use_deco_pool objectAtIndex:i];
                if (!deco){
                    continue;
                }
                CGPoint decoPositionInWorld = [_scene convertPoint:deco.position fromNode:_decorations];
                CGPoint decoPositionInView = [_view convertPoint:decoPositionInWorld fromScene:_scene];
                if (decoPositionInView.x < (0 - (deco.size.width / 2))){
                    [trash addObject:deco];
                }
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                for (Decoration* deco in trash) {
                    [deco removeFromParent];
                    [in_use_deco_pool removeObject:deco];
                    [IDDictionary removeObjectForKey:deco.uniqueID];
                }
                cleaningUpOldDecos = false;
            });
        });
    }
}

-(BOOL)checkForOldObstacles{
    BOOL areThereAnyOldObstacles = false;
    NSMutableArray* phoenices = [NSMutableArray array];
    for (Obstacle* obs in _obstacles.children) {
        CGPoint obsPositionInWorld = [_scene convertPoint:obs.position fromNode:_obstacles];
        CGPoint obsPositionInView = [_view convertPoint:obsPositionInWorld fromScene:_scene];
        if (obsPositionInView.x < (0 - (obs.size.height / 2))){
            [phoenices addObject:obs];
        }
    }
    for (Obstacle* obs in phoenices) {
        areThereAnyOldObstacles = true;
        [obs removeFromParent];
        NSMutableArray* obstacleTypeArray = [obstacle_pool valueForKey:obs.name];
        [obstacleTypeArray addObject:obs];
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

-(void)updateWithPlayerDistance:(NSUInteger)playerDistance andDeltaTime:(NSTimeInterval)deltaTime{
    if (deltaTime < DELTA_TIME_THRESHOLD_FOR_UPDATE) {
        if (shouldLoadObstacles) {
            [self checkForOldObstacles];
            if (!chunkLoading) {
                [self checkForLastObstacleWithDistance:playerDistance];
            }
        }
        playerDistance += total_previous_distance;
        if(!chunkLoading && [self shouldParseNewDecorationSet]){
            [self preloadDecorationChunkWithDistance:playerDistance asynchronous:YES];
        }
        float xOffset = _view.bounds.size.width;
        if (!chunkLoading) {
            [self cleanUpOldDecos];
        }
        if (!chunkLoading) {
            [self loadNextDecoWithXOffset:xOffset];
        }
    }

}



-(NSString*)calcuateObstacleSetForDifficulty:(NSUInteger)difficulty{
    NSMutableArray* difficultyArray = [constants.OBSTACLE_SETS valueForKey:[NSString stringWithFormat:@"%lu", (unsigned long)difficulty]];
    NSUInteger chance = arc4random_uniform((uint)difficultyArray.count);
    NSString* obstacleSet = [difficultyArray objectAtIndex:chance];
    return obstacleSet;
}

-(NSString*)calculateDecorationSetForBiome:(Biome)biome{
    NSMutableDictionary* biomeDict = [constants.BIOMES valueForKey:[self biomeToString:biome]];
    NSMutableArray* timeOfDayArray = [biomeDict valueForKey:@"day"];
    NSUInteger chance = arc4random_uniform((uint)timeOfDayArray.count);
    NSString* decorationSet = [timeOfDayArray objectAtIndex:chance];
    return decorationSet;
}


-(NSUInteger)calculateDifficultyFromDistance:(NSUInteger)distance{
    NSUInteger roundedDistance = RoundDownTo(distance, OBSTACLE_STADE_LENGTH);
        NSUInteger difficulty = (roundedDistance / OBSTACLE_STADE_LENGTH) + 1;
    if (difficulty > MAX_DIFFICULTY) {
        difficulty = MAX_DIFFICULTY;
    }
    return difficulty;
}

-(void)loadObstacleChunkWithXOffset:(float)xOffset andDistance:(NSUInteger)distance{
    chunkLoading = true;
    NSUInteger difficulty = [self calculateDifficultyFromDistance:distance];
    NSString* obstacleSet = [self calcuateObstacleSetForDifficulty:difficulty];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        ChunkLoader *obstacleSetParser = [[ChunkLoader alloc] initWithFile:obstacleSet];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [obstacleSetParser loadObstaclesInWorld:_scene withObstacles:_obstacles withinView:_view withXOffset:xOffset];
            chunkLoading = false;
        });
    });
}

-(void)checkForLastObstacleWithDistance:(NSUInteger)distance{
    Obstacle* lastObstacle = [_obstacles.children lastObject];
    if (!lastObstacle) {
        [self loadObstacleChunkWithXOffset:_view.bounds.size.width * 3 andDistance:0];
        return;
    }
    CGPoint lastObstaclePosInSelf = [_scene convertPoint:lastObstacle.position fromNode:_obstacles];
    CGPoint lastObstaclePosInView = [_view convertPoint:lastObstaclePosInSelf fromScene:_scene];
    if (lastObstaclePosInView.x < _view.bounds.size.width) {
        [self loadObstacleChunkWithXOffset:(lastObstaclePosInSelf.x + (lastObstacle.size.width / 2) + (_view.bounds.size.width * 3/4)) andDistance:distance];
   }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopScrolling" object:nil];
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
