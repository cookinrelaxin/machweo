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
const int PAST_SLOPES_COUNT = 10;
const float ONLINE_ROTATION_SPEED = .005f;
const float OFFLINE_ROTATION_SPEED = .02f;

@implementation ButsuLiKi{
    float previousSlope;
    NSMutableArray *pastSlopes;
    BOOL shangoBrokeHisBack;
}

-(void)resolveCollisions:(Player*)player withLineArray:(NSMutableArray*)LineArray{
    
   __block float yMin = player.position.y;
    player.roughlyOnLine = false;
    previousSlope = player.currentSlope;
    player.currentSlope = 0.0f;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(LineArray.count, queue, ^(size_t i) {
        Line* line = [LineArray objectAtIndex:i];
    //for (Line *line in LineArray){
        NSMutableArray *pointArray = line.nodeArray;
        if (pointArray.count < 2) {
            //continue;
            return ;
        }
        
        int leftPointIndex = [self binarySearchForFlankingPoints:pointArray withPoint:player.position from:0 to:(int)pointArray.count - 1 forPlayerSize:player.size];
        int rightPointIndex = leftPointIndex + 1;
        if (!(rightPointIndex < pointArray.count)) {
            rightPointIndex = leftPointIndex;
        }
        for (int i = leftPointIndex; (i < leftPointIndex + 10) && (i < pointArray.count - 1); i ++) {

            NSValue *leftNode = [pointArray objectAtIndex:i];
            NSValue *rightNode = [pointArray objectAtIndex:i + 1];

            CGPoint leftPoint = leftNode.CGPointValue;
            CGPoint rightPoint = rightNode.CGPointValue;
           // NSLog(@"player.position.x: %f", player.position.x);
           // NSLog(@"rightPoint.x: %f", rightPoint.x);
            
            BOOL playerIntersects = [self playerIntersectsLineSegment:player :leftPoint :rightPoint];

            if (playerIntersects) {
                
                if (!line.belowPlayer) {
                    if (!line.belowPlayer && ((leftPoint.y < player.yCoordinateOfBottomSide) && (rightPoint.y < player.yCoordinateOfBottomSide))) {
                        line.belowPlayer = true;
                    }
                    break;
                }
                
                CGPoint intersectionPoint = [self closestPtPointSegment:player.position :leftPoint :rightPoint];
                
                CGPoint newPlayerPosition = CGPointMake(intersectionPoint.x - (player.size.width / 2), intersectionPoint.y + (player.size.height / 2));
                
                if (newPlayerPosition.y > yMin) {
                    yMin = newPlayerPosition.y;
                }
                
                float slope = [ButsuLiKi calculateSlopeForTriangleBetween:leftPoint and:rightPoint];
                player.currentSlope = slope;
                player.roughlyOnLine = true;
                [self addSlopeToSlopeArray:slope];
                [self isShangoDead:player];
                player.currentRotationSpeed = ONLINE_ROTATION_SPEED;

                
                
                
                if (rightNode == pointArray.lastObject) {
                    player.endOfLine = true;
                    player.currentRotationSpeed = OFFLINE_ROTATION_SPEED;
                }
//                if ((rightNode == pointArray.lastObject) && (player.position.x > rightPoint.x)) {
//                    player.endOfLine = true;
//                }
                
            }
        }

    //}
    });

        player.minYPosition = yMin;
}

