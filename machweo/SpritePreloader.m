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
    NSMutableDictionary* skyDict;
    NSMutableDictionary* textureDict;
    NSMutableArray* texArray;
    Constants* constants;
}
-(instancetype)init{
    if (self = [super init]) {
        constants = [Constants sharedInstance];
        obstaclePool = [constants OBSTACLE_POOL];
        skyDict = [constants SKY_DICT];
        texArray = [NSMutableArray array];
        textureDict = constants.TEXTURE_DICT;
    }
    return self;
}

-(void)load{
    NSArray* atlases;
    switch (constants.deviceType) {
        case iphone_4_5:
            atlases = @[[SKTextureAtlas atlasNamed:@"clouds_iphone4_iphone5"], [SKTextureAtlas atlasNamed:@"Desert_iphone4_iphone5"], [SKTextureAtlas atlasNamed:@"Jungle_iphone4_iphone5"], [SKTextureAtlas atlasNamed:@"obstacles_iphone4_iphone5"], [SKTextureAtlas atlasNamed:@"savanna_iphone4_iphone5"], [SKTextureAtlas atlasNamed:@"skys_iphone4_iphone5"]];
            break;
        case iphone_6:
            atlases = @[[SKTextureAtlas atlasNamed:@"clouds_iphone6"], [SKTextureAtlas atlasNamed:@"Desert_iphone6"], [SKTextureAtlas atlasNamed:@"Jungle_iphone6"], [SKTextureAtlas atlasNamed:@"obstacles_iphone6"], [SKTextureAtlas atlasNamed:@"savanna_iphone6"], [SKTextureAtlas atlasNamed:@"skys_iphone6"]];
            break;
        case iphone_6_plus:
            atlases = @[[SKTextureAtlas atlasNamed:@"clouds_iphone6_plus"], [SKTextureAtlas atlasNamed:@"Desert_iphone6_plus"], [SKTextureAtlas atlasNamed:@"Jungle_iphone6_plus"], [SKTextureAtlas atlasNamed:@"obstacles_iphone6_plus"], [SKTextureAtlas atlasNamed:@"savanna_iphone6_plus"], [SKTextureAtlas atlasNamed:@"skys_iphone6_plus"]];
            break;
        case ipad:
            atlases = @[[SKTextureAtlas atlasNamed:@"clouds_ipad"], [SKTextureAtlas atlasNamed:@"Desert_ipad"], [SKTextureAtlas atlasNamed:@"Jungle_ipad"], [SKTextureAtlas atlasNamed:@"obstacles_ipad"], [SKTextureAtlas atlasNamed:@"savanna_ipad"], [SKTextureAtlas atlasNamed:@"skys_ipad"]];
            break;
    }
    for (SKTextureAtlas* atlas in atlases) {
        for (NSString* name in atlas.textureNames) {
            NSString* correctedName = [name stringByDeletingPathExtension];
            if ([correctedName hasSuffix:@"obstacle"]) {
                [self populateObstacleSpritePoolWithName:correctedName andAtlas:atlas];
                continue;
            }
            if ([correctedName hasSuffix:@"decoration"]) {
                SKTexture *tex = [atlas textureNamed:correctedName];
                if ([correctedName isEqualToString:@"tree_decoration"]) {
                    [constants.TERRAIN_ARRAY addObject:tex];
                }
                if ([correctedName isEqualToString:@"tree_decoration2"]) {
                    [constants.TERRAIN_ARRAY addObject:tex];
                }
                if ([correctedName isEqualToString:@"tree_decoration3"]) {
                    [constants.TERRAIN_ARRAY addObject:tex];
                }
                if ([correctedName isEqualToString:@"tree_decoration4"]) {
                    [constants.TERRAIN_ARRAY addObject:tex];
                }
                [textureDict setValue:tex forKey:correctedName];
                [texArray addObject:tex];
                continue;
            }
            if ([correctedName hasPrefix:@"tenggriPS"]) {
                [self preprocessSkyImage:correctedName withAtlas:atlas];
                continue;
            }
        }
    }
    [SKTexture preloadTextures:texArray withCompletionHandler:^{
    }];
}

-(void)preprocessSkyImage:(NSString*)skyName withAtlas:(SKTextureAtlas*)atlas{
    SKTexture* skyTex = [atlas textureNamed:skyName];
    [texArray addObject:skyTex];
    SKSpriteNode* sky = [SKSpriteNode spriteNodeWithTexture:skyTex];
    sky.physicsBody = nil;
    sky.zPosition = constants.BACKGROUND_Z_POSITION;
    sky.name = skyName;
    [skyDict setValue:sky forKey:sky.name];
}

-(void)populateObstacleSpritePoolWithName:(NSString*)spriteName andAtlas:(SKTextureAtlas*)atlas{
    Obstacle* prototype = [self obstaclePrototypeWithName:spriteName andAtlas:atlas];
    prototype.xScale = prototype.yScale = .5;
    NSMutableArray* typeArray = [NSMutableArray array];
    for (int i = 0; i < NUM_SPRITES_PER_TYPE; i ++) {
        Obstacle* obsCopy = [prototype copy];
        obsCopy.position = CGPointMake(i, i);
        [typeArray addObject:obsCopy];
    }
    [obstaclePool setValue:typeArray forKey:spriteName];
 }

-(Obstacle*)obstaclePrototypeWithName:(NSString*)obsName andAtlas:(SKTextureAtlas*)atlas{
    SKTexture* spriteTexture = [atlas textureNamed:obsName];
    [texArray addObject:spriteTexture];
    Obstacle* obstacle = [Obstacle obstacleWithTexture:spriteTexture];
    obstacle.name = obsName;
    obstacle.physicsBody = [SKPhysicsBody bodyWithTexture:spriteTexture size:CGSizeMake(obstacle.size.width / 2, obstacle.size.height / 2)];
    obstacle.physicsBody.categoryBitMask = constants.OBSTACLE_HIT_CATEGORY;
    obstacle.physicsBody.contactTestBitMask = constants.PLAYER_HIT_CATEGORY;
    obstacle.physicsBody.dynamic = false;
    obstacle.zPosition = constants.OBSTACLE_Z_POSITION;
    return obstacle;
}

@end
