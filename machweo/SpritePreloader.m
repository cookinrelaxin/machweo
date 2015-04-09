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
        NSArray* atlases = @[[SKTextureAtlas atlasNamed:@"clouds"], [SKTextureAtlas atlasNamed:@"Desert"], [SKTextureAtlas atlasNamed:@"Jungle"], [SKTextureAtlas atlasNamed:@"obstacles"], [SKTextureAtlas atlasNamed:@"savanna"], [SKTextureAtlas atlasNamed:@"skys"]];
        for (SKTextureAtlas* atlas in atlases) {
            for (NSString* name in atlas.textureNames) {
                if ([name hasSuffix:@"obstacle"]) {
                    @autoreleasepool {
                        [self populateObstacleSpritePoolWithName:name andAtlas:atlas];
                    }
                    continue;
                }
                if ([name hasSuffix:@"decoration"]) {
                    @autoreleasepool {
                        //UIImage* img = [UIImage imageWithContentsOfFile:[url path]];
                        //img = [self imageResize:img andResizeTo:CGSizeMake(img.size.width * constants.SCALE_COEFFICIENT.dy, img.size.height * constants.SCALE_COEFFICIENT.dy) shouldUseHighRes:constants.enableHighResTextures];
                        //SKTexture *tex = [SKTexture textureWithImage:img];
                        SKTexture *tex = [atlas textureNamed:name];
                        tex.size = CGSizeMake(img.size.width * constants.SCALE_COEFFICIENT.dy, img.size.height * constants.SCALE_COEFFICIENT.dy);
                        if ([name isEqualToString:@"tree_decoration"]) {
                            [constants.TERRAIN_ARRAY addObject:tex];
                        }
                        if ([name isEqualToString:@"tree_decoration2"]) {
                            [constants.TERRAIN_ARRAY addObject:tex];
                        }
                        if ([name isEqualToString:@"tree_decoration3"]) {
                            [constants.TERRAIN_ARRAY addObject:tex];
                        }
                        if ([name isEqualToString:@"tree_decoration4"]) {
                            [constants.TERRAIN_ARRAY addObject:tex];
                        }
                       // img = nil;
                        [textureDict setValue:tex forKey:name];
                        [texArray addObject:tex];
                    }
                    continue;
                }
                if ([name hasPrefix:@"tenggriPS"]) {
                    @autoreleasepool {
                        [self preprocessSkyImage:name withAtlas:atlas];
                    }
                    continue;
                }
            }
        }

        [SKTexture preloadTextures:texArray withCompletionHandler:^{
        }];
    }
    return self;
}

-(void)preprocessSkyImage:(NSString*)skyName withAtlas:(SKTextureAtlas*)atlas{
    SKTexture* skyTex = [atlas textureNamed:skyName];
    skyTex.size = CGSizeMake(skyTex.size.width * constants.SCALE_COEFFICIENT.dy, skyTex.size.height * constants.SCALE_COEFFICIENT.dy);
    [texArray addObject:skyTex];
    SKSpriteNode* sky = [SKSpriteNode spriteNodeWithTexture:skyTex];
    sky.physicsBody = nil;
    sky.zPosition = constants.BACKGROUND_Z_POSITION;
    sky.name = skyName;
    [skyPool setValue:sky forKey:sky.name];
}

-(NSMutableDictionary*)getObstaclePool{
    return obstaclePool;
}

-(NSMutableDictionary*)getSkyPool{
    return skyPool;
}

-(void)populateObstacleSpritePoolWithName:(NSString*)spriteName andAtlas:(SKTextureAtlas*)atlas{
    Obstacle* prototype = [self obstaclePrototypeWithName:spriteName];
    NSMutableArray* typeArray = [NSMutableArray array];
    for (int i = 0; i < NUM_SPRITES_PER_TYPE; i ++) {
        Obstacle* obsCopy = [prototype copy];
        obsCopy.position = CGPointMake(i, i);
        [typeArray addObject:obsCopy];
    }
    [obstaclePool setValue:typeArray forKey:spriteName];
 }

-(Obstacle*)obstaclePrototypeWithName:(NSString*)obsName andAtlas:(SKTextureAtlas*)atlas{
    UIImage* img = [UIImage imageWithContentsOfFile:path];
    img = [self imageResize:img andResizeTo:CGSizeMake(img.size.width * constants.SCALE_COEFFICIENT.dy, img.size.height * constants.SCALE_COEFFICIENT.dy) shouldUseHighRes:constants.enableHighResTextures];
    SKTexture* spriteTexture = [SKTexture textureWithImage:img];
    [texArray addObject:spriteTexture];
    Obstacle* obstacle = [Obstacle obstacleWithTexture:spriteTexture];
    img = nil;
    obstacle.name = obsName;
    obstacle.physicsBody = [SKPhysicsBody bodyWithTexture:spriteTexture size:obstacle.size];
    obstacle.physicsBody.categoryBitMask = constants.OBSTACLE_HIT_CATEGORY;
    obstacle.physicsBody.contactTestBitMask = constants.PLAYER_HIT_CATEGORY;
    obstacle.physicsBody.dynamic = false;
    obstacle.zPosition = constants.OBSTACLE_Z_POSITION;
    return obstacle;
}

//-(UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize shouldUseHighRes:(BOOL)highRes
//{
//    CGFloat scale = [[UIScreen mainScreen]scale];
//    if (highRes) {
//        UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
//    }
//    else{
//        UIGraphicsBeginImageContext(newSize);
//    }
//    //CGContextRef cgr = UIGraphicsGetCurrentContext();
//    //CGContextSetInterpolationQuality(cgr, kCGInterpolationNone);
//    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}

@end
