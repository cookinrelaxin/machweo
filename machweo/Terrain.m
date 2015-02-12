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

@implementation Terrain{
    CGVector vertexOffset;
    CGRect pathBoundingBox;
    NSMutableArray* decos;
    Constants* constants;
    CGSize sceneSize;
    
    //int backgroundYOffset;
}

-(instancetype)initWithTexture:(SKTexture*)texture forSceneSize:(CGSize)size{
    if (self = [super init]) {
        sceneSize = size;
        _terrainTexture = texture;
        decos = [NSMutableArray array];
        constants = [Constants sharedInstance];
        
        
    }
    return self;
}

//-(void)updateLastNSprites:(SKSpriteNode*)newest{
//    if (lastNSprites.count >= LAST_N_SPRITES_N) {
//        [lastNSprites removeObjectAtIndex:0];
//    }
//    [lastNSprites addObject:newest];
//}

-(void)correctSpriteZsBeforeVertex:(CGPoint)vertex againstSlope:(BOOL)againstSlope{
    for (SKSpriteNode* deco in decos) {
        
        //float x_max = size.width;
        float x_min = 0;
        // float x_d_i = deco.position.x;
        float x_d_i = [deco.parent.parent convertPoint:deco.position fromNode:deco.parent].x;
        float x_t_i = vertex.x;
        
        if (againstSlope){
            if  (x_d_i >= x_t_i){
                //NSLog(@"(x_d_i >= x_t_i)");
                continue;
            }
            
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
               // NSLog(@"v_t: %f", v_t);
                //NSLog(@"max_v_d: %f", max_v_d);
                //NSLog(@"v_d_now: %f", v_d_now);
                float newZ = (max_v_d * z_t) / v_t;
                if (againstSlope) {
                     //NSLog(@"z_d: %f", z_d);
                     //NSLog(@"newZ: %f", newZ);

                }
                deco.zPosition = newZ;
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
    if (_cropNode) {
        [_cropNode removeFromParent];
    }
    SKShapeNode* textureShapeNode = [self shapeNodeWithVertices:_vertices];
    SKTexture* texFromShapeNode = [view textureFromNode:textureShapeNode];
    SKSpriteNode* maskWrapper = [SKSpriteNode spriteNodeWithTexture:texFromShapeNode];
    _cropNode = [SKCropNode node];
    SKTexture* croppedTexture = [SKTexture textureWithRect:CGRectMake(0, 0, maskWrapper.size.width / _terrainTexture.size.width, maskWrapper.size.height / _terrainTexture.size.height) inTexture:_terrainTexture];
    
    SKSpriteNode* pattern = [[SKSpriteNode alloc] initWithTexture:croppedTexture];
    pattern.name = @"pattern";
    
    [_cropNode addChild:pattern];
    
    pattern.position = CGPointMake(CGRectGetMidX(pathBoundingBox) + vertexOffset.dx, CGRectGetMidY(pathBoundingBox) + vertexOffset.dy);
    maskWrapper.position = CGPointMake(CGRectGetMidX(pathBoundingBox) + vertexOffset.dx, CGRectGetMidY(pathBoundingBox) + vertexOffset.dy);
    _cropNode.maskNode = maskWrapper;
    
    [self addChild:_cropNode];
}

-(SKShapeNode*)shapeNodeWithVertices:(NSArray*)vertexArray{
    
    SKShapeNode* node = [SKShapeNode node];
    node.position = CGPointZero;
    //node.zPosition = self.zPosition;
    node.fillColor = [UIColor whiteColor];
    node.antialiased = false;
    node.physicsBody = nil;
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    node.lineWidth = 1;
    
    CGPoint firstVertex = [(NSValue*)[vertexArray firstObject] CGPointValue];
    vertexOffset = CGVectorMake(firstVertex.x, firstVertex.y);
    CGPathMoveToPoint(pathToDraw, NULL, 0, 0);
    
    for (NSValue* value in vertexArray) {
        CGPoint vertex = [value CGPointValue];
        if (CGPointEqualToPoint(vertex, firstVertex)) {
            continue;
        }
        //NSLog(@"vertex: %f, %f", vertex.x, vertex.y);
        CGPathAddLineToPoint(pathToDraw, NULL, vertex.x - vertexOffset.dx, vertex.y - vertexOffset.dy);
        
        if (value == vertexArray.lastObject) {
            //CGPoint rightLipVertex = CGPointMake(vertex.x + 50, vertex.y - vertexOffset.dy);
            CGPoint bottomRightAreaVertex = CGPointMake(vertex.x + 100, 0);
            CGPoint bottomLeftAreaVertex = CGPointMake(firstVertex.x - 100, 0);
            CGPoint upperLeftAreaVertex = firstVertex;
            //CGPathAddLineToPoint(pathToDraw, NULL, rightLipVertex.x - vertexOffset.dx, rightLipVertex.y - vertexOffset.dy);
            CGPathAddLineToPoint(pathToDraw, NULL, bottomRightAreaVertex.x - vertexOffset.dx, bottomRightAreaVertex.y - vertexOffset.dy);
            CGPathAddLineToPoint(pathToDraw, NULL, bottomLeftAreaVertex.x - vertexOffset.dx, bottomLeftAreaVertex.y - vertexOffset.dy);
            CGPathAddLineToPoint(pathToDraw, NULL, upperLeftAreaVertex.x - vertexOffset.dx, upperLeftAreaVertex.y - vertexOffset.dy);
            break;
        }
    }
    node.path = pathToDraw;
    pathBoundingBox = CGPathGetPathBoundingBox(pathToDraw);
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
                //CGRect nodeFrame = node.calculateAccumulatedFrame;
                //NSLog(@"nodeFrame: %f, %f", nodeFrame.size.width, nodeFrame.size.height);
           //     NSLog(@"slope: %f", slope);
                int zPositionDie = 0;
//                if (slope < -1) {
//                    zPositionDie = 0;
//                }
//                else if (slope < 1) {
//                    zPositionDie = arc4random_uniform(10);
//                }
//                else if (slope < 2) {
//                    zPositionDie = arc4random_uniform(16);
//                }
//                else if (slope < 3) {
//                    zPositionDie = arc4random_uniform(22);
//                }
//                else{
//                    zPositionDie = arc4random_uniform(20);
//                }
//                else if (slope > 2) {
//                    return;
//                }
                zPositionDie = arc4random_uniform(20);

//                if (slope < -.1) {
//                    [self correctSpriteZsBeforeVertex:v againstSlope:YES];
//                    return;
//                }
//                else{
//                    if (slope < -.5) {
//                        // this size is magic and temporary. fix sometime
//                        [self correctSpriteZsBeforeVertex:v againstSlope:YES];
//                    }
//                    return;
//                }
                
                sprite.zPosition = constants.FOREGROUND_Z_POSITION - zPositionDie;
                sprite.zPosition = self.zPosition - 1 - zPositionDie;

            }
            else{
                sprite.zPosition = zPos;
            }
            //sprite.zPosition = constants.FOREGROUND_Z_POSITION - 1;
            //NSLog(@"zPos: %f", zPos);
            float differenceInZs = (constants.FOREGROUND_Z_POSITION - sprite.zPosition) * .1f;
            if (differenceInZs > 1){
    //                NSLog(@"differenceInZs: %i", differenceInZs);
                sprite.size = CGSizeMake(sprite.size.width * (1 / differenceInZs), sprite.size.height * (1 / differenceInZs));
              //  NSLog(@"sprite.size: %f, %f", sprite.size.width, sprite.size.height);
            }
         //   NSLog(@"differenceInZs: %f", differenceInZs);

            
            sprite.position = [node convertPoint:v fromNode:self.parent.parent];
            float z_d = sprite.zPosition;
            float h_s = sprite.size.height;
            float z_t = self.zPosition;
            int height_die_d = arc4random_uniform((z_d * h_s) / (8 * z_t));
            sprite.position = CGPointMake(sprite.position.x, sprite.position.y + height_die_d);
            //sprite.position = CGPointMake(sprite.position.x, sprite.position.y + (sprite.size.height / 2));
            
            //double rotationDie = drand48();
            
            //int signDie = arc4random_uniform(2);
            //float rotation = (signDie == 0) ? (M_PI_4 / 2 * rotationDie) : -(M_PI_4 / 2 * rotationDie);
            
            //float rotation = -(M_PI_4 / 2 * rotationDie);
            //sprite.zRotation = rotation;
            
           // sprite.zRotation = M_PI_4 * slope;


           // sprite.name = @"terrain deco";
            [node addChild:sprite];
            [decos addObject:sprite];
            
            if (slope < -1) {
                [self correctSpriteZsBeforeVertex:v againstSlope:YES];
               // return;
            }

            
            }
    }
}

@end
