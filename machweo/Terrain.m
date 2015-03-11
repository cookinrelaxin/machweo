//
//  TerrainSignifier.m
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 1/27/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "Terrain.h"
#import "Constants.h"
#import "Decoration.h"

int CLIFF_VERTEX_COUNT = 15;

@implementation Terrain{
    CGVector vertexOffset;
    CGRect pathBoundingBox;
    Constants* constants;
    //CGSize sceneSize;
    //int lipOffset;
    NSMutableArray* beforeCliff;
    NSMutableArray* endCliff;
    BOOL beforeCliffAddedToVertices;
    float terrainAlpha;
    float previousSunY;
    
    //UIImage* textureSource;
    
}

-(instancetype)initWithImage:(UIImage*)image forSceneSize:(CGSize)size{
    if (self = [super init]) {
        //sceneSize = size;
        //textureSource = image;
        //[self generateTiledFillTexture:CGSizeMake(100, 100) andSceneSize:size :image];
        _decos = [NSMutableArray array];
        constants = [Constants sharedInstance];
        //lipOffset = arc4random_uniform(150) + 50;
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
            dx = arc4random_uniform(20);
        }
        else{
            dx = arc4random_uniform(10);

        }
        //int sign = (forwardLip == true) ? 1 :0;
        int sign = 1;
        
//        if ((i > (CLIFF_VERTEX_COUNT / 2)) && forwardLip) {
//            sign = arc4random_uniform(2);
//        }
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
    for (Decoration* deco in _decos) {
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

-(void)closeLoopAndFillTerrainInView:(SKView*)view withCurrentSunYPosition:(float)sunY minY:(float)minY andMaxY:(float)maxY{
//    [self generateBackground:view];
    [self generate:view withCurrentSunYPosition:sunY minY:minY andMaxY:maxY];
    
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

-(void)generate:(SKView*)view withCurrentSunYPosition:(float)sunY minY:(float)minY andMaxY:(float)maxY{
    
    if (_textureShapeNode) {
        [_textureShapeNode removeFromParent];
    }
    _textureShapeNode = [self shapeNodeWithVertices:_vertices];
    _textureShapeNode.fillColor = [self findTimeSpecificTerrainColorWithCurrentSunYPosition:sunY minY:minY andMaxY:maxY];
    //_textureShapeNode.fillColor = [SKColor colorWithHue:100 saturation:100 brightness:100 alpha:1];
    //NSLog(@"_textureShapeNode.fillColor: %@", _textureShapeNode.fillColor);
    //_textureShapeNode.alpha = 0.75f;
    
    [self addChild:_textureShapeNode];

}

//2 gradient point scheme

//-(SKColor*)findTimeSpecificTerrainColorWithCurrentSunYPosition:(float)sunY minY:(float)minY andMaxY:(float)maxY{
//    float a = minY;
//    float b = maxY;
//    float c = 196;
//    float d = 255;
//    float hue = c + ((fabsf(d - c) / fabsf(b - a)) * (b - sunY));
//    //NSLog(@"hue: %f", hue);
//    float minB = .4;
//    float alpha = .8;
//    float brightness = sunY / maxY;
//    brightness = (brightness < minB) ? minB : brightness;
//    SKColor* terCol = [SKColor colorWithHue:hue / 360 saturation:1.0 brightness:brightness alpha:alpha];
//    
//    return terCol;
//}

//-(SKColor*)findTimeSpecificTerrainColorWithCurrentSunYPosition:(float)sunY minY:(float)minY andMaxY:(float)maxY{
//    // that is, sunset, of course
//    float a_1 = 0;
//    float a_2 = minY;
//    float b = maxY;
//    
//    float c = 196;
//    //float d = 255;
//    //float e = 360;
//    float e = 270;
//    
//    float hue = 1;
//    float dy = sunY - previousSunY;
//    //if ((sunY > a_1) || (dy > 0)) {
//        //if (dy > 0) {
//         //   hue = c + ((fabsf(e - c) / fabsf(b - a_1)) * (b - sunY));
//        //}
//        //if (dy < 0) {
//          //  hue = c + ((fabsf(d - c) / fabsf(b - a_1)) * (b - sunY));
//        //}
//
//    //}
////    else{
////        hue = e - ((fabsf(d - e) / fabsf(a_1 - a_2)) * (a_1 - sunY));
////        //NSLog(@"hue: %f", hue);
////
////    }
//    hue = c + ((fabsf(e - c) / fabsf(b - a_2)) * (b - sunY));
//    
//    NSLog(@"hue: %f", hue);
//    float minB = .4;
//    terrainAlpha = .9;
//    float brightness = sunY / maxY;
//    brightness = (brightness < minB) ? minB : brightness;
//    //NSLog(@"brightness: %f", brightness);
//    
//    float saturation = 1 - (sunY / maxY);
//    float minSat = .25;
//    saturation = (saturation < minSat) ? minSat : saturation;
//    saturation = (saturation > 1) ? 1 : saturation;
//
//    //NSLog(@"saturation: %f", saturation);
//
//    SKColor* terCol = [SKColor colorWithHue:hue / 360 saturation:saturation brightness:brightness alpha:terrainAlpha];
//
//    previousSunY = sunY;
//    return terCol;
//}

-(SKColor*)findTimeSpecificTerrainColorWithCurrentSunYPosition:(float)sunY minY:(float)minY andMaxY:(float)maxY{
//black and white
    
    terrainAlpha = .9;
    float brightness = sunY / maxY;
    float minB = 0;
    brightness = (brightness < minB) ? minB : brightness;
    //NSLog(@"brightness: %f", brightness);

    float saturation = 1 - (sunY / maxY);
    float minSat = .25;
    saturation = (saturation < minSat) ? minSat : saturation;
    saturation = (saturation > 1) ? 1 : saturation;
    
    float hue = 35.0 / 360.0;
    
    SKColor* terCol = [SKColor colorWithHue:hue saturation:saturation brightness:brightness alpha:terrainAlpha];

    previousSunY = sunY;
    return terCol;
}



-(SKShapeNode*)shapeNodeWithVertices:(NSMutableArray*)vertexArray{
    
    SKShapeNode* node = [SKShapeNode node];
    node.position = CGPointZero;
    //node.fillColor = [SKColor colorWithHue:100 saturation:1.0 brightness:1.0 alpha:1.0];
    //node.fillColor = [UIColor colorWithHue:drand48() saturation:1.0 brightness:1.0 alpha:1.0];
    //node.fillTexture = _terrainTexture;
    node.antialiased = false;
    node.strokeColor = nil;
    node.physicsBody = nil;
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
    //CGPathMoveToPoint(pathToDraw, NULL, 0, 0);
    CGPathMoveToPoint(pathToDraw, NULL, firstVertex.x, firstVertex.y);

    
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
            CGPoint bottomLeftAreaVertex = CGPointMake(firstVertex.x, 0);
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


//-(void)dealloc{
//    NSLog(@"dealloc terrain");
//}

-(void)generateDecorationAtVertex:(CGPoint)v fromTerrainPool:(NSMutableArray*)terrainPool inNode:(SKNode*)node withZposition:(float)zPos andSlope:(float)slope{
    //NSLog(@"terrainPool:%@", terrainPool);
    if(_permitDecorations && (terrainPool.count > 0)){
    
        int probability1 = constants.TERRAIN_VERTEX_DECORATION_CHANCE_DENOM;
        int castedDie1 = arc4random_uniform(probability1 + 1);
        if (castedDie1 == probability1){
           // NSLog(@"(castedDie1 == probability1)");
            int castedDie2 = arc4random_uniform((int)terrainPool.count);
            //    NSLog(@"castedDie2: %i", castedDie2);
            SKTexture* tex = [terrainPool objectAtIndex:castedDie2];
            Decoration* sprite = [Decoration spriteNodeWithTexture:tex];
            sprite.size = CGSizeMake(sprite.size.width * constants.SCALE_COEFFICIENT.dy, sprite.size.height * constants.SCALE_COEFFICIENT.dy);
            if (sprite.size.width > (((SKScene*)node.parent).size.width / 5)) {
                sprite.size = CGSizeMake(sprite.size.width / 2, sprite.size.height / 2);
            }
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
