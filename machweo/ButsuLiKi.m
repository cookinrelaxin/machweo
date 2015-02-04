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
    CGPoint playerCurrentPosition = player.position;
    CGPoint playerFuturePosition = CGPointMake(playerCurrentPosition.x + player.velocity.dx, playerCurrentPosition.y + player.velocity.dy);
    
    for (Line *line in LineArray){
        if (![self test2DSegmentAABB:playerCurrentPosition :playerFuturePosition :line.AABB]) {
            continue;
        }
        
       // NSLog(@"lineIntersection");

    
        for (SubLine *sub in line.subLines) {
            if (![self test2DSegmentAABB:playerCurrentPosition :playerFuturePosition :sub.AABB]) {
                continue;
            }
           // NSLog(@"sublineIntersection");

            Intersection *sublineIntersection = [self findSublineIntersection:playerCurrentPosition :playerFuturePosition :sub];
            [self resolveCollision:sublineIntersection :player];
            return;

        }

    }
    [self resolveCollision:nil :player];

}

-(void)resolveCollision:(Intersection*)intersection :(Player*)player{
    Constants *constants = [Constants sharedInstance];

    if (intersection) {
        
        GLKVector2 currentVelocity = GLKVector2Make(player.velocity.dx, player.velocity.dy);
        GLKVector2 normalizedVelocity = GLKVector2Normalize(currentVelocity);
        
        // not sure at all about this
       // player.position = CGPointMake(intersection.point.x - (normalizedVelocity.x * player.size.width / 2), intersection.point.y - (normalizedVelocity.y * player.size.height / 2));
        //player.position = CGPointMake(intersection.point.x, intersection.point.y + player.size.height / 2);
        player.position = intersection.point;
        
        float rads = atanf(intersection.slope);
        float impulse = constants.GRAVITY * sinf(rads);
        GLKVector2 parallelToSlopeForce = GLKVector2Make(impulse * cosf(rads), impulse * sinf(rads));
        
       // GLKVector2 normalForce = GLKVector2Make(player.velocity, impulse * sinf(rads));

        
        player.velocity = CGVectorMake(parallelToSlopeForce.x, parallelToSlopeForce.y);
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
-(BOOL)test2DSegmentAABB:(CGPoint)a :(CGPoint)b :(CGRect)rect{
    
    CGPoint rectTopSide1 = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    CGPoint rectTopSide2 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGPoint intersection = [self test2DSegmentSegment:a :b :rectTopSide1 :rectTopSide2];
    if (!CGPointEqualToPoint(intersection, CGPointZero)) {
        // there's an intersection
       // NSLog(@"Intersection with top side");

        return true;
    }
    
    CGPoint rectBottomSide1 = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint rectBottomSide2 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    intersection = [self test2DSegmentSegment:a :b :rectBottomSide1 :rectBottomSide2];
    if (!CGPointEqualToPoint(intersection, CGPointZero)) {
        // there's an intersection
        //NSLog(@"Intersection with bottom side");

        return true;
    }
    
    CGPoint rectLeftSide1 = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint rectLeftSide2 = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    intersection = [self test2DSegmentSegment:a :b :rectLeftSide1 :rectLeftSide2];
    if (!CGPointEqualToPoint(intersection, CGPointZero)) {
        // there's an intersection
        return true;
    }
    
    CGPoint rectRightSide1 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    CGPoint rectRightSide2 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    intersection = [self test2DSegmentSegment:a :b :rectRightSide1 :rectRightSide2];
    if (!CGPointEqualToPoint(intersection, CGPointZero)) {
        // there's an intersection
        return true;
    }
    
    if ((a.x > rect.origin.x) && (a.x < rect.origin.x + rect.size.width)) {
        if ((a.y > rect.origin.y) && (a.y < rect.origin.y + rect.size.height)) {
            return true;
        }
    }
    if ((b.x > rect.origin.x) && (b.x < rect.origin.x + rect.size.width)) {
        if ((b.y > rect.origin.y) && (b.y < rect.origin.y + rect.size.height)) {
            return true;
        }
    }
    
    //return CGPointZero;
    return false;
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
    
    [self findCollision:player withLineArray:lineArray];
    player.position = CGPointMake(player.position.x + player.velocity.dx * constants.PHYSICS_SCALAR_MULTIPLIER, player.position.y + player.velocity.dy * constants.PHYSICS_SCALAR_MULTIPLIER);
    
  //  NSLog(@"player.position.y: %f", player.position.y);
   // NSLog(@"player.position.y scaled: %f", player.position.y * constants.PHYSICS_SCALAR_MULTIPLIER);

    

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
