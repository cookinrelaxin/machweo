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
            [_runningFrames addObject:tex];
        }
    }
    {
        _jumpingFrames = [[NSMutableArray alloc] init];
        SKTextureAtlas *runningAtlas = [SKTextureAtlas atlasNamed:@"jumpingDude"];
        NSUInteger numImages = runningAtlas.textureNames.count;
        for (int i=1; i <= numImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"cloakmanjump%d", i];
            SKTexture *tex = [runningAtlas textureNamed:textureName];
            [_jumpingFrames addObject:tex];
        }
    }
    
    return self;
}

@end


