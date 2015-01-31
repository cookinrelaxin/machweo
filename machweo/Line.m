//
//  Line.m
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 12/1/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "Line.h"

@implementation Line

-(instancetype)init{
    _nodeArray = [NSMutableArray array];
    _shouldDraw = true;
    _allowIntersections = false;
    return self;
}

+(Line*)lineWithVertices:(NSMutableArray*)vertices{
    Line* line = [[Line alloc] init];
    line.belowPlayer = true;
    line.nodeArray = vertices;
    line.allowIntersections = true;
    line.shouldDraw = false;
    return line;
}

@end
