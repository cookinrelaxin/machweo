//
//  Intersection.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/2/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "Intersection.h"

@implementation Intersection
+(Intersection*)intersectionWithPoint:(CGPoint)point andSlope:(float)slope{
    Intersection* i = [[Intersection alloc] init];
    i.point = point;
    i.slope = slope;
    return i;
    
    
}

@end
