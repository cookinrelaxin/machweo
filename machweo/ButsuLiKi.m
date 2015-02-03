//
//  ButsuLiKi.m
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 10/23/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "ButsuLiKi.h"
#import "Obstacle.h"
#import "Line.h"
#import "SubLine.h"
#import "Intersection.h"
const int PAST_SLOPES_COUNT = 10;
const float ONLINE_ROTATION_SPEED = .005f;
const float OFFLINE_ROTATION_SPEED = .02f;

@implementation ButsuLiKi{
    float previousSlope;
    NSMutableArray *pastSlopes;
    BOOL shangoBrokeHisBack;
}

-(void)findCollision:(Player*)player withLineArray:(NSMutableArray*)LineArray{
    
    previousSlope = player.currentSlope;
    player.currentSlope = 0.0f;
    
    for (Line *line in LineArray){
        CGPoint playerCurrentPosition = player.position;
        CGPoint playerFuturePosition = CGPointMake(playerCurrentPosition.x + player.velocity.dx, playerCurrentPosition.y + player.velocity.dy);
        CGPoint lineAABBIntersection = [self test2DSegmentAABB:playerCurrentPosition :playerFuturePosition :line.AABB];
        if (CGPointEqualToPoint(lineAABBIntersection, CGPointZero)) {
            continue;
        }
       // NSLog(@"lineIntersection");

    
        for (SubLine *sub in line.subLines) {
            CGPoint sublineAABBIntersection = [self test2DSegmentAABB:playerCurrentPosition :playerFuturePosition :sub.AABB];
            if (CGPointEqualToPoint(sublineAABBIntersection, CGPointZero)) {
                continue;
            }
            NSLog(@"sublineIntersection");

            Intersection *sublineIntersection = [self findSublineIntersection:playerCurrentPosition :playerFuturePosition :sub];
            [self resolveCollision:sublineIntersection :player];
            return;

        }
        
        
//        if (pointArray.count < 2) {
//            //continue;
//            return ;
//        }
//        
//        int leftPointIndex = [self binarySearchForFlankingPoints:pointArray withPoint:player.position from:0 to:(int)pointArray.count - 1 forPlayerSize:player.size];
//        int rightPointIndex = leftPointIndex + 1;
//        if (!(rightPointIndex < pointArray.count)) {
//            rightPointIndex = leftPointIndex;
//        }
//        for (int i = leftPointIndex; (i < leftPointIndex + 10) && (i < pointArray.count - 1); i ++) {
//
//            NSValue *leftNode = [pointArray objectAtIndex:i];
//            NSValue *rightNode = [pointArray objectAtIndex:i + 1];
//
//            CGPoint leftPoint = leftNode.CGPointValue;
//            CGPoint rightPoint = rightNode.CGPointValue;
//           // NSLog(@"player.position.x: %f", player.position.x);
//           // NSLog(@"rightPoint.x: %f", rightPoint.x);
//            
//            BOOL playerIntersects = [self playerIntersectsLineSegment:player :leftPoint :rightPoint];
//
//            if (playerIntersects) {
//                
//                if (!line.belowPlayer) {
//                    if (!line.belowPlayer && ((leftPoint.y < player.yCoordinateOfBottomSide) && (rightPoint.y < player.yCoordinateOfBottomSide))) {
//                        line.belowPlayer = true;
//                    }
//                    break;
//                }
//                
//                CGPoint intersectionPoint = [self closestPtPointSegment:player.position :leftPoint :rightPoint];
//                
//                CGPoint newPlayerPosition = CGPointMake(intersectionPoint.x - (player.size.width / 2), intersectionPoint.y + (player.size.height / 2));
//                
//                if (newPlayerPosition.y > yMin) {
//                    yMin = newPlayerPosition.y;
//                }
//                
//                float slope = [ButsuLiKi calculateSlopeForTriangleBetween:leftPoint and:rightPoint];
//                player.currentSlope = slope;
//                player.roughlyOnLine = true;
//                [self addSlopeToSlopeArray:slope];
//                [self isShangoDead:player];
//                player.currentRotationSpeed = ONLINE_ROTATION_SPEED;
//
//                
//                
//                
//                if (rightNode == pointArray.lastObject) {
//                    player.endOfLine = true;
//                    player.currentRotationSpeed = OFFLINE_ROTATION_SPEED;
//                }
////                if ((rightNode == pointArray.lastObject) && (player.position.x > rightPoint.x)) {
////                    player.endOfLine = true;
////                }
//                
//            }
//        }

    }
    [self resolveCollision:nil :player];

  //  player.minYPosition = yMin;
}

