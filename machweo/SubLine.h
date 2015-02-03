//
//  SubLine.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/2/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface SubLine : NSObject
@property (nonatomic) NSMutableArray *vertices;

@property (nonatomic) CGRect AABB;
@property (nonatomic) float minX;
@property (nonatomic) float maxX;
@property (nonatomic) float minY;
@property (nonatomic) float maxY;

@property (nonatomic) SKSpriteNode* visualBoundingBox;


-(void)updateMinimaEtMaximaWithPoint:(CGPoint)point;
-(void)adjustMinimaEtMaximaByDifference:(CGVector)difference;


@end
