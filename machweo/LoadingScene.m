//
//  LoadingScene.m
//  tgrrn
//
//  Created by John Feldcamp on 1/4/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "LoadingScene.h"

@implementation LoadingScene{
    SKLabelNode* loadingLabel;
}

-(instancetype)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]){
        Constants *constants = [Constants sharedInstance];
        loadingLabel = [SKLabelNode labelNodeWithText:@"GET PSYCHED!"];
        loadingLabel.fontColor = constants.LOADING_LABEL_FONT_COLOR;
        loadingLabel.fontSize = constants.LOADING_LABEL_FONT_SIZE * constants.SCALE_COEFFICIENT.dy;
        loadingLabel.fontName = constants.LOADING_LABEL_FONT_NAME;
        loadingLabel.zPosition = 10;
        loadingLabel.position = CGPointMake(CGRectGetMidX(self.frame) * constants.SCALE_COEFFICIENT.dx, CGRectGetMidY(self.frame) * constants.SCALE_COEFFICIENT.dy);
    
        [self addChild:loadingLabel];
    }
    return self;
}

-(void)update:(NSTimeInterval)currentTime{
}


@end
