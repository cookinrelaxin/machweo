//
//  TerrainSignifier.m
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 1/27/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "Terrain.h"
#import "Constants.h"

int LAST_N_SPRITES_N = 1;

@implementation Terrain{
    CGVector vertexOffset;
    CGRect pathBoundingBox;
    NSMutableArray* lastNSprites;
    
    //int backgroundYOffset;
}

-(instancetype)initWithTexture:(SKTexture*)texture{
    if (self = [super init]) {
        _terrainTexture = texture;
        lastNSprites = [NSMutableArray array];
        
        
    }
    return self;
}

-(void)updateLastNSprites:(SKSpriteNode*)newest{
    if (lastNSprites.count > LAST_N_SPRITES_N) {
        [lastNSprites removeObjectAtIndex:0];
    }
    [lastNSprites addObject:newest];
}

-(void)freezeLastNSprites{
    for (SKSpriteNode* sp in lastNSprites) {
        sp.zPosition = self.zPosition - 1;
    }
}

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
    
    Constants* constants = [Constants sharedInstance];
    int backgroundOffset = (constants.FOREGROUND_Z_POSITION - self.zPosition) * 5;
    
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
        CGPathAddLineToPoint(pathToDraw, NULL, vertex.x - vertexOffset.dx, vertex.y - vertexOffset.dy + backgroundOffset);
        
        if (value == vertexArray.lastObject) {
          //  CGPoint rightLipVertex = CGPointMake(vertex.x + 50 + backgroundOffset, vertex.y - 50);
            CGPoint bottomRightAreaVertex = CGPointMake(vertex.x + 100 + backgroundOffset, 0);
            CGPoint bottomLeftAreaVertex = CGPointMake(firstVertex.x - 100 - backgroundOffset, 0);
            CGPoint upperLeftAreaVertex = firstVertex;
           // CGPathAddLineToPoint(pathToDraw, NULL, rightLipVertex.x - vertexOffset.dx, rightLipVertex.y - vertexOffset.dy);
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

-(void)generateDecorationAtVertex:(CGPoint)v fromTerrainPool:(NSMutableArray*)terrainPool inNode:(SKNode*)node{
    if(_permitDecorations){
    
        Constants* constants = [Constants sharedInstance];
        int probability1 = constants.TERRAIN_VERTEX_DECORATION_CHANCE_DENOM;
        int castedDie1 = arc4random_uniform(probability1 + 1);
        if (castedDie1 == probability1){
           // NSLog(@"(castedDie1 == probability1)");
            int castedDie2 = arc4random_uniform((int)terrainPool.count);
            //    NSLog(@"castedDie2: %i", castedDie2);
            SKTexture* tex = [terrainPool objectAtIndex:castedDie2];
            SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:tex];
            sprite.size = CGSizeMake(sprite.size.width * constants.SCALE_COEFFICIENT.dy, sprite.size.height * constants.SCALE_COEFFICIENT.dy);
            
            int zPositionDie = arc4random_uniform(15);
           // sprite.zPosition = constants.FOREGROUND_Z_POSITION - zPositionDie;
            sprite.zPosition = self.zPosition - 1 - zPositionDie;
            
            float differenceInZs = (constants.FOREGROUND_Z_POSITION - sprite.zPosition) * .1f;
            if (differenceInZs > 1){
//                NSLog(@"differenceInZs: %i", differenceInZs);
                sprite.size = CGSizeMake(sprite.size.width * (1 / differenceInZs), sprite.size.height * (1 / differenceInZs));
              //  NSLog(@"sprite.size: %f, %f", sprite.size.width, sprite.size.height);
            }
         //   NSLog(@"differenceInZs: %f", differenceInZs);

            
            sprite.position = [node convertPoint:v fromNode:self.parent.parent];
            int heightDie = arc4random_uniform((sprite.size.height / 4));
            sprite.position = CGPointMake(sprite.position.x, sprite.position.y + heightDie);
            
           // int heightDie = arc4random_uniform((sprite.size.height / 3));
            double rotationDie = drand48();
            int signDie = arc4random_uniform(2);
            float rotation = (signDie == 0) ? (M_PI_4 / 2 * rotationDie) : -(M_PI_4 / 2 * rotationDie);
            sprite.zRotation = rotation;



            [node addChild:sprite];
            [self updateLastNSprites:sprite];
            
        }
    }
}

//-(void)decrementZposition{
//    self.zPosition -= 10;
//    
//}



@end
