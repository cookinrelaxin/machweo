//
//  Line.m
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 12/1/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "Line.h"
#import "Constants.h"



@implementation Line{
    SKShapeNode* intersectingLinesNode;
}

-(instancetype)initWithTerrainNode:(SKNode*)node :(CGPoint)origin{
    _origin = origin;
    _nodeArray = [NSMutableArray array];
    _terrainArray = [NSMutableArray array];
    _shouldDraw = true;
    _allowIntersections = false;
    //_foreground = [[Terrain alloc] initWithTexture:[SKTexture textureWithImageNamed:@"african_textile_3_terrain"]];
    //_foreground.lineVertices = self.nodeArray;
   // [node addChild:_foreground];
    Constants* constants = [Constants sharedInstance];
    for (int i = 0; i < constants.TERRAIN_LAYER_COUNT; i ++) {
        
        NSString* textureName = @"filler";
        if (i == 0) {
//            textureName = @"african_textile_3_terrain";
            textureName = @"linequilt";
//            textureName = @"lotusquilt_decoration";


        }
        Terrain* ter = [[Terrain alloc] initWithTexture:[SKTexture textureWithImageNamed:textureName]];
        ter.vertices = [NSMutableArray array];
        ter.zPosition = constants.FOREGROUND_Z_POSITION - (constants.ZPOSITION_DIFFERENCE_PER_LAYER * i);
//        if (i > 0) {
//           ter.hidden = true;
//
//        }
        [_terrainArray addObject:ter];
        [node addChild:ter];
    }
    
    return self;
}

-(void)generateConnectingLinesInTerrainNode:(SKNode*)node withTerrainPool:(NSMutableArray*)terrainPool andDecoNode:(SKNode*)decorations :(BOOL)generateDecorations{
   // NSLog(@"node.children.count: %lu", (unsigned long)node.children.count);
    //[node enumerateChildNodesWithName:@"intersectingLines" usingBlock:^(SKNode *kiddo, BOOL *stop) {
   //     [kiddo removeFromParent];
  //  }];
    if (intersectingLinesNode) {
        //NSLog(@"removing intersecting lines");
        [intersectingLinesNode removeFromParent];
        //intersectingLinesNode = nil;
    }
    Terrain* firstTerrain = [_terrainArray objectAtIndex:0];
    Terrain* secondTerrain = [_terrainArray objectAtIndex:1];
    if (firstTerrain && secondTerrain) {
            
        

        NSArray* vertices1 = firstTerrain.vertices;
        NSArray* vertices2 = secondTerrain.vertices;
        
        
        intersectingLinesNode = [SKShapeNode node];
        intersectingLinesNode.name = @"intersectingLines";
    //    node.position = CGPointZero;
           // node.zPosition = constants.FOREGROUND_Z_POSITION;
    //    node.fillColor = [UIColor whiteColor];
        //intersectingLinesNode.fillTexture = secondTerrain.terrainTexture;
       // intersectingLinesNode.fillColor = [UIColor greenColor];
        intersectingLinesNode.antialiased = false;
        intersectingLinesNode.physicsBody = nil;
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        intersectingLinesNode.lineWidth = 1;
        
        CGPoint firstVertex = [(NSValue*)[vertices2 firstObject] CGPointValue];
        CGPathMoveToPoint(pathToDraw, NULL, firstVertex.x, firstVertex.y);
        if (vertices1.count >= 3) {
            for (int i = 0; i < (vertices1.count - 2); i ++ ) {
                //CGPoint v2_a = ((NSValue*)[vertices2 objectAtIndex:i]).CGPointValue;
                CGPoint v2_b = ((NSValue*)[vertices2 objectAtIndex:i + 1]).CGPointValue;
                CGPoint v2_c = ((NSValue*)[vertices2 objectAtIndex:i + 1 + 1]).CGPointValue;

                CGPoint v1_a = ((NSValue*)[vertices1 objectAtIndex:i]).CGPointValue;
                CGPoint v1_b = ((NSValue*)[vertices1 objectAtIndex:i + 1]).CGPointValue;
                if (generateDecorations) {
                    if (i >= (vertices1.count - 3)) {
                        float slope = (v1_a.y - v2_b.y) / (v1_a.x - v2_b.x);
                        //NSLog(@"slope: %f", slope);
                        [self findRandomPointAlongVertices :v1_b :CGPointMake(v2_b.x, v2_b.y) withZPosition1:firstTerrain.zPosition and2:secondTerrain.zPosition inTerrain:firstTerrain withTerrainPool:terrainPool inNode:decorations andSlope:slope];
                    }
                }
                


                CGPathAddLineToPoint(pathToDraw, NULL, v1_a.x, v1_a.y);
                CGPathAddLineToPoint(pathToDraw, NULL, v1_b.x, v1_b.y);
                CGPathAddLineToPoint(pathToDraw, NULL, v2_b.x, v2_b.y);
                CGPathAddLineToPoint(pathToDraw, NULL, v2_c.x, v2_c.y);
            }
        }
        
        intersectingLinesNode.path = pathToDraw;
        CGPathRelease(pathToDraw);
       // [firstTerrain addChild:intersectingLinesNode];
    }
    
}

-(void)findRandomPointAlongVertices:(CGPoint)v1 :(CGPoint)v2 withZPosition1:(float)z1 and2:(float)z2 inTerrain:(Terrain*)terrain withTerrainPool:(NSMutableArray*)terrainPool inNode:(SKNode*)node andSlope:(float)slope{
    //float m = (v2.y - v1.y) / (v2.x / v1.x);
//    float yDiff = v2.y - v1.y;
//    if (yDiff <= 0) {
//        return;
//    }
//    float xDiff = v2.x - v1.x;
//    int newYDiff = arc4random_uniform(yDiff);
//    int newXDiff = arc4random_uniform(xDiff);
//    
//    CGPoint newPoint = CGPointMake(v1.x + (float)newXDiff, v1.y + (float)newYDiff);
//    float zDiff = z2 - z1;
//    float zPositionScale = zDiff / yDiff;
//    float newZposition = z1 + (zPositionScale * (float)newYDiff);
    
    //NSLog(@"yDiff: %f", yDiff);
   // NSLog(@"z1: %f", z1);
   // NSLog(@"newYDiff: %f", (float)newYDiff);
   // NSLog(@"zPositionScale: %f", zPositionScale);
   // NSLog(@"newZposition: %f", newZposition);
    
    
   // [terrain generateDecorationAtVertex:newPoint fromTerrainPool:terrainPool inNode:node withZposition:newZposition andSlope:slope];
    
    
    //float newScale =
    

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