-(void)resolveCollision:(Intersection*)intersection :(Player*)player{
    Constants *constants = [Constants sharedInstance];

    if (intersection) {
        
        GLKVector2 currentVelocity = GLKVector2Make(player.velocity.dx, player.velocity.dy);
        GLKVector2 normalizedVelocity = GLKVector2Normalize(currentVelocity);
        
        // not sure at all about this
        player.position = CGPointMake(intersection.point.x - (normalizedVelocity.x * player.size.width), intersection.point.y - (normalizedVelocity.y * player.size.height));
        
        float rads = atanf(intersection.slope);
        float impulse = constants.GRAVITY * sinf(rads);
        GLKVector2 m = GLKVector2Make(impulse * cosf(rads), impulse * sinf(rads));
        
        player.velocity = CGVectorMake(m.x, m.y);
    }
    else{
        player.velocity = CGVectorMake(player.velocity.dx, player.velocity.dy - constants.GRAVITY);
    }
    
}

-(Intersection*)findSublineIntersection:(CGPoint)a :(CGPoint)b :(SubLine*)subline{
    NSMutableArray* vertices = subline.vertices;
    for (int i = 0; i < vertices.count - 1; i ++) {
        CGPoint pt1 = ((NSValue*)[vertices objectAtIndex:i]).CGPointValue;
        CGPoint pt2 = ((NSValue*)[vertices objectAtIndex:i + 1]).CGPointValue;
        CGPoint intersection = [self test2DSegmentSegment:a :b :pt1 :pt2];
        if (!CGPointEqualToPoint(intersection, CGPointZero)) {
            // there's an intersection
            return [Intersection intersectionWithPoint:intersection andSlope:[ButsuLiKi calculateSlopeForTriangleBetween:pt1 and:pt2]];
        }

    }
    //no intersection. should not occur under expected circumstances
    return nil;
}


// this is possibly not working because cg rect's origin is top left...
-(CGPoint)test2DSegmentAABB:(CGPoint)a :(CGPoint)b :(CGRect)rect{
    CGPoint rectTopSide1 = CGPointMake(rect.origin.x, rect.size.height);
    CGPoint rectTopSide2 = CGPointMake(rect.origin.x + rect.size.width, rect.size.height);
    CGPoint intersection = [self test2DSegmentSegment:a :b :rectTopSide1 :rectTopSide2];
    if (!CGPointEqualToPoint(intersection, CGPointZero)) {
        // there's an intersection
        NSLog(@"Intersection with top side");

        return intersection;
    }
    
    CGPoint rectBottomSide1 = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint rectBottomSide2 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    intersection = [self test2DSegmentSegment:a :b :rectBottomSide1 :rectBottomSide2];
    if (!CGPointEqualToPoint(intersection, CGPointZero)) {
        // there's an intersection
        return intersection;
    }
    
    CGPoint rectLeftSide1 = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint rectLeftSide2 = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    intersection = [self test2DSegmentSegment:a :b :rectLeftSide1 :rectLeftSide2];
    if (!CGPointEqualToPoint(intersection, CGPointZero)) {
        // there's an intersection
        return intersection;
    }
    
    CGPoint rectRightSide1 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    CGPoint rectRightSide2 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    intersection = [self test2DSegmentSegment:a :b :rectRightSide1 :rectRightSide2];
    if (!CGPointEqualToPoint(intersection, CGPointZero)) {
        // there's an intersection
        return intersection;
    }
    
    return CGPointZero;
}

