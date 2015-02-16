//
//  TerrainSignifier.m
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 1/27/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "Terrain.h"
#import "Constants.h"

//int LAST_N_SPRITES_N = 5;
//float MINIMUM_FREEZE_DISTANCE = 100.0f;
int CLIFF_VERTEX_COUNT = 15;

@implementation Terrain{
    CGVector vertexOffset;
    CGRect pathBoundingBox;
    NSMutableArray* decos;
    Constants* constants;
    CGSize sceneSize;
    int lipOffset;
    NSMutableArray* beforeCliff;
    NSMutableArray* endCliff;
    BOOL beforeCliffAddedToVertices;
    
    SKShapeNode* textureShapeNode;
    
}

-(instancetype)initWithTexture:(SKTexture*)texture forSceneSize:(CGSize)size{
    if (self = [super init]) {
        sceneSize = size;
        _terrainTexture = texture;
        decos = [NSMutableArray array];
        constants = [Constants sharedInstance];
        lipOffset = arc4random_uniform(150) + 50;
        endCliff = [NSMutableArray array];
        beforeCliff = [NSMutableArray array];
        [self generateCliff:endCliff :YES];
        [self generateCliff:beforeCliff :NO];
        
    }
    return self;
}
-(void)generateCliff:(NSMutableArray*)cliffArray :(BOOL)forwardLip{
    for (int i = 0; i < CLIFF_VERTEX_COUNT; i ++) {
        int dx;
        if (forwardLip) {
            dx = arc4random_uniform(10);
        }
        else{
            dx = arc4random_uniform(5);

        }
        //int sign = (forwardLip == true) ? 1 :0;
        int sign = 0;
        
        if ((i > (CLIFF_VERTEX_COUNT / 2)) && forwardLip) {
            sign = arc4random_uniform(2);
        }
        if (!forwardLip) {
            sign = arc4random_uniform(2);
        }
        
        dx = (sign == 0) ? -dx : dx;
        //int dx = 0;
        int dy = 0;
        CGVector v = CGVectorMake(dx, dy);
        [cliffArray addObject:[NSValue valueWithCGVector:v]];
    }
    
}
-(void)correctSpriteZsBeforeVertex:(CGPoint)vertex againstSlope:(BOOL)againstSlope{
    for (SKSpriteNode* deco in decos) {
        if ([deco.name isEqualToString:@"corrected"]) {
            continue;
        }
        
        //float x_max = size.width;
        float x_min = -50;
        // float x_d_i = deco.position.x;
        float x_d_i = [deco.parent.parent convertPoint:deco.position fromNode:deco.parent].x + (deco.size.width / 2);
        float x_t_i = vertex.x;
        
        if (againstSlope){
           // if  (x_d_i > x_t_i){
                //NSLog(@"deco: %@", deco);
                //NSLog(@"(x_d_i >= x_t_i)");
               // continue;
           // }
            
//            float d_bottom_x_ish = x_d_i - (deco.size.height / 2);
//            if (!(d_bottom_x_ish >= vertex.y)) {
//                continue;
//            }
//            NSLog(@"correct!");
        }
            
            // should this be negative?
            float v_t = -constants.MAX_PLAYER_VELOCITY_DX;
            
            float t = (x_min - x_t_i) / v_t;
            float max_v_d = (x_min - x_d_i) / t;
            
            float z_d = deco.zPosition;
            float z_t = self.zPosition;
            
            float c = z_d / z_t;
            float v_d_now = c * v_t;
            if (v_d_now > max_v_d) {
                //NSLog(@"deco: %@", deco);
               // NSLog(@"v_t: %f", v_t);
                //NSLog(@"max_v_d: %f", max_v_d);
                //NSLog(@"v_d_now: %f", v_d_now);
                float newZ = (max_v_d * z_t) / v_t;
                if (againstSlope) {
                     //NSLog(@"z_d: %f", z_d);
                     //NSLog(@"newZ: %f", newZ);

                }
                
                deco.zPosition = newZ;
                deco.name = @"corrected";
                if (deco.zPosition >= z_t) {
                    deco.zPosition = z_t - 1;
                }
                //deco.zPosition = z_t - 1;

                
            }
           // else{
            //    NSLog(@"max_v_d: %f", max_v_d);
            //    NSLog(@"v_d_now: %f", v_d_now);
           // }
        
    }
}

