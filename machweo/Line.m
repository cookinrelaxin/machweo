//
//  Line.m
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 12/1/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "Line.h"

@implementation Line

-(instancetype)initWithTerrainNode:(SKNode*)node{
    _nodeArray = [NSMutableArray array];
    _shouldDraw = true;
    _allowIntersections = false;
    _terrain = [[Terrain alloc] initWithTexture:[SKTexture textureWithImageNamed:@"african_textile_3_terrain"]];
    _terrain.lineVertices = self.nodeArray;
    [node addChild:_terrain];
    
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
