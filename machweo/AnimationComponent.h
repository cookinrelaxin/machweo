//
//  AnimationComponent.h
//  ChunkADT
//
//  Created by John Feldcamp on 7/11/14.
//  Copyright (c) 2014 Zachary Feldcamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>


@interface AnimationComponent : NSObject

@property (nonatomic) NSMutableArray* runningFrames;
@property (nonatomic) NSMutableArray* jumpingFrames;
@property (nonatomic) NSMutableArray* midairFrames;
@property (nonatomic) NSRange run;
@property (nonatomic) NSRange jump;
@property (nonatomic) NSRange land;
@property (nonatomic) NSRange previousFrameRange;
@property (nonatomic) NSRange currentFrameRange;

+ (instancetype)sharedInstance;

@end
