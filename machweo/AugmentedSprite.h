//
//  AugmentedSprite.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 3/17/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface AugmentedSprite : SKSpriteNode
@property (nonatomic, strong) NSString* uniqueID;
@property (nonatomic) CGPoint rawPosition;
@end
