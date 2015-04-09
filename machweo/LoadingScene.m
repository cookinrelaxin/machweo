//
//  LoadingScene.m
//  tgrrn
//
//  Created by John Feldcamp on 1/4/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "LoadingScene.h"
#import "AnimationComponent.h"
#import <CoreText/CoreText.h>

@implementation LoadingScene{
    Constants* constants;
    SKSpriteNode* lightning;
    SKSpriteNode* logo;
}

-(instancetype)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]){
        constants = [Constants sharedInstance];
        self.backgroundColor = constants.LOADING_SCREEN_BACKGROUND_COLOR;
        logo = [SKSpriteNode spriteNodeWithImageNamed:@"logo"];
        logo.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        logo.size = CGSizeMake(logo.size.width * constants.SCALE_COEFFICIENT.dx, logo.size.height * constants.SCALE_COEFFICIENT.dx);
        [self addChild:logo];
        
        lightning = [SKSpriteNode spriteNodeWithImageNamed:@"lightningbolt1"];
        lightning.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height / 4);
        lightning.size = CGSizeMake(lightning.size.width * constants.SCALE_COEFFICIENT.dx * .5, lightning.size.height * constants.SCALE_COEFFICIENT.dx * .5);
        [self addChild:lightning];
        
        NSMutableArray* lightningFrames = [[NSMutableArray alloc] init];
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"lightning"];
        NSUInteger numImages = atlas.textureNames.count;
        for (int i=1; i <= numImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"lightningbolt%d", i];
            SKTexture *tex = [atlas textureNamed:textureName];
            tex.filteringMode = SKTextureFilteringNearest;
            [lightningFrames addObject:tex];
        }
        [lightning runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:lightningFrames timePerFrame:.05]]];

    }
    return self;
}
-(void)update:(NSTimeInterval)currentTime{
}

@end
