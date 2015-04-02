//
//  CellParser.m
//  tgrrn
//
//  Created by John Feldcamp on 1/5/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "LevelParser.h"

@implementation LevelParser{
    
}

-(instancetype)init{
    if (self = [super init]) {
        _obstacleSets = [NSMutableDictionary dictionary];
        _biomes = [NSMutableDictionary dictionary];
        NSArray* urls = [self findXMLURLs];
        for (NSURL* url in urls) {
            NSString* name = [[url lastPathComponent] stringByDeletingPathExtension];
            if ([name hasPrefix:@"obstacleSet"]) {
                [self processObstacleSet:name];
                continue;
            }
            if ([name hasPrefix:@"decorationSet"]) {
                [self processDecorationSet:name];
                continue;
            }
        }
    }
    return self;
}
-(void)processObstacleSet:(NSString*)obstacleSetName{
    NSArray* componentArray = [obstacleSetName componentsSeparatedByString:@"_"];
    NSString* difficulty = ((NSString*)[componentArray objectAtIndex:1]);
    NSMutableArray* difficultyArray = [_obstacleSets objectForKey:difficulty];
    if (!difficultyArray) {
        difficultyArray = [NSMutableArray array];
        [_obstacleSets setValue:difficultyArray forKey:difficulty];
    }
    [difficultyArray addObject:obstacleSetName];
    return;
}

-(void)processDecorationSet:(NSString*)decorationSetName{
    NSArray* componentArray = [decorationSetName componentsSeparatedByString:@"_"];
    NSString* biome = ((NSString*)[componentArray objectAtIndex:1]);
    NSMutableDictionary* biomeDict = [_biomes objectForKey:biome];
    if (!biomeDict) {
        biomeDict = [NSMutableDictionary dictionary];
        [_biomes setValue:biomeDict forKey:biome];
    }
    NSString* timeOfDay = ((NSString*)[componentArray objectAtIndex:2]);
    if ([timeOfDay isEqualToString:@"day"] || [timeOfDay isEqualToString:@"night"]) {
        NSMutableArray* timeArray = [biomeDict valueForKey:timeOfDay];
        if (!timeArray) {
            timeArray = [NSMutableArray array];
            [biomeDict setValue:timeArray forKey:timeOfDay];
        }
        [timeArray addObject:decorationSetName];
    }
    else{
        NSLog(@"error: time of day must be either day or night");
    }
    return;
}

-(NSArray*)findXMLURLs{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *bundleRoot = [[NSBundle mainBundle] bundleURL];
    NSArray * dirContents =
    [fm contentsOfDirectoryAtURL:bundleRoot
      includingPropertiesForKeys:@[]
                         options:NSDirectoryEnumerationSkipsHiddenFiles
                           error:nil];
    NSPredicate * fltr = [NSPredicate predicateWithFormat:@"pathExtension='xml'"];
    NSArray * onlyXMLS = [dirContents filteredArrayUsingPredicate:fltr];
    
    return onlyXMLS;
    
}

@end

