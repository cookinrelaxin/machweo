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

-(instancetype)initWithWorld:(SKScene*)world withObstacles:(SKNode*)obstacles andDecorations:(SKNode*)decorations withinView:(SKView *)view andLines:(NSMutableArray*)lines withXOffset:(float)xOffset andTimeOfDay:(TimeOfDay)timeOfDay;

-(void)updateWithPlayerDistance:(NSUInteger)playerDistance andTimeOfDay:(TimeOfDay)timeOfDay;
-(NSMutableArray*)getTerrainPool;
-(void)restoreObstaclesToPool;





@end
