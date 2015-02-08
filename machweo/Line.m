//
//  Line.m
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 12/1/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "Line.h"
#import "Constants.h"

@implementation Line

-(instancetype)initWithTerrainNode:(SKNode*)node{
    _nodeArray = [NSMutableArray array];
    _terrainArray = [NSMutableArray array];
    _shouldDraw = true;
    _allowIntersections = false;
    //_foreground = [[Terrain alloc] initWithTexture:[SKTexture textureWithImageNamed:@"african_textile_3_terrain"]];
    //_foreground.lineVertices = self.nodeArray;
   // [node addChild:_foreground];
    Constants* constants = [Constants sharedInstance];
    for (int i = 0; i < constants.TERRAIN_LAYER_COUNT; i ++) {
        Terrain* ter = [[Terrain alloc] initWithTexture:[SKTexture textureWithImageNamed:@"african_textile_3_terrain"]];
        ter.vertices = [NSMutableArray array];
        ter.zPosition = constants.FOREGROUND_Z_POSITION - (constants.ZPOSITION_DIFFERENCE_PER_LAYER * i);
        [_terrainArray addObject:ter];
        [node addChild:ter];
    }
    
    return self;
}

//+(Line*)lineWithVertices:(NSMutableArray*)vertices{
//    Line* line = [[Line alloc] init];
//    line.belowPlayer = true;
//    line.nodeArray = vertices;
//    line.allowIntersections = true;
//    line.shouldDraw = false;
//    return line;
//}

//-(void)dealloc{
//  //  NSLog(@"dealloc line");
//    if (_terrain) {
//        if (_terrain.parent) {
//            [_terrain removeFromParent];
//            _terrain = nil;
//            
//        }
//    }
//}

@end
