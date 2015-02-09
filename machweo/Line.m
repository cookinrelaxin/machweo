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
            textureName = @"african_textile_3_terrain";
        }
        if (i == 1) {
            textureName = @"african_textile_2_terrain";
        }
        if (i == 2) {
            textureName = @"african_textile_5_terrain";
        }
        Terrain* ter = [[Terrain alloc] initWithTexture:[SKTexture textureWithImageNamed:textureName]];
        ter.vertices = [NSMutableArray array];
        ter.zPosition = constants.FOREGROUND_Z_POSITION - (constants.ZPOSITION_DIFFERENCE_PER_LAYER * i / 2);
    //    ter.hidden = true;
        [_terrainArray addObject:ter];
        [node addChild:ter];
    }
    
    return self;
}

-(void)generateConnectingLinesInNode:(SKNode*)node{
    NSLog(@"node.children.count: %lu", (unsigned long)node.children.count);
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
        
        
        Constants* constants = [Constants sharedInstance];
      //  Constants* constants = [Constants sharedInstance];
        int backgroundOffset = (constants.FOREGROUND_Z_POSITION - secondTerrain.zPosition) * 5;
        intersectingLinesNode = [SKShapeNode node];
        intersectingLinesNode.name = @"intersectingLines";
    //    node.position = CGPointZero;
           // node.zPosition = constants.FOREGROUND_Z_POSITION;
    //    node.fillColor = [UIColor whiteColor];
        intersectingLinesNode.antialiased = false;
        intersectingLinesNode.physicsBody = nil;
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        intersectingLinesNode.lineWidth = 1;
        
        CGPoint firstVertex = [(NSValue*)[vertices2 firstObject] CGPointValue];
        CGPathMoveToPoint(pathToDraw, NULL, firstVertex.x, firstVertex.y + backgroundOffset);
        if (vertices1.count >= 3) {
            for (int i = 0; i < (vertices1.count - 2); i ++ ) {
                //CGPoint v2_a = ((NSValue*)[vertices2 objectAtIndex:i]).CGPointValue;
                CGPoint v2_b = ((NSValue*)[vertices2 objectAtIndex:i + 1]).CGPointValue;
                CGPoint v2_c = ((NSValue*)[vertices2 objectAtIndex:i + 1 + 1]).CGPointValue;

                CGPoint v1_a = ((NSValue*)[vertices1 objectAtIndex:i]).CGPointValue;
                CGPoint v1_b = ((NSValue*)[vertices1 objectAtIndex:i + 1]).CGPointValue;


                CGPathAddLineToPoint(pathToDraw, NULL, v1_a.x, v1_a.y);
                CGPathAddLineToPoint(pathToDraw, NULL, v1_b.x, v1_b.y);
                CGPathAddLineToPoint(pathToDraw, NULL, v2_b.x, v2_b.y + backgroundOffset);
                CGPathAddLineToPoint(pathToDraw, NULL, v2_c.x, v2_c.y + backgroundOffset);
            }
        }
        
        intersectingLinesNode.path = pathToDraw;
        CGPathRelease(pathToDraw);
        [firstTerrain addChild:intersectingLinesNode];
     //   return node;
    }
    
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
