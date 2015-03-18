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
                    @autoreleasepool {
                        [self populateObstacleSpritePoolWithName:name andPath:[url path]];
                    }
                    continue;
                }
                if ([name hasSuffix:@"decoration"]) {
                    //UIImage* img = [UIImage imageNamed:name];
                    @autoreleasepool {
                        UIImage* img = [UIImage imageWithContentsOfFile:[url path]];
                        img = [self imageResize:img andResizeTo:CGSizeMake(img.size.width * constants.SCALE_COEFFICIENT.dy, img.size.height * constants.SCALE_COEFFICIENT.dy) shouldUseHighRes:YES];
                        SKTexture *tex = [SKTexture textureWithImage:img];
                        img = nil;
                        [textureDict setValue:tex forKey:name];
                        [texArray addObject:tex];
                    }
                    continue;
                }
                if ([name hasPrefix:@"tenggriPS"]) {
                    @autoreleasepool {
                        [self preprocessSkyImage:name withPath:[url path]];
                    }
                    continue;
                }
                
            
            }
        }
        [SKTexture preloadTextures:texArray withCompletionHandler:^{
            NSLog(@"textures preloaded");
        }];
    
    return self;
}

-(void)preprocessSkyImage:(NSString*)skyName withPath:(NSString*)path{
    //NSLog(@"skyName: %@", skyName);
    //UIImage* img = [UIImage imageNamed:skyName];
    UIImage* img = [UIImage imageWithContentsOfFile:path];
    img = [self imageResize:img andResizeTo:CGSizeMake(img.size.width, img.size.height * constants.SCALE_COEFFICIENT.dy) shouldUseHighRes:NO];
    SKTexture* skyTex = [SKTexture textureWithImage:img];
    [texArray addObject:skyTex];
    img = nil;
    SKSpriteNode* sky = [SKSpriteNode spriteNodeWithTexture:skyTex];
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

-(void)populateObstacleSpritePoolWithName:(NSString*)spriteName andPath:(NSString*)path{
    //NSLog(@"spriteName: %@", spriteName);
    
    Obstacle* prototype = [self obstaclePrototypeWithName:spriteName andPath:path];
    
    NSMutableArray* typeArray = [NSMutableArray array];
    for (int i = 0; i < NUM_SPRITES_PER_TYPE; i ++) {
        Obstacle* obsCopy = [prototype copy];
        obsCopy.position = CGPointMake(i, i);
        [typeArray addObject:obsCopy];
    }
    //NSLog(@"typeArray: %@", typeArray);
    [obstaclePool setValue:typeArray forKey:spriteName];
 
}

-(Obstacle*)obstaclePrototypeWithName:(NSString*)obsName andPath:(NSString*)path{
    
    //UIImage* img = [UIImage imageNamed:obsName];
    UIImage* img = [UIImage imageWithContentsOfFile:path];
    img = [self imageResize:img andResizeTo:CGSizeMake(img.size.width * constants.SCALE_COEFFICIENT.dy, img.size.height * constants.SCALE_COEFFICIENT.dy) shouldUseHighRes:YES];
    SKTexture* spriteTexture = [SKTexture textureWithImage:img];
    [texArray addObject:spriteTexture];
    
    Obstacle* obstacle = [Obstacle obstacleWithTexture:spriteTexture];
    img = nil;

    obstacle.name = obsName;
    //obstacle.size = CGSizeMake(obstacle.size.width * constants.SCALE_COEFFICIENT.dy, obstacle.size.height * constants.SCALE_COEFFICIENT.dy);
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

-(UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize shouldUseHighRes:(BOOL)highRes
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    /*You can remove the below comment if you dont want to scale the image in retina   device .Dont forget to comment UIGraphicsBeginImageContextWithOptions*/
    //UIGraphicsBeginImageContext(newSize);
    if (highRes) {
        UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    }
    else{
        UIGraphicsBeginImageContext(newSize);
    }
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