//-(void)removeLastSprite{
//    SKSpriteNode* last = [lastNSprites lastObject];
//    [last removeFromParent];
//    [lastNSprites removeObject:last];
//}

-(void)closeLoopAndFillTerrainInView:(SKView*)view{
//    [self generateBackground:view];
    [self generate:view];
    
    _isClosed = false;
    //   _permitVertices = false;
    
}

-(void)changeDecorationPermissions:(CGPoint)currentPoint{
    CGPoint firstVertex = [(NSValue*)[_vertices firstObject] CGPointValue];
    double distance = ({double d1 = currentPoint.x - firstVertex.x, d2 = currentPoint.y - firstVertex.y; sqrt(d1 * d1 + d2 * d2); });
    if(distance > 100){
        _permitDecorations = true;
    }
    
}

-(void)generate:(SKView*)view{
//    if (_cropNode) {
//        [_cropNode removeFromParent];
//    }
//    SKShapeNode* textureShapeNode = [self shapeNodeWithVertices:_vertices];
//    //textureShapeNode.fi
//   // textureShapeNode.antialiased = false;
//    SKTexture* texFromShapeNode = [view textureFromNode:textureShapeNode];
//    SKSpriteNode* maskWrapper = [SKSpriteNode spriteNodeWithTexture:texFromShapeNode];
//    _cropNode = [SKCropNode node];
//    SKTexture* croppedTexture = [SKTexture textureWithRect:CGRectMake(0, 0, maskWrapper.size.width / _terrainTexture.size.width, maskWrapper.size.height / _terrainTexture.size.height) inTexture:_terrainTexture];
//    
//    SKSpriteNode* pattern = [[SKSpriteNode alloc] initWithTexture:croppedTexture];
//    pattern.name = @"pattern";
//    
//    [_cropNode addChild:pattern];
//    
//    pattern.position = CGPointMake(CGRectGetMidX(pathBoundingBox) + vertexOffset.dx, CGRectGetMidY(pathBoundingBox) + vertexOffset.dy);
//    maskWrapper.position = CGPointMake(CGRectGetMidX(pathBoundingBox) + vertexOffset.dx, CGRectGetMidY(pathBoundingBox) + vertexOffset.dy);
//    _cropNode.maskNode = maskWrapper;
//    
//    [self addChild:_cropNode];
    
    if (textureShapeNode) {
        [textureShapeNode removeFromParent];
    }
    textureShapeNode = [self shapeNodeWithVertices:_vertices];
    [self addChild:textureShapeNode];
    //NSLog(@"self.children.count: %lu", (unsigned long)self.children.count);
    //NSLog(@"textureShapeNode.position: %f, %f", textureShapeNode.position.x, textureShapeNode.position.y);
    

}

