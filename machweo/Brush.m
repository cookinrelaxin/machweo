//
//  Brush.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 1/11/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "Brush.h"
#import "Line.h"
#import "Constants.h"

@implementation Brush

+(Brush*)brushWithColors:(NSArray*)colors lineThickness:(float)thickness andLineSpacing:(float)spacing{
    Brush* brush = [[Brush alloc] init];
    brush.colors = colors;
    brush.lineThickness = thickness;
    brush.spaceBetweenLines = spacing;
    
    return brush;
}

-(void)drawInScene:(SKScene*)scene forLines:(NSArray*)lines andShapeNodes:(NSMutableArray*)shapeNodes{
    Constants* _constants = [Constants sharedInstance];
    //for (Line* line in lines) {
    for (int i = 0; i < lines.count; i ++) {
        Line* line = [lines objectAtIndex:i];
        for (int j = 0; j < _colors.count; j ++) {
        
            SKShapeNode* currentLineNode = [SKShapeNode node];
            currentLineNode.zPosition = _constants.LINE_Z_POSITION;
            //currentLineNode.zPosition = _constants.OBSTACLE_Z_POSITION;
            currentLineNode.strokeColor = [_colors objectAtIndex:j];
            currentLineNode.antialiased = false;
            currentLineNode.physicsBody = nil;
            currentLineNode.lineCap = kCGLineCapRound;
            currentLineNode.lineJoin = kCGLineJoinRound;
            CGMutablePathRef pathToDraw = CGPathCreateMutable();
            NSValue* firstPointNode = line.nodeArray.firstObject;
            CGPoint firstPointNodePosition = firstPointNode.CGPointValue;
            currentLineNode.lineWidth = _lineThickness;
            CGPathMoveToPoint(pathToDraw, NULL, firstPointNodePosition.x, firstPointNodePosition.y - (j * _spaceBetweenLines));
            for (NSValue* pointNode in line.nodeArray) {
                CGPoint pointNodePosition = pointNode.CGPointValue;
                CGPathAddLineToPoint(pathToDraw, NULL, pointNodePosition.x, pointNodePosition.y - (j * _spaceBetweenLines));
            }
            currentLineNode.path = pathToDraw;
            [shapeNodes addObject:currentLineNode];
            [scene addChild:currentLineNode];
            CGPathRelease(pathToDraw);

        }
        
//        if (useOutline) {
//            
//            SKShapeNode* outlineNode = [SKShapeNode node];
//            outlineNode.zPosition = currentLineNode.zPosition - 1;
//            outlineNode.strokeColor = [UIColor blackColor];
//            outlineNode.antialiased = false;
//            outlineNode.physicsBody = nil;
//            outlineNode.lineCap = kCGLineCapRound;
//            outlineNode.lineWidth = thickness - 5;
//            CGPathRef thickPathToDraw = CGPathCreateCopyByStrokingPath(pathToDraw, NULL, thickness, currentLineNode.lineCap, currentLineNode.lineJoin, currentLineNode.miterLimit);
//            outlineNode.path = thickPathToDraw;
//            [shapeNodes addObject:outlineNode];
//            [self addChild:outlineNode];
//            CGPathRelease(thickPathToDraw);
//        }
        
        
    }
    
}

@end
