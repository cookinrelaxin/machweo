//
//  SpritePreloader.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 3/15/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "SpritePreloader.h"
#import "Obstacle.h"
#import "Constants.h"

const int NUM_SPRITES_PER_TYPE= 12;

@implementation SpritePreloader{
    NSMutableDictionary* obstaclePool;
    NSMutableDictionary* skyPool;

    NSMutableDictionary* textureDict;
    NSMutableArray* texArray;
    Constants* constants;

}
-(instancetype)init{
    if (self = [super init]) {
        constants = [Constants sharedInstance];
        obstaclePool = [NSMutableDictionary dictionary];
        skyPool = [NSMutableDictionary dictionary];
        texArray = [NSMutableArray array];
        textureDict = constants.TEXTURE_DICT;
        
        NSArray* urls = [self findPNGURLs];
        for (NSURL* url in urls) {
            NSString* name = [[url lastPathComponent] stringByDeletingPathExtension];
            //NSLog(@"name: %@", name);
            if ([name hasSuffix:@"obstacle"]) {
                [self populateObstacleSpritePoolWithName:name];
                continue;
            }
            if ([name hasSuffix:@"decoration"]) {
                SKTexture *tex = [SKTexture textureWithImageNamed:name];
                [textureDict setValue:tex forKey:name];
                [texArray addObject:tex];
                continue;
            }
            if ([name hasPrefix:@"tenggriPS"]) {
                [self preprocessSkyImage:name];
                continue;
            }
            
        
        }
        [SKTexture preloadTextures:texArray withCompletionHandler:^{}];
        texArray = nil;
    }
    
    return self;
}

-(void)preprocessSkyImage:(NSString*)skyName{
    //NSLog(@"skyName: %@", skyName);
    SKTexture* skyTex = [SKTexture textureWithImageNamed:skyName];
    [texArray addObject:skyTex];
    SKSpriteNode* sky = [SKSpriteNode spriteNodeWithTexture:skyTex];
    sky.zPosition = constants.BACKGROUND_Z_POSITION;
    sky.size = CGSizeMake(sky.size.width, sky.size.height * constants.SCALE_COEFFICIENT.dy);
    sky.name = skyName;
    [skyPool setValue:sky forKey:sky.name];

}

-(NSMutableDictionary*)getObstaclePool{
    return obstaclePool;
}

-(NSMutableDictionary*)getSkyPool{
    return skyPool;
}

-(void)populateObstacleSpritePoolWithName:(NSString*)spriteName{
    //NSLog(@"spriteName: %@", spriteName);
    
    Obstacle* prototype = [self obstaclePrototypeWithName:spriteName];
    
    NSMutableArray* typeArray = [NSMutableArray array];
    for (int i = 0; i < NUM_SPRITES_PER_TYPE; i ++) {
        Obstacle* obsCopy = [prototype copy];
        obsCopy.position = CGPointMake(i, i);
        [typeArray addObject:obsCopy];
    }
    //NSLog(@"typeArray: %@", typeArray);
    [obstaclePool setValue:typeArray forKey:spriteName];
 
}

-(Obstacle*)obstaclePrototypeWithName:(NSString*)obsName{
    SKTexture *spriteTexture = [SKTexture textureWithImageNamed:obsName];

    Obstacle* obstacle = [Obstacle obstacleWithTexture:spriteTexture];
    obstacle.name = obsName;
    obstacle.size = CGSizeMake(obstacle.size.width * constants.SCALE_COEFFICIENT.dy, obstacle.size.height * constants.SCALE_COEFFICIENT.dy);
    obstacle.physicsBody = [SKPhysicsBody bodyWithTexture:spriteTexture size:obstacle.size];
    obstacle.physicsBody.categoryBitMask = constants.OBSTACLE_HIT_CATEGORY;
    obstacle.physicsBody.contactTestBitMask = constants.PLAYER_HIT_CATEGORY;
    obstacle.physicsBody.dynamic = false;
    obstacle.zPosition = constants.OBSTACLE_Z_POSITION;
    return obstacle;
}

-(NSArray*)findPNGURLs{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *bundleRoot = [[NSBundle mainBundle] bundleURL];
    NSArray * dirContents =
    [fm contentsOfDirectoryAtURL:bundleRoot
      includingPropertiesForKeys:@[]
                         options:NSDirectoryEnumerationSkipsHiddenFiles
                           error:nil];
    NSPredicate * fltr = [NSPredicate predicateWithFormat:@"pathExtension='png'"];
    NSArray * onlyXMLS = [dirContents filteredArrayUsingPredicate:fltr];
    
    return onlyXMLS;
    
}

@end
