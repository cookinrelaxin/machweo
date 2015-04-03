//
//  ButsuLiKi.m
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 10/23/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "ButsuLiKi.h"
#import "Obstacle.h"
#import "Terrain.h"
const int PAST_SLOPES_COUNT = 10;
const float ONLINE_ROTATION_SPEED = .005f;
const float OFFLINE_ROTATION_SPEED = .02f;

@implementation ButsuLiKi{
    float previousSlope;
    CGSize sceneSize;
    Constants *constants;
}
-(instancetype)initWithSceneSize:(CGSize)size{
    if (self = [super init]) {
        sceneSize = size;
        constants = [Constants sharedInstance];
    }
    return self;
}
-(void)resolveCollisions:(Player*)player withTerrainArray:(NSMutableArray*)terrainArray{
    
   __block float yMin = player.position.y;
    player.roughlyOnLine = false;
    player.endOfLine = false;
    previousSlope = player.currentSlope;
    player.currentSlope = 0.0f;
    for (Terrain *ter in terrainArray){
        NSMutableArray *pointArray = ter.vertices;
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
            BOOL playerIntersects = [self playerIntersectsLineSegment:player :leftPoint :rightPoint];
            if (playerIntersects) {
                if (!ter.belowPlayer) {
                    if (!ter.belowPlayer && ((leftPoint.y < player.yCoordinateOfBottomSide) && (rightPoint.y < player.yCoordinateOfBottomSide))) {
                        ter.belowPlayer = true;
                    }
                    break;
                }
                CGPoint intersectionPoint = [self closestPtPointSegment:player.position :leftPoint :rightPoint];
                CGPoint newPlayerPosition = CGPointMake(intersectionPoint.x - (player.size.width / 2), intersectionPoint.y + (player.size.height / 2) - (player.size.height / 6));
                if (newPlayerPosition.y > yMin) {
                    yMin = newPlayerPosition.y;
                }
                float slope = [ButsuLiKi calculateSlopeForTriangleBetween:leftPoint and:rightPoint];
                player.currentSlope = slope;
                player.roughlyOnLine = true;
                player.currentRotationSpeed = ONLINE_ROTATION_SPEED;
                CGPoint lastPoint = ((NSValue*)pointArray.lastObject).CGPointValue;
                if (fabsf(lastPoint.x - rightNode.CGPointValue.x) < player.size.width) {
                    player.endOfLine = true;
                    player.roughlyOnLine = false;
                    player.currentRotationSpeed = OFFLINE_ROTATION_SPEED;
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
    GLKVector2 d = GLKVector2Add(aVector, GLKVector2MultiplyScalar(ab, t));
    return CGPointMake(d.x, d.y);
}

-(void)calculatePlayerVelocity:(Player *)player{
    if (player.roughlyOnLine || player.endOfLine) {
        player.velocity = CGVectorMake(player.velocity.dx + [self calculateXForceGivenSlope:player.currentSlope], player.velocity.dy + [self calculateYForceGivenSlope:player.currentSlope]);
        player.velocity = CGVectorMake(player.velocity.dx + constants.AMBIENT_X_FORCE, player.velocity.dy);
        player.velocity = CGVectorMake(player.velocity.dx * constants.FRICTION_COEFFICIENT, player.velocity.dy * constants.FRICTION_COEFFICIENT);
        if (player.velocity.dy < -2) {
            player.velocity = CGVectorMake(player.velocity.dx, -2);
        }
    }
    else if (player.onGround) {
        player.velocity = CGVectorMake(player.velocity.dx + constants.AMBIENT_X_FORCE, player.velocity.dy);
        player.velocity = CGVectorMake(player.velocity.dx * constants.FRICTION_COEFFICIENT, 0);
    }
   else{
        player.velocity = CGVectorMake(player.velocity.dx, player.velocity.dy - constants.GRAVITY);
    }
    if ((player.velocity.dy < 0) && player.endOfLine) {
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
    //NSLog(@"player.velocity: %f, %f", player.velocity.dx, player.velocity.dy);
}

-(float)calculateXForceGivenSlope:(float)slope{
    if (fabsf(slope - previousSlope) < .001f) {
        return 0;
    }
    return -slope * constants.GRAVITY;
}

-(float)calculateYForceGivenSlope:(float)slope{
    if (fabsf(slope - previousSlope) < .001f) {
        return 0;
    }
    return slope;
}

-(void)calculatePlayerPosition:(Player *)player withTerrainArray:(NSMutableArray *)terrainArray{
    [self calculatePlayerVelocity:player];
    player.position = CGPointMake(player.position.x + player.velocity.dx * constants.PHYSICS_SCALAR_MULTIPLIER, player.position.y + player.velocity.dy * constants.PHYSICS_SCALAR_MULTIPLIER);
    [self resolveCollisions:player withTerrainArray:terrainArray];
    [self calculatePlayerRotation:player];
    if (player.roughlyOnLine || player.endOfLine) {
        if (player.position.y < player.minYPosition) {
            player.position = CGPointMake(player.position.x, player.minYPosition);
        }
    }
    if ((player.position.y - (player.size.height / 2)) < 0){
        player.onGround = true;
        player.position = CGPointMake(player.position.x, (player.size.height / 2) - (player.size.height / 6));
    }
    else{
        player.onGround = false;
    }
}

-(void)calculatePlayerRotation:(Player*)player{
    if (player.onGround) {
        player.zRotation = 0;
    }
    if (player.roughlyOnLine) {
        player.zRotation = M_PI_4 * player.currentSlope;
        return;
    }
    if (player.endOfLine) {
        if (![player actionForKey:@"flip"]) {
            int dice = arc4random_uniform(64);
            if (dice == 0) {
                int sign = (arc4random_uniform(2) == 0) ? -1 : 1;
                [player runAction:[SKAction sequence:@[[SKAction rotateByAngle:(sign * 2 * M_PI) duration:.3], [SKAction rotateToAngle:0 duration:.5 shortestUnitArc:YES]]] withKey:@"flip"];
                return;
            }
            if (player.zRotation > (M_PI / 4)) {
                [player runAction:[SKAction rotateToAngle:0 duration:.5 shortestUnitArc:NO] withKey:@"flip"];
            }
        }
    }
}

-(void)reset{
    previousSlope = 0;
}

@end
