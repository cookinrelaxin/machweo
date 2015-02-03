//
//  Line.h
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 12/1/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Line : NSObject
@property (nonatomic) BOOL complete;
@property (nonatomic) BOOL belowPlayer;
@property (nonatomic) BOOL shouldDeallocNodeArray;
@property (nonatomic) BOOL shouldDraw;
@property (nonatomic) BOOL allowIntersections;
@property (nonatomic) CGRect AABB;

@property (nonatomic) float minX;
@property (nonatomic) float maxX;
@property (nonatomic) float minY;
@property (nonatomic) float maxY;

@property (nonatomic) NSMutableArray *subLines;

+(Line*)lineWithVertices:(NSMutableArray*)vertices;
@end
