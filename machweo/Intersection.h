//
//  Intersection.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/2/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Intersection : NSObject
@property (nonatomic) CGPoint point;
@property (nonatomic) float slope;
+(Intersection*)intersectionWithPoint:(CGPoint)point andSlope:(float)slope;

@end
