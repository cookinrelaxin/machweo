//
//  TerrainSignifier.m
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 1/27/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "Terrain.h"
#import "Decoration.h"

int CLIFF_VERTEX_COUNT = 15;

@implementation Terrain{
    CGVector vertexOffset;
    CGRect pathBoundingBox;
    Constants* constants;
    NSMutableArray* beforeCliff;
    NSMutableArray* endCliff;
    BOOL beforeCliffAddedToVertices;
    float terrainAlpha;
    float previousSunY;
    CGSize sceneSize;
    NSMutableArray* terrainPool;
}

-(instancetype)initWithSceneSize:(CGSize)size{
    if (self = [super init]) {
        sceneSize = size;
        _decos = [NSMutableArray array];
        _vertices = [NSMutableArray array];
        constants = [Constants sharedInstance];
        endCliff = [NSMutableArray array];
        beforeCliff = [NSMutableArray array];
        [self generateCliff:endCliff :YES];
        [self generateCliff:beforeCliff :NO];
        self.physicsBody = nil;
        terrainPool = [constants TERRAIN_ARRAY];
        self.zPosition = constants.FOREGROUND_Z_POSITION;
    }
    return self;
}
-(void)generateCliff:(NSMutableArray*)cliffArray :(BOOL)forwardLip{
    for (int i = 0; i < CLIFF_VERTEX_COUNT; i ++) {
        int dx;
        if (forwardLip) {
            dx = arc4random_uniform(20);
        }
        else{
            dx = arc4random_uniform(10);

        }
        int sign = 1;
        if (!forwardLip) {
            sign = arc4random_uniform(2);
        }
        dx = (sign == 0) ? -dx : dx;
        int dy = 0;
        CGVector v = CGVectorMake(dx, dy);
        [cliffArray addObject:[NSValue valueWithCGVector:v]];
    }
}
-(void)correctSpriteZsBeforeVertex:(CGPoint)vertex againstSlope:(BOOL)againstSlope{
    for (Decoration* deco in _decos) {
        if ([deco.name isEqualToString:@"corrected"]) {
            continue;
        }
        float x_min = -50;
        float x_d_i = [deco.parent.parent convertPoint:deco.position fromNode:deco.parent].x + (deco.size.width / 2);
        float x_t_i = vertex.x;
        float v_t = -constants.MAX_PLAYER_VELOCITY_DX;
        float t = (x_min - x_t_i) / v_t;
        float max_v_d = (x_min - x_d_i) / t;
        float z_d = deco.zPosition;
        float z_t = self.zPosition;
        float c = z_d / z_t;
        float v_d_now = c * v_t;
        if (v_d_now > max_v_d) {
            float newZ = (max_v_d * z_t) / v_t;
            deco.zPosition = newZ;
            deco.name = @"corrected";
            if (deco.zPosition >= z_t) {
                deco.zPosition = z_t - 1;
            }
        }
    }
}

-(void)closeLoopAndFillTerrainInView:(SKView*)view withCurrentSunYPosition:(float)sunY minY:(float)minY andMaxY:(float)maxY{
    [self generate:view withCurrentSunYPosition:sunY minY:minY andMaxY:maxY];
    _isClosed = false;
}

-(void)changeDecorationPermissions:(CGPoint)currentPoint{
    CGPoint firstVertex = [(NSValue*)[_vertices firstObject] CGPointValue];
    double distance = ({double d1 = currentPoint.x - firstVertex.x, d2 = currentPoint.y - firstVertex.y; sqrt(d1 * d1 + d2 * d2); });
    if(distance > 100){
        _permitDecorations = true;
    }
}

-(void)generate:(SKView*)view withCurrentSunYPosition:(float)sunY minY:(float)minY andMaxY:(float)maxY{
    [self shapeNodeWithVertices:_vertices];
    _textureShapeNode.fillColor = [self findTimeSpecificTerrainColorWithCurrentSunYPosition:sunY minY:minY andMaxY:maxY];
    if (!_textureShapeNode.parent) {
        [self addChild:_textureShapeNode];
    }
}

