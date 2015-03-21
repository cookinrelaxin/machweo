//
//  AnimationComponent.m
//  ChunkADT
//
//  Created by John Feldcamp on 7/11/14.
//  Copyright (c) 2014 Zachary Feldcamp. All rights reserved.
//

#import "AnimationComponent.h"
#import "Constants.h"

@implementation AnimationComponent {
    
}

- (id)initAnimationDictionary {
    //Constants* constants = [Constants sharedInstance];
    {
        _runningFrames = [[NSMutableArray alloc] init];
        SKTextureAtlas *runningAtlas = [SKTextureAtlas atlasNamed:@"runningDude"];
        NSUInteger numImages = runningAtlas.textureNames.count;
        for (int i=1; i <= numImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"cloakman%d", i];
            SKTexture *tex = [runningAtlas textureNamed:textureName];
            tex.filteringMode = SKTextureFilteringNearest;
            [_runningFrames addObject:tex];
        }
        [SKTexture preloadTextures:_runningFrames withCompletionHandler:^{}];
    }
    {
        _jumpingFrames = [[NSMutableArray alloc] init];
        SKTextureAtlas *runningAtlas = [SKTextureAtlas atlasNamed:@"jumpingDude"];
        NSUInteger numImages = runningAtlas.textureNames.count;
        for (int i=1; i <= numImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"cloakmanjump%d", i];
            SKTexture *tex = [runningAtlas textureNamed:textureName];
            tex.filteringMode = SKTextureFilteringNearest;
            [_jumpingFrames addObject:tex];
        }
        [SKTexture preloadTextures:_jumpingFrames withCompletionHandler:^{}];

    }
    
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static AnimationComponent* sharedSingleton = nil;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[AnimationComponent alloc] initAnimationDictionary];
    });
    return sharedSingleton;
}

@end


