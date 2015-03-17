//
//  CellParser.m
//  tgrrn
//
//  Created by John Feldcamp on 1/5/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "LevelParser.h"
#import "ChunkLoader.h"
//#import "GameDataManager.h"


@implementation LevelParser{
    
}

-(instancetype)init{
    if (self = [super init]) {
        _obstacleSets = [NSMutableDictionary dictionary];
        _biomes = [NSMutableDictionary dictionary];
        
        NSArray* urls = [self findXMLURLs];
        for (NSURL* url in urls) {
            NSString* name = [[url lastPathComponent] stringByDeletingPathExtension];
            //NSLog(@"name: %@", name);
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
    //NSLog(@"componentArray: %@", componentArray);
    NSString* difficulty = ((NSString*)[componentArray objectAtIndex:1]);
    NSMutableArray* difficultyArray = [_obstacleSets objectForKey:difficulty];
    if (!difficultyArray) {
        difficultyArray = [NSMutableArray array];
        [_obstacleSets setValue:difficultyArray forKey:difficulty];
    }
    
    NSMutableArray* obstacleSet = [self obstacleSetForName:obstacleSetName];
    [difficultyArray addObject:obstacleSet];
    return;
    
}

-(NSMutableArray*)obstacleSetForName:(NSString*)name{
    ChunkLoader *obstacleSetParser = [[ChunkLoader alloc] initWithFile:name];
    return obstacleSetParser.obstacleArray;
}



-(void)processDecorationSet:(NSString*)decorationSetName{
    NSArray* componentArray = [decorationSetName componentsSeparatedByString:@"_"];
    //NSLog(@"componentArray: %@", componentArray);
    NSString* biome = ((NSString*)[componentArray objectAtIndex:1]);
    NSMutableArray* biomeArray = [_biomes objectForKey:biome];
    if (!biomeArray) {
        biomeArray = [NSMutableArray array];
        [_biomes setValue:biomeArray forKey:biome];
    }
     //NSLog(@"decoration set name: %@", decorationSetName);
    NSMutableArray* decoSet = [self decorationSetForName:decorationSetName];
   // NSLog(@"decoration set: %@", schema);
    [biomeArray addObject:decoSet];
    
    return;
    
}

-(NSMutableArray*)decorationSetForName:(NSString*)name{
    ChunkLoader *decorationSetParser = [[ChunkLoader alloc] initWithFile:name];
    return decorationSetParser.decorationArray;
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