-(void)isShangoDead:(Player*)player{
  //  if ((player.currentRotationSpeed == OFFLINE_ROTATION_SPEED) && (player.velocity.dy < 0)) {
      if (player.velocity.dy < 0) {

      //  NSLog(@"player.zRotation: %f", player.zRotation);
        if (player.zRotation > M_PI_4) {
              //NSLog(@"player.currentSlope: %f", player.currentSlope);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shangoBrokeHisBack" object:nil];
            shangoBrokeHisBack = true;
        }
    }
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

//returns the index of the left point for the relevant line
-(int) binarySearchForFlankingPoints:(NSMutableArray*)pointArray withPoint:(CGPoint)point from:(int)imin to:(int)imax forPlayerSize:(CGSize)playerSize{
    if ((imax - imin) == 1){
        return imin;
    }
    if (imax == imin){
        return imin;
    }
    
    NSValue *imaxNode = [pointArray objectAtIndex:imax];
    CGPoint imaxPoint = imaxNode.CGPointValue;
    
    NSValue *iminNode = [pointArray objectAtIndex:imin];
    CGPoint iminPoint = iminNode.CGPointValue;
    
    if ((imaxPoint.x - iminPoint.x) < playerSize.width) {
        CGPoint closestPoint = iminPoint;
        int closestIndex = imin;
        for (int i = imin + 1; i <= imax; i ++) {
            NSValue *iNode = [pointArray objectAtIndex:i];
            CGPoint iPoint = iNode.CGPointValue;
            
            float distanceToPlayer = [self distanceBetween:point and:iPoint];
            if (distanceToPlayer < [self distanceBetween:point and:closestPoint]) {
                closestPoint = iPoint;
                closestIndex = i;
            }
        }
        return closestIndex;
    }
    
    
     {
        int imid = midpoint(imin, imax);
        NSValue *imidNode = [pointArray objectAtIndex:imid];
         CGPoint imidPoint = imidNode.CGPointValue;
         if (imidPoint.x > point.x) {
            return [self binarySearchForFlankingPoints:pointArray withPoint:point from:imin to:imid forPlayerSize:playerSize];
        }
        else{
            return [self binarySearchForFlankingPoints:pointArray withPoint:point from:imid to:imax forPlayerSize:playerSize];
        }
    }
}

- (float) distanceBetween : (CGPoint) p1 and: (CGPoint)p2
{
    return sqrt(pow(p2.x-p1.x,2)+pow(p2.y-p1.y,2));
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

-(CGPoint)closestPtPointSegment:(CGPoint)c :(CGPoint)a :(CGPoint)b{
    GLKVector2 aVector = GLKVector2Make(a.x, a.y);
    GLKVector2 bVector = GLKVector2Make(b.x, b.y);
    GLKVector2 cVector = GLKVector2Make(c.x, c.y);
    
    GLKVector2 ab = GLKVector2Subtract(bVector, aVector);
    float t = GLKVector2DotProduct(GLKVector2Subtract(cVector, aVector), ab) / GLKVector2DotProduct(ab, ab);
//    if (t < 0.0f){
//        t = 0.0f;
//    }
//    if (t > 0.0f) {
        //t = 1.0f;
//    }

    //NSLog(@"t: %f", t);
    GLKVector2 d = GLKVector2Add(aVector, GLKVector2MultiplyScalar(ab, t));
    return CGPointMake(d.x, d.y);
}

-(void)calculatePlayerVelocity:(Player *)player{
    Constants *constants = [Constants sharedInstance];
    
    if (player.roughlyOnLine) {
        player.velocity = CGVectorMake(player.velocity.dx + [self calculateXForceGivenSlope:player.currentSlope], player.velocity.dy + [self calculateYForceGivenSlope:player.currentSlope]);
        player.velocity = CGVectorMake(player.velocity.dx + constants.AMBIENT_X_FORCE, player.velocity.dy);
        player.velocity = CGVectorMake(player.velocity.dx * constants.FRICTION_COEFFICIENT, player.velocity.dy * constants.FRICTION_COEFFICIENT);
        if (player.velocity.dy < -1) {
            player.velocity = CGVectorMake(player.velocity.dx, -1);
        }
    }
   else{
        player.velocity = CGVectorMake(player.velocity.dx, player.velocity.dy - constants.GRAVITY);
    }
    
    if ((player.velocity.dy < 0) && player.endOfLine) {
        player.endOfLine = false;
        player.velocity = CGVectorMake(player.velocity.dx, 0);
    }

    if (player.velocity.dy < constants.MIN_PLAYER_VELOCITY_DY) {
        player.velocity = CGVectorMake(player.velocity.dx, constants.MIN_PLAYER_VELOCITY_DY);
    }
    if (player.velocity.dy > constants.MAX_PLAYER_VELOCITY_DY) {
        player.velocity = CGVectorMake(player.velocity.dx, constants.MAX_PLAYER_VELOCITY_DY);
    }
    if (player.velocity.dx < constants.MIN_PLAYER_VELOCITY_DX) {
        player.velocity = CGVectorMake(constants.MIN_PLAYER_VELOCITY_DX, player.velocity.dy);
    }
    if (player.velocity.dx > constants.MAX_PLAYER_VELOCITY_DX) {
        player.velocity = CGVectorMake(constants.MAX_PLAYER_VELOCITY_DX, player.velocity.dy);
    }
   // NSLog(@"player.velocity: %f, %f", player.velocity.dx, player.velocity.dy);

}

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
    
    [self calculatePlayerRotation:player];
    [self calculatePlayerVelocity:player];
    player.position = CGPointMake(player.position.x + player.velocity.dx * constants.PHYSICS_SCALAR_MULTIPLIER, player.position.y + player.velocity.dy * constants.PHYSICS_SCALAR_MULTIPLIER);
  //  NSLog(@"player.position.y: %f", player.position.y);
   // NSLog(@"player.position.y scaled: %f", player.position.y * constants.PHYSICS_SCALAR_MULTIPLIER);

    
    [self resolveCollisions:player withLineArray:lineArray];
    if (player.roughlyOnLine) {
        if (player.position.y < player.minYPosition) {
            player.position = CGPointMake(player.position.x, player.minYPosition);
        }
    }
   // [self verticalLoopPlayer:player];
   
    
    
}

-(void)verticalLoopPlayer:(Player*)player{
    if (player.velocity.dy > 0) {
        if ((player.position.y - player.size.height) > player.parent.frame.size.height) {
            player.position = CGPointMake(player.position.x, 0 - player.size.height);
        }
        return;
    }
    if (player.velocity.dy < 0) {
     //   NSLog(@"player.position.y: %f", player.position.y);
        if ((player.position.y + player.size.height) < 0) {
            player.position = CGPointMake(player.position.x, player.size.height + player.parent.frame.size.height);
        }
        return;
    }
    
}
-(float)averageSlope{
    float sum = 0;
    for (NSNumber* num in pastSlopes) {
        float slope = [num floatValue];
        sum += slope;
    }
    return sum / pastSlopes.count;
}

-(void)calculatePlayerRotation:(Player*)player{
    //if (!shangoBrokeHisBack) {
        
        if (player.roughlyOnLine) {
            float averageSlope = [self averageSlope];
            
            float expectedRotation = M_PI_4 * averageSlope;
            if (expectedRotation > M_PI_2) {
                expectedRotation = M_PI_2;
            }
            
            
            
//            float differenceBetweenRotations = fabsf(player.zRotation - expectedRotation);
//            if (differenceBetweenRotations > 0) {
//            }
    
            player.zRotation = expectedRotation;
            return;
        }

        [pastSlopes removeAllObjects];
        if (fabsf(player.zRotation) <= (player.currentRotationSpeed * 2)){
            player.zRotation = 0;
        }
        else{
            player.zRotation -= player.currentRotationSpeed;
        }
    //}

    
    
}

@end