-(CGPoint)test2DSegmentSegment:(CGPoint)a :(CGPoint)b :(CGPoint)c :(CGPoint)d{
    float a1 = [self signed2DTriArea:a :b :d];
    float a2 = [self signed2DTriArea:a :b :c];
    if (a1 * a2 < 0.0f) {
        float a3 = [self signed2DTriArea:c :d :a];
        float a4 = a3 + a2 - a1;
        if (a3 * a4 < 0.0f) {
            float t = a3 / (a3 - a4);
            
            GLKVector2 aVector = GLKVector2Make(a.x, a.y);
            GLKVector2 bVector = GLKVector2Make(b.x, b.y);
            
            GLKVector2 pVector = GLKVector2Add(aVector, GLKVector2MultiplyScalar(GLKVector2Subtract(bVector, aVector), t));
            
            CGPoint intersectionPoint = CGPointMake(pVector.x, pVector.y);
            return intersectionPoint;
            
            
        }
    }
    //if no intersection
    return CGPointZero;
}

-(float)signed2DTriArea:(CGPoint)a :(CGPoint)b :(CGPoint)c{
    return (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);
}

-(void)addSlopeToSlopeArray:(float)slope{
    if (!pastSlopes) {
        pastSlopes = [NSMutableArray array];
    }
    [pastSlopes addObject:[NSNumber numberWithFloat:slope]];
    if (pastSlopes.count > PAST_SLOPES_COUNT) {
        [pastSlopes removeObjectAtIndex:0];
    }}

-(BOOL)playerIntersectsLineSegment:(Player*)player :(CGPoint)leftPoint :(CGPoint)rightPoint{
    float previousXCoordinateOfLeftSide = player.xCoordinateOfLeftSide;
    float previousXCoordinateOfRightSide = player.xCoordinateOfRightSide;
    float previousYCoordinateOfBottomSide = player.yCoordinateOfBottomSide;
    float previousYCoordinateOfTopSide = player.yCoordinateOfTopSide;
    
    float currentXCoordinateOfLeftSide = player.position.x - (player.size.width / 2);
    float currentXCoordinateOfRightSide = player.position.x + (player.size.width / 2);
    float currentYCoordinateOfBottomSide = player.position.y - (player.size.height / 2);
    float currentYCoordinateOfTopSide = player.position.y + (player.size.height / 2);

    float xOfSweptLeftSide = (previousXCoordinateOfLeftSide < currentXCoordinateOfLeftSide) ? previousXCoordinateOfLeftSide : currentXCoordinateOfLeftSide;
    float xOfSweptRightSide = (previousXCoordinateOfRightSide > currentXCoordinateOfRightSide) ? previousXCoordinateOfRightSide : currentXCoordinateOfRightSide;
    float yOfSweptBottomSide = (previousYCoordinateOfBottomSide < currentYCoordinateOfBottomSide) ? previousYCoordinateOfBottomSide : currentYCoordinateOfBottomSide;
    float yOfSweptTopSide = (previousYCoordinateOfTopSide > currentYCoordinateOfTopSide) ? previousYCoordinateOfTopSide : currentYCoordinateOfTopSide;
    
    
    BOOL horizontalPlaneIntersects = false;
    BOOL verticalPlaneIntersects = false;
    
    CGPoint lesserYPoint = (leftPoint.y < rightPoint.y) ? leftPoint : rightPoint;
    CGPoint greaterYPoint = (leftPoint.y > rightPoint.y) ? leftPoint : rightPoint;
    
    if ((yOfSweptTopSide >= lesserYPoint.y) && (yOfSweptBottomSide <= greaterYPoint.y)) {
        horizontalPlaneIntersects = true;
    }
    if ((xOfSweptRightSide >= leftPoint.x) && (xOfSweptLeftSide <= rightPoint.x)) {
        verticalPlaneIntersects = true;
    }
    
    return (horizontalPlaneIntersects && verticalPlaneIntersects);
}


+ (float)calculateSlopeForTriangleBetween:(CGPoint)pt1 and:(CGPoint)pt2{
    float horizontalLength = pt2.x - pt1.x;
    if (horizontalLength == 0) {
        return 0;
    }
    float verticalLength = pt2.y - pt1.y;
    float slope = verticalLength / horizontalLength;
    return slope;
}