-(SKShapeNode*)shapeNodeWithVertices:(NSMutableArray*)vertexArray{
    
    SKShapeNode* node = [SKShapeNode node];
    node.position = CGPointZero;
    //node.zPosition = self.zPosition;
    node.fillColor = [UIColor whiteColor];
    textureShapeNode.fillTexture = _terrainTexture;
    node.antialiased = false;
    node.strokeColor = nil;
    node.physicsBody = nil;
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    //node.lineWidth = 1;
    
    if (!beforeCliffAddedToVertices) {
        CGPoint firstVertex = [(NSValue*)[vertexArray firstObject] CGPointValue];
        [vertexArray removeObject:[vertexArray firstObject]];
        
        int x = firstVertex.x;
        int y = 0;
        float yDiff = firstVertex.y;
        int yInterval = yDiff / CLIFF_VERTEX_COUNT;
        for (NSValue* val in beforeCliff) {
            CGVector vec = [val CGVectorValue];
            
            [vertexArray addObject:[NSValue valueWithCGPoint:CGPointMake(x + vec.dx, y + yInterval)]];
            //CGPathAddLineToPoint(pathToDraw, NULL, x + vec.dx, y - yInterval);
            x += vec.dx;
            y += yInterval;
        }
        [vertexArray addObject:[NSValue valueWithCGPoint:firstVertex]];

        beforeCliffAddedToVertices = true;
    }
    
    CGPoint firstVertex = [(NSValue*)[vertexArray firstObject] CGPointValue];
    //vertexOffset = CGVectorMake(firstVertex.x, firstVertex.y);
    vertexOffset = CGVectorMake(0, 0);
    CGPathMoveToPoint(pathToDraw, NULL, 0, 0);
    
    for (NSValue* value in vertexArray) {
        CGPoint vertex = [value CGPointValue];
        if (CGPointEqualToPoint(vertex, firstVertex)) {
            continue;
        }
        //NSLog(@"vertex: %f, %f", vertex.x, vertex.y);
        CGPathAddLineToPoint(pathToDraw, NULL, vertex.x - vertexOffset.dx, vertex.y - vertexOffset.dy);
        
        if (value == vertexArray.lastObject) {
            int x = vertex.x - vertexOffset.dx;
            int y = vertex.y - vertexOffset.dy;
            float yDiff = vertex.y;
            int yInterval = yDiff / CLIFF_VERTEX_COUNT;
            for (NSValue* val in endCliff) {
                CGVector vec = [val CGVectorValue];
                CGPathAddLineToPoint(pathToDraw, NULL, x + vec.dx, y - yInterval);
                x += vec.dx;
                y -= yInterval;
            }
            CGPoint bottomRightAreaVertex = CGPointMake(x, 0);
            CGPoint bottomLeftAreaVertex = CGPointMake(firstVertex.x - 100, 0);
            CGPoint upperLeftAreaVertex = firstVertex;
            CGPathAddLineToPoint(pathToDraw, NULL, bottomRightAreaVertex.x, bottomRightAreaVertex.y - vertexOffset.dy);
            CGPathAddLineToPoint(pathToDraw, NULL, bottomLeftAreaVertex.x - vertexOffset.dx, bottomLeftAreaVertex.y - vertexOffset.dy);
            CGPathAddLineToPoint(pathToDraw, NULL, upperLeftAreaVertex.x - vertexOffset.dx, upperLeftAreaVertex.y - vertexOffset.dy);
            
            break;
        }
    }
    node.path = pathToDraw;
    //pathBoundingBox = CGPathGetPathBoundingBox(pathToDraw);
    CGPathRelease(pathToDraw);
    return node;
}


-(void)dealloc{
//    NSLog(@"dealloc terrain");
}

-(void)generateDecorationAtVertex:(CGPoint)v fromTerrainPool:(NSMutableArray*)terrainPool inNode:(SKNode*)node withZposition:(float)zPos andSlope:(float)slope{
    if(_permitDecorations){
    
        int probability1 = constants.TERRAIN_VERTEX_DECORATION_CHANCE_DENOM;
        int castedDie1 = arc4random_uniform(probability1 + 1);
        if (castedDie1 == probability1){
           // NSLog(@"(castedDie1 == probability1)");
            int castedDie2 = arc4random_uniform((int)terrainPool.count);
            //    NSLog(@"castedDie2: %i", castedDie2);
            SKTexture* tex = [terrainPool objectAtIndex:castedDie2];
            SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:tex];
            sprite.size = CGSizeMake(sprite.size.width * constants.SCALE_COEFFICIENT.dy, sprite.size.height * constants.SCALE_COEFFICIENT.dy);
            if (zPos == 0) {
                int zPositionDie = arc4random_uniform(30);
                sprite.zPosition = self.zPosition - 1 - zPositionDie;

            }
            else{
                sprite.zPosition = zPos;
            }
            //sprite.zPosition = constants.FOREGROUND_Z_POSITION - 1;
            //NSLog(@"zPos: %f", zPos);
            float differenceInZs = (self.zPosition - sprite.zPosition) * .05f;
            if (differenceInZs > 1){
    //                NSLog(@"differenceInZs: %i", differenceInZs);
                sprite.size = CGSizeMake(sprite.size.width * (1 / differenceInZs), sprite.size.height * (1 / differenceInZs));
              //  NSLog(@"sprite.size: %f, %f", sprite.size.width, sprite.size.height);
            }
         //   NSLog(@"differenceInZs: %f", differenceInZs);

            
            sprite.position = [node convertPoint:v fromNode:self.parent.parent];
            //float z_d = sprite.zPosition;
            float h_s = sprite.size.height;
            //float z_t = self.zPosition;
           // int height_die_d = arc4random_uniform((z_d * h_s) / (4 * z_t));
            int height_die_d = arc4random_uniform(h_s / 5);
            sprite.position = CGPointMake(sprite.position.x, sprite.position.y + height_die_d);
            
            [node addChild:sprite];
            [decos addObject:sprite];
            
            if (slope < -1.5) {
                [self correctSpriteZsBeforeVertex:v againstSlope:YES];
                return;
            }

            
        }
    }
}

@end