-(SKColor*)findTimeSpecificTerrainColorWithCurrentSunYPosition:(float)sunY minY:(float)minY andMaxY:(float)maxY{
    terrainAlpha = .9;
    float brightness = sunY / maxY;
    float minB = .25;
    float maxB = .90f;
    brightness = (brightness < minB) ? minB : brightness;
    brightness = (brightness > maxB) ? maxB : brightness;

    float saturation = 1 - (sunY / maxY);
    float minSat = .25;
    saturation = (saturation < minSat) ? minSat : saturation;
    saturation = (saturation > 1) ? 1 : saturation;
    float hue = 35.0 / 360.0;
    SKColor* terCol = [SKColor colorWithHue:hue saturation:saturation brightness:brightness alpha:terrainAlpha];
    previousSunY = sunY;
    return terCol;
}

-(void)shapeNodeWithVertices:(NSMutableArray*)vertexArray{
    if (!_textureShapeNode) {
        _textureShapeNode = [SKShapeNode node];
    }
    SKShapeNode* node = _textureShapeNode;
    node.position = CGPointZero;
    node.antialiased = false;
    node.strokeColor = nil;
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
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
            x += vec.dx;
            y += yInterval;
        }
        [vertexArray addObject:[NSValue valueWithCGPoint:firstVertex]];
        beforeCliffAddedToVertices = true;
    }
    CGPoint firstVertex = [(NSValue*)[vertexArray firstObject] CGPointValue];
    vertexOffset = CGVectorMake(0, 0);
    CGPathMoveToPoint(pathToDraw, NULL, firstVertex.x, firstVertex.y);
    for (NSValue* value in vertexArray) {
        CGPoint vertex = [value CGPointValue];
        if (CGPointEqualToPoint(vertex, firstVertex)) {
            continue;
        }
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
            CGPoint bottomLeftAreaVertex = CGPointMake(firstVertex.x, 0);
            CGPoint upperLeftAreaVertex = firstVertex;
            CGPathAddLineToPoint(pathToDraw, NULL, bottomRightAreaVertex.x, bottomRightAreaVertex.y - vertexOffset.dy);
            CGPathAddLineToPoint(pathToDraw, NULL, bottomLeftAreaVertex.x - vertexOffset.dx, bottomLeftAreaVertex.y - vertexOffset.dy);
            CGPathAddLineToPoint(pathToDraw, NULL, upperLeftAreaVertex.x - vertexOffset.dx, upperLeftAreaVertex.y - vertexOffset.dy);
            break;
        }
    }
    node.path = pathToDraw;
    CGPathRelease(pathToDraw);
}


-(void)dealloc{
    for (Decoration* deco in _decos) {
        [deco removeFromParent];
    }
}

-(void)fadeOutAndDelete{
    for (Decoration *deco in _decos) {
        [deco runAction:[SKAction fadeAlphaTo:0 duration:.5] completion:^(void){
            [deco removeFromParent];
        }];
    }
    [self runAction:[SKAction fadeAlphaTo:0 duration:.5] completion:^(void){
        [self removeFromParent];
    }];
}

-(void)generateDecorationAtVertex:(CGPoint)v inNode:(SKNode*)node andSlope:(float)slope andCurrentBiome:(Biome)biome{
    if(_permitDecorations && (biome == savanna)){
        int probability1 = constants.TERRAIN_VERTEX_DECORATION_CHANCE_DENOM;
        int castedDie1 = arc4random_uniform(probability1 + 1);
        if (castedDie1 == probability1){
            int castedDie2 = arc4random_uniform((int)terrainPool.count);
            SKTexture* tex = [terrainPool objectAtIndex:castedDie2];
            Decoration* sprite = [Decoration spriteNodeWithTexture:tex];
            sprite.xScale = sprite.yScale = .5;
            sprite.physicsBody = nil;
            int zPositionDie = arc4random_uniform(30);
            sprite.zPosition = self.zPosition - 1 - zPositionDie;
            float differenceInZs = (self.zPosition - sprite.zPosition) * .1f;
            if (differenceInZs > 1){
                sprite.size = CGSizeMake(sprite.size.width * (1 / differenceInZs), sprite.size.height * (1 / differenceInZs));
            }
            sprite.position = [node convertPoint:v fromNode:self.parent.parent];
            float h_s = sprite.size.height;
            int height_die_d = arc4random_uniform(h_s / 5);
            sprite.position = CGPointMake(sprite.position.x, sprite.position.y + height_die_d);
            sprite.alpha = terrainAlpha;
            [node addChild:sprite];
            [_decos addObject:sprite];
            
            if (slope < -1.5) {
                [self correctSpriteZsBeforeVertex:v againstSlope:YES];
                return;
            }
        }
    }
    

}


@end