//-(void)calculatePlayerVelocity:(Player *)player{
//    Constants *constants = [Constants sharedInstance];
//    
//    if (player.roughlyOnLine) {
//        player.velocity = CGVectorMake(player.velocity.dx + [self calculateXForceGivenSlope:player.currentSlope], player.velocity.dy + [self calculateYForceGivenSlope:player.currentSlope]);
//        player.velocity = CGVectorMake(player.velocity.dx + constants.AMBIENT_X_FORCE, player.velocity.dy);
//        player.velocity = CGVectorMake(player.velocity.dx * constants.FRICTION_COEFFICIENT, player.velocity.dy * constants.FRICTION_COEFFICIENT);
//        if (player.velocity.dy < -1) {
//            player.velocity = CGVectorMake(player.velocity.dx, -1);
//        }
//    }
//   else{
//        player.velocity = CGVectorMake(player.velocity.dx, player.velocity.dy - constants.GRAVITY);
//    }
//    
//    if ((player.velocity.dy < 0) && player.endOfLine) {
//        player.endOfLine = false;
//        player.velocity = CGVectorMake(player.velocity.dx, 0);
//    }
//
//    if (player.velocity.dy < constants.MIN_PLAYER_VELOCITY_DY) {
//        player.velocity = CGVectorMake(player.velocity.dx, constants.MIN_PLAYER_VELOCITY_DY);
//    }
//    if (player.velocity.dy > constants.MAX_PLAYER_VELOCITY_DY) {
//        player.velocity = CGVectorMake(player.velocity.dx, constants.MAX_PLAYER_VELOCITY_DY);
//    }
//    if (player.velocity.dx < constants.MIN_PLAYER_VELOCITY_DX) {
//        player.velocity = CGVectorMake(constants.MIN_PLAYER_VELOCITY_DX, player.velocity.dy);
//    }
//    if (player.velocity.dx > constants.MAX_PLAYER_VELOCITY_DX) {
//        player.velocity = CGVectorMake(constants.MAX_PLAYER_VELOCITY_DX, player.velocity.dy);
//    }
//   // NSLog(@"player.velocity: %f, %f", player.velocity.dx, player.velocity.dy);
//
//}

-(float)calculateXForceGivenSlope:(float)slope{
    Constants *constants = [Constants sharedInstance];
    if (fabsf(slope - previousSlope) < .001f) {
        // NSLog(@"same slope. return 0");
        return 0;
    }
    return -slope * constants.GRAVITY;
}

-(float)calculateYForceGivenSlope:(float)slope{
   // NSLog(@"slope: %f", slope);
    if (fabsf(slope - previousSlope) < .001f) {
       // NSLog(@"same slope. return 0");
        return 0;

    }
    return slope;
}

-(void)calculatePlayerPosition:(Player *)player withLineArray:(NSMutableArray*)lineArray{
    Constants *constants = [Constants sharedInstance];
    
    //[self calculatePlayerRotation:player];
   // [self calculatePlayerVelocity:player];
    player.position = CGPointMake(player.position.x + player.velocity.dx * constants.PHYSICS_SCALAR_MULTIPLIER, player.position.y + player.velocity.dy * constants.PHYSICS_SCALAR_MULTIPLIER);
  //  NSLog(@"player.position.y: %f", player.position.y);
   // NSLog(@"player.position.y scaled: %f", player.position.y * constants.PHYSICS_SCALAR_MULTIPLIER);

    
    [self findCollision:player withLineArray:lineArray];

}

-(float)averageSlope{
    float sum = 0;
    for (NSNumber* num in pastSlopes) {
        float slope = [num floatValue];
        sum += slope;
    }
    return sum / pastSlopes.count;
}

//-(void)calculatePlayerRotation:(Player*)player{
//    //if (!shangoBrokeHisBack) {
//        
//        if (player.roughlyOnLine) {
//            float averageSlope = [self averageSlope];
//            
//            float expectedRotation = M_PI_4 * averageSlope;
//            if (expectedRotation > M_PI_2) {
//                expectedRotation = M_PI_2;
//            }
//            
//            
//            
////            float differenceBetweenRotations = fabsf(player.zRotation - expectedRotation);
////            if (differenceBetweenRotations > 0) {
////            }
//    
//            player.zRotation = expectedRotation;
//            return;
//        }
//
//        [pastSlopes removeAllObjects];
//        if (fabsf(player.zRotation) <= (player.currentRotationSpeed * 2)){
//            player.zRotation = 0;
//        }
//        else{
//            player.zRotation -= player.currentRotationSpeed;
//        }
//    //}
//
//    
//    
//}

@end
