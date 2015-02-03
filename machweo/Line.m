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
    _subLines = [NSMutableArray array];
    _shouldDraw = true;
    _allowIntersections = false;
    _minX = FLT_MAX;
    _maxX = -FLT_MAX;
    _minY = FLT_MAX;
    _maxY = -FLT_MAX;
    
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

-(void)updateMinimaEtMaximaWithPoint:(CGPoint)point{
    if (point.x < _minX) {
        _minX = point.x;
    }
    if (point.x > _maxX) {
        _maxX = point.x;
    }
    if (point.y < _minY) {
        _minY = point.y;
    }
    if (point.y > _maxY) {
        _maxY = point.y;
    }
    [self updateAABB];
}

-(void)updateAABB{
    _AABB = CGRectMake(_minX, _minY, _maxX - _minX, _maxY - _minY);
}

-(void)adjustMinimaEtMaximaByDifference:(CGVector)difference{
    _minX -= difference.dx;
    _maxX -= difference.dx;
    _minY -= difference.dy;
    _maxY -= difference.dy;
    [self updateAABB];

}


@end
