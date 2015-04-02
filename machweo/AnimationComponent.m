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
    if (self = [super init]) {
        _runningFrames = [[NSMutableArray alloc] init];
        _jumpingFrames = [[NSMutableArray alloc] init];
        _midairFrames = [[NSMutableArray alloc] init];
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"runningDude"];
        NSUInteger numImages = atlas.textureNames.count;
        for (int i=1; i <= numImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"cloakman%d", i];
            SKTexture *tex = [atlas textureNamed:textureName];
            tex.filteringMode = SKTextureFilteringNearest;
            if (i <= 13) {
                [_runningFrames addObject:tex];
                continue;
            }
            else if (i <= 18) {
                [_jumpingFrames addObject:tex];
                continue;
            }
            else {
                [_midairFrames addObject:tex];
                continue;
            }
        }
        [SKTexture preloadTextures:_runningFrames withCompletionHandler:^{}];
        [SKTexture preloadTextures:_jumpingFrames withCompletionHandler:^{}];
        [SKTexture preloadTextures:_midairFrames withCompletionHandler:^{}];
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


