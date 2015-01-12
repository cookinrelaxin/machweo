//
//  Brush.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 1/11/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Brush : NSObject
@property (nonatomic, strong) NSArray* colors;
@property (nonatomic) float lineThickness;
@property (nonatomic) float spaceBetweenLines;

+(Brush*)brushWithColors:(NSArray*)colors lineThickness:(float)thickness andLineSpacing:(float)spacing;
-(void)drawInScene:(SKScene*)scene forLines:(NSArray*)lines andShapeNodes:(NSMutableArray*)shapeNodes;
@end
