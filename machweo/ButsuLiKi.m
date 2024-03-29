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
@implementation ButsuLiKi

-(void)resolveCollisions:(Player*)player withLineArray:(NSMutableArray*)LineArray{
    
    float yMin = player.position.y;
    player.roughlyOnLine = false;
    player.currentSlope = 0.0f;
    
    for (Line *line in LineArray){
        NSMutableArray *pointArray = line.nodeArray;
        if (pointArray.count < 2) {
            continue;
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
                
                if (rightNode == pointArray.lastObject) {
                    player.endOfLine = true;
                }
                
            }
        }

    }

        player.minYPosition = yMin;
}

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
    }
    //else{
        player.velocity = CGVectorMake(player.velocity.dx, player.velocity.dy - constants.GRAVITY);
   // }
    
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

}

-(float)calculateXForceGivenSlope:(float)slope{
    Constants *constants = [Constants sharedInstance];
    return -slope * constants.GRAVITY;
}

-(float)calculateYForceGivenSlope:(float)slope{
    return slope /*- constants.GRAVITY*/;

}

-(void)calculatePlayerPosition:(Player *)player withLineArray:(NSMutableArray*)lineArray{
    [self calculatePlayerVelocity:player];
    player.position = CGPointMake(player.position.x + player.velocity.dx, player.position.y + player.velocity.dy);
    [self resolveCollisions:player withLineArray:lineArray];
    if (player.roughlyOnLine) {
        if (player.position.y < player.minYPosition) {
            player.position = CGPointMake(player.position.x, player.minYPosition);
        }
    }
    //NSLog(@"player.position.y: %f", player.position.y);
}

//-(BOOL)correctNodeSize:(SKSpriteNode*)node :(Constants*)constants{
//    if (CGSizeEqualToSize(node.size, CGSizeMake(constants.BRUSH_SIZE * constants.SCALE_COEFFICIENT.dx, constants.BRUSH_SIZE* constants.SCALE_COEFFICIENT.dy))) {
//        return true;
//    }
//    return false;
//}
@end
