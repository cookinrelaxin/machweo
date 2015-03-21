//
//  WorldStreamer.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/25/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "Constants.h"

@interface WorldStreamer : NSObject

-(instancetype)initWithScene:(SKScene*)scene withObstacles:(SKNode*)obstacles andDecorations:(SKNode*)decorations withinView:(SKView *)view andLines:(NSMutableArray*)lines withXOffset:(float)xOffset;

-(void)updateWithPlayerDistance:(NSUInteger)playerDistance;
-(NSMutableArray*)getTerrainPool;
-(void)reset;
-(void)enableObstacles;

@end
