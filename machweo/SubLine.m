//
//  SubLine.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/2/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "SubLine.h"

@implementation SubLine
-(instancetype)init{
    if (self = [super init]) {
        _vertices = [NSMutableArray array];
        _minX = FLT_MAX;
        _maxX = -FLT_MAX;
        _minY = FLT_MAX;
        _maxY = -FLT_MAX;
    }
    return self;
}

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
    //NSLog(@"_AABB: %f, %f, %f, %f", _AABB.origin.x, _AABB.origin.y, _AABB.size.width, _AABB.size.height);

}

-(void)adjustMinimaEtMaximaByDifference:(CGVector)difference{
    _minX -= difference.dx;
    _maxX -= difference.dx;
    _minY -= difference.dy;
    _maxY -= difference.dy;
    [self updateAABB];
    
}
@end
