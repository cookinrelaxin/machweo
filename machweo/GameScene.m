//
//  GameScene.m
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 10/19/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//
#import "GameScene.h"
#import "ButsuLiKi.h"
#import "Player.h"
#import "Obstacle.h"
#import "Line.h"
#import "ChunkLoader.h"
#import "Score.h"

@implementation GameScene{
    Player *player;
    CGPoint previousPoint;
    CGPoint currentPoint;
    ButsuLiKi *physicsComponent;
    NSMutableArray *arrayOfLines;
    CGPoint currentDesiredPlayerPositionInView;
    //Score* playerScore;
    Obstacle* nextObstacle;
    
    NSMutableArray* terrainPool;
    
    double previousTime;
 //   int timerTime;
    
    //HUD
    //SKLabelNode* timerLabel;
    //SKLabelNode* restartButton;
    //SKLabelNode* returnToMenuButton;
    
    BOOL stopScrolling;
    BOOL gameWon;
    BOOL restartGameNotificationSent;
    
    //BOOL zTicker;
    
    SKSpriteNode* sunNode;
}

-(void)dealloc{
    NSLog(@"dealloc game scene");
}

-(instancetype)initWithSize:(CGSize)size forLevel:(NSString *)levelName withinView:(SKView*)view{
    if (self = [super initWithSize:size]){
        //playerScore = [[Score alloc] init];
        _constants = [Constants sharedInstance];
        _obstacles = [SKNode node];
        _terrain = [SKNode node];
        _decorations = [SKNode node];
        [self addChild:_obstacles];
        [self addChild:_terrain];
        [self addChild:_decorations];
        physicsComponent = [[ButsuLiKi alloc] init];
        arrayOfLines = [NSMutableArray array];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        //init hud
        
//        timerLabel = [SKLabelNode labelNodeWithFontNamed:@"helvetica"];
//        timerLabel.fontSize = _constants.TIMER_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dy;
//        timerLabel.fontColor = _constants.TIMER_LABEL_FONT_COLOR;
//        timerLabel.position = CGPointMake(CGRectGetMidX(self.frame), timerLabel.fontSize / 4);
//        timerLabel.zPosition = _constants.HUD_Z_POSITION;
//        timerLabel.text = @"0.00";
//        [self addChild:timerLabel];
        
//        restartButton = [SKLabelNode labelNodeWithText:@"restart"];
//        restartButton.fontSize = _constants.RESTART_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dy;
//        restartButton.fontName = _constants.RESTART_LABEL_FONT_NAME;
//        restartButton.fontColor = _constants.RESTART_LABEL_FONT_COLOR;
//        restartButton.position = CGPointMake(CGRectGetMaxX(self.frame) - restartButton.fontSize * 2, restartButton.fontSize / 4);
//        restartButton.zPosition = _constants.HUD_Z_POSITION;
//        [self addChild:restartButton];
        
        ChunkLoader *cl = [[ChunkLoader alloc] initWithFile:levelName];
        terrainPool = [NSMutableArray array];
        [cl loadWorld:self withObstacles:_obstacles andDecorations:_decorations andTerrain:_terrain withinView:view andLines:arrayOfLines andTerrainPool:terrainPool];
        
        [self performSunrise];
        
    }
    return self;
}

-(void)performSunrise{
    sunNode = [SKSpriteNode spriteNodeWithImageNamed:@"sun_decoration"];
    [_decorations addChild:sunNode];
    sunNode.size = CGSizeMake(sunNode.size.width * _constants.SCALE_COEFFICIENT.dy, sunNode.size.height * _constants.SCALE_COEFFICIENT.dy);
    sunNode.zPosition = 1;
    sunNode.position = CGPointMake(self.position.x + self.size.width / 2, 0 - (sunNode.size.height / 2));
    SKAction* sunriseAction = [SKAction moveToY:(self.size.height - (sunNode.size.height / 2))  duration:3.0f];
    [sunNode runAction:sunriseAction];
}

-(void)performSunset{
    SKAction* sunsetAction = [SKAction moveToY:(0 - (sunNode.size.height / 2))  duration:3.0f];
    [sunNode runAction:sunsetAction];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    player.touchesEnded = false;
    UITouch* touch = [touches anyObject];
    CGPoint positionInSelf = [touch locationInNode:self];
    //[self handleButtonPressesAtPoint:positionInSelf];
    previousPoint = currentPoint = positionInSelf;
    
//    Line *currentLine = [arrayOfLines lastObject];

   // Line *newLine = [[Line alloc] initWithTerrainNode:_terrain :currentPoint];
    Line *newLine = [[Line alloc] initWithTerrainNode:_terrain :self.size];
//    for (Terrain * ter in newLine.terrainArray) {
//        if (zTicker) {
//        }
//    }
    [arrayOfLines addObject:newLine];
    

    //if ([currentLine pointUnderLine:currentPoint]) {
//    for (Terrain* ter in currentLine.terrainArray) {
//        ter.zPosition -= 10;
//    }
    //currentLine.terrain.zPosition -= 10;
   // }
    
    if (!player) {
        [self createPlayer];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismiss logo" object:nil];
    }
    
}

//-(void)handleButtonPressesAtPoint:(CGPoint)point{
//    if (CGRectContainsPoint(restartButton.frame, point) ) {
//        [restartButton removeFromParent];
//        [self restartGame];
//    }
//    if (CGRectContainsPoint(returnToMenuButton.frame, point) ) {
//        [returnToMenuButton removeFromParent];
//        //[self calculateScoreAndExit];
//    }
//}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    currentPoint = [touch locationInNode:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    Line *currentLine = [arrayOfLines lastObject];
    for (Terrain* ter in currentLine.terrainArray) {
        [ter correctSpriteZsBeforeVertex:currentPoint againstSlope:NO];
    }
//    for (Terrain* ter in currentLine.terrainArray) {
//        [ter removeLastSprite];
//    }
    currentLine.complete = true;
    player.touchesEnded = true;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesEnded:touches withEvent:event];
}

-(void)createPlayer{
    CGPoint pointToInitAt = CGPointMake(0, self.frame.size.height / 2);
    player = [Player playerAtPoint:pointToInitAt];
    [self addChild:player];
    currentDesiredPlayerPositionInView = CGPointMake(self.view.bounds.origin.x + (self.view.bounds.size.width / 8) * _constants.SCALE_COEFFICIENT.dy, [self convertPointToView:player.position].y);


}

-(void)createLineNode{
    Line *currentLine = [arrayOfLines lastObject];
    NSMutableArray *currentPointArray = currentLine.nodeArray;
    
    for (int i = (int)currentPointArray.count - 1; (i >= 0) && (i > currentPointArray.count - 1 - 5); i --) {
        NSValue* node = [currentPointArray objectAtIndex:i];
        float nodeXPos = [node CGPointValue].x;
        if (currentPoint.x < nodeXPos) {
            return;
        }
    }
    
    if (currentPointArray.count == 0) {
        
        if (player.position.y > currentPoint.y) {
            currentLine.belowPlayer = true;
        }
        else{
            currentLine.belowPlayer = false;
        }
    }
   // NSValue* pointValue = [NSValue valueWithCGPoint:currentPoint];
    
   // [currentPointArray addObject:pointValue];
    [currentPointArray addObject:[NSValue valueWithCGPoint:currentPoint]];
    //NSLog(@"currentPointArray.count:%lu", (unsigned long)currentPointArray.count);
    for (Terrain* ter in currentLine.terrainArray) {
        int backgroundOffset = (_constants.FOREGROUND_Z_POSITION - ter.zPosition) / 4;

        //int randomYd = arc4random_uniform(20);
        int randomYd = 0;
        float yDifferenceFromOrigin = currentLine.origin.y - currentPoint.y;
        float mellowedDifference = yDifferenceFromOrigin / 4;
        CGPoint newPoint;
        if (ter == currentLine.terrainArray.firstObject) {
            newPoint = CGPointMake(currentPoint.x, currentPoint.y + randomYd);
        }
        else{
            newPoint = CGPointMake(currentPoint.x, currentLine.origin.y + randomYd + mellowedDifference + backgroundOffset);

        }
            [ter.vertices addObject:[NSValue valueWithCGPoint:[ter convertPoint:newPoint fromNode:self]]];
        if (!ter.permitDecorations){
            [ter changeDecorationPermissions:newPoint];
        }
       // int backgroundYOffset = (_constants.FOREGROUND_Z_POSITION - ter.zPosition) / 2;
        [ter generateDecorationAtVertex:newPoint fromTerrainPool:terrainPool inNode:_decorations withZposition:0 andSlope:((currentPoint.y - previousPoint.y) / (currentPoint.x - previousPoint.x))];
    }
    [self removeLineIntersectionsBetween:previousPoint and:currentPoint];
    previousPoint = currentPoint;
    
}

-(void)removeLineIntersectionsBetween:(CGPoint)a and:(CGPoint)b{
    NSMutableArray* nodesToDeleteFromNodeArray = [NSMutableArray array];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(arrayOfLines.count, queue, ^(size_t i) {
        Line* previousLine = [arrayOfLines objectAtIndex:i];
   // for (Line *previousLine in arrayOfLines) {
        if ((previousLine == arrayOfLines.lastObject) || previousLine.allowIntersections) {
            return;
        }
        
        NSMutableArray *previousPointArray = previousLine.nodeArray;
        BOOL killTheRest = false;
        for (NSValue* node in previousPointArray) {
            CGPoint nodePosInScene = node.CGPointValue;

            //yes, 50 is a magic number. but it is a necessary cushion.
            if (killTheRest || (nodePosInScene.x >= a.x)) {
                if (killTheRest || ((nodePosInScene.y <= a.y) && (nodePosInScene.y >= b.y)) || ((nodePosInScene.y >= a.y) && (nodePosInScene.y <= b.y))) {
                    [nodesToDeleteFromNodeArray addObject:node];
                    killTheRest = true;
                }
            }
        }
        for (NSValue* node in nodesToDeleteFromNodeArray) {
            [previousPointArray removeObject:node];
        }
        });
        
   // }
    
}

//-(void)calculateScoreAndExit{
//    if (gameWon) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"return to menu" object:nil userInfo:[NSDictionary dictionaryWithObject:playerScore forKey:@"playerScore"]];
//    }
//    else{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"return to menu" object:nil userInfo:nil];
//    }
//    
//}

-(void)deallocOldLines{
    
    NSMutableArray* oldLines = [NSMutableArray array];
    
    for (Line *thisLine in arrayOfLines) {
        if (thisLine.shouldDeallocNodeArray) {
            [oldLines addObject:thisLine];
        }
    }
    
    for (Line* oldLine in oldLines) {
        [arrayOfLines removeObject:oldLine];
        for (Terrain* ter in oldLine.terrainArray) {
            [ter removeFromParent];
        }
    }
}

-(void)checkForOldLines{
    for (Line *thisLine in arrayOfLines) {
        if (thisLine == arrayOfLines.lastObject) {
            continue;
        }
        if (thisLine.shouldDeallocNodeArray) {
            continue;
        }
        if (thisLine.complete) {
            NSMutableArray* nodeArray = thisLine.nodeArray;
            NSValue* lastNode = nodeArray.lastObject;
            CGPoint lastNodePositionInView = [self convertPointToView: lastNode.CGPointValue];
            if (lastNodePositionInView.x < 0 - (self.size.width / 2)) {
                thisLine.shouldDeallocNodeArray = true;
            }
        }
    }
}

-(void)drawLines{
   // dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
   // dispatch_apply(arrayOfLines.count, queue, ^(size_t i) {
    for (Line* line in arrayOfLines) {
        if (line.shouldDraw) {
            //line.terrain.lineVertices = line.nodeArray;
            for (Terrain* ter in line.terrainArray) {
                [ter closeLoopAndFillTerrainInView:self.view];
            }
        }
   // });
    }
}

//-(void)updateTimerLabelWithTime:(double)time{
//    if (time > 10) {
//        timerLabel.text = [[NSString stringWithFormat:@"%f", time] substringToIndex:5];
//    }
//    else {
//        timerLabel.text = [[NSString stringWithFormat:@"%f", time] substringToIndex:4];
//    }
//}
//
//-(void)updateTime:(CFTimeInterval)currentTime{
//    if (previousTime == 0) {
//        previousTime = currentTime;
//    }
//    double difference = currentTime - previousTime;
//    if (difference > .001) {
//        [self updateTimerLabelWithTime:playerScore.time];
//        playerScore.time += currentTime - previousTime;
//        previousTime = currentTime;
//    }
//}

-(void)update:(CFTimeInterval)currentTime {
   // __weak GameScene* weakSelf = self;
   // dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^(void){
    //[self updateTime:currentTime];
   // });
    [self checkForOldLines];
    [self deallocOldLines];
    if (!player.touchesEnded) {
        [self createLineNode];
    }
    [self tellObstaclesToMove];
    //[self checkForWonGame];
    [self checkForLostGame];
    
    //if (!player) {
        //shouldCreateNewPlayer = true;
    //}
    //if (shouldCreateNewPlayer) {
    //    [self createPlayer];
    //}

    if (player) {
        [self centerCameraOnPlayer];
        [player resetMinsAndMaxs];
        [player updateEdges];
        [physicsComponent calculatePlayerPosition:player withLineArray:arrayOfLines];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"update velocity" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"{%f, %f}", player.velocity.dx, player.velocity.dy] forKey:@"velocity"]];
    [self drawLines];
   // [self generateDecorations];
}

-(void)checkForLostGame{

    if (player.physicsBody.allContactedBodies.count > 0) {
        [self loseGame];
    }
    if (player.position.y < 0 - (player.size.height / 2)) {
        [self loseGame];
    }
    
    if (_shangoBrokeHisBack) {
        [self loseGame];
    }
}


-(void)loseGame{
    [self performSunset];
    if (!restartGameNotificationSent) {
        restartGameNotificationSent = true;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"restart game" object:nil];
    }

   // self.view.paused = true;
}
//
//-(void)checkForWonGame{
//    if (player.position.x > self.size.width + player.size.width / 2) {
//        [self winGame];
//    }
//}

-(void)tellObstaclesToMove{
    for (Obstacle* obs in _obstacles.children) {
        [obs move];
    }
}

//-(void)winGame{
//    
//    self.view.paused = true;
//    
//    returnToMenuButton = [SKLabelNode labelNodeWithText:@"you win! return to menu?"];
//    returnToMenuButton.fontSize = _constants.RETURN_TO_MENU_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dy;
//    returnToMenuButton.fontName = _constants.RETURN_TO_MENU_LABEL_FONT_NAME;
//    returnToMenuButton.fontColor = _constants.RETURN_TO_MENU_LABEL_FONT_COLOR;
//    //returnToMenuButton.position = CGPointMake(CGRectGetMidX(self.frame) * _constants.SCALE_COEFFICIENT.dx, CGRectGetMidY(self.frame) * _constants.SCALE_COEFFICIENT.dy);
//    returnToMenuButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
//    returnToMenuButton.zPosition = _constants.HUD_Z_POSITION;
//    [self addChild:returnToMenuButton];
//    restartButton.hidden = true;
//    gameWon = true;
//    
//}


-(void)restartGame{
    self.view.paused = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restart game" object:nil userInfo:nil];

}

-(void)generateDecorations{
    for (Line* line in arrayOfLines) {
        // if (!player.touchesEnded) {
        [line generateConnectingLinesInTerrainNode:_terrain withTerrainPool:terrainPool andDecoNode:_decorations :!player.touchesEnded];
    }
}

- (void)centerCameraOnPlayer {
    if (!stopScrolling) {
        currentDesiredPlayerPositionInView = CGPointMake(currentDesiredPlayerPositionInView.x, [self convertPointToView:player.position].y);
        
        CGPoint playerPreviousPosition = CGPointMake(player.xCoordinateOfLeftSide + player.size.width / 2, player.yCoordinateOfBottomSide + player.size.height / 2);
        CGPoint playerCurrentPosition = player.position;
        player.position = [self convertPointFromView:currentDesiredPlayerPositionInView];
        CGVector differenceInPreviousAndCurrentPlayerPositions = CGVectorMake(playerCurrentPosition.x - playerPreviousPosition.x, playerCurrentPosition.y - playerPreviousPosition.y);
        for (Line* line in arrayOfLines) {
            for (int i = 0; i < line.nodeArray.count; i ++) {
                NSValue* pointNode = [line.nodeArray objectAtIndex:i];
                CGPoint pointNodePosition = pointNode.CGPointValue;
                [line.nodeArray replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:CGPointMake(pointNodePosition.x - differenceInPreviousAndCurrentPlayerPositions.dx, pointNodePosition.y)]];
            }
            
           // float fractionalCoefficient = _constants.FOREGROUND_Z_POSITION / _constants.OBSTACLE_Z_POSITION;
            // NSLog(@"fractionalCoefficient: %f", fractionalCoefficient);
            //CGVector parallaxAdjustedDifference = CGVectorMake(fractionalCoefficient * differenceInPreviousAndCurrentPlayerPositions.dx, fractionalCoefficient * differenceInPreviousAndCurrentPlayerPositions.dy * _constants.Y_PARALLAX_COEFFICIENT);
            //NSLog(@"parallaxAdjustedDifference.x: %f", parallaxAdjustedDifference.dx);
            
            for (Terrain* ter in line.terrainArray) {
                float fractionalCoefficient = ter.zPosition / _constants.OBSTACLE_Z_POSITION;
                CGVector parallaxAdjustedDifference = CGVectorMake(fractionalCoefficient * differenceInPreviousAndCurrentPlayerPositions.dx, fractionalCoefficient * differenceInPreviousAndCurrentPlayerPositions.dy * _constants.Y_PARALLAX_COEFFICIENT);
                ter.position = CGPointMake(ter.position.x - parallaxAdjustedDifference.dx, ter.position.y);
//                for (int i = 0; i < ter.vertices.count; i ++) {
//                    NSValue* pointNode = [ter.vertices objectAtIndex:i];
//                    CGPoint pointNodePosition = pointNode.CGPointValue;
//                    
//                    CGPoint newPoint = CGPointMake(pointNodePosition.x - parallaxAdjustedDifference.dx, pointNodePosition.y);
//                    
//                    [ter.vertices replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:newPoint]];
//                }
//
            }
        }
        
        _obstacles.position = CGPointMake(_obstacles.position.x - differenceInPreviousAndCurrentPlayerPositions.dx, _obstacles.position.y);
        //_terrain.position = CGPointMake(_terrain.position.x - differenceInPreviousAndCurrentPlayerPositions.dx, _terrain.position.y);
        
        for (SKSpriteNode* deco in _decorations.children) {
            if ([deco.name isEqualToString:@"rightMostNode"]) {
                CGPoint posInScene = [self convertPoint:CGPointMake(CGRectGetMaxX(deco.frame), deco.position.y) fromNode:_decorations];
                if (posInScene.x <= self.size.width){
                    stopScrolling = true;
                    return;
                }

            }
            //NSLog(@"deco.zPosition: %f", deco.zPosition);
            float fractionalCoefficient = deco.zPosition / _constants.OBSTACLE_Z_POSITION;
            CGVector parallaxAdjustedDifference = CGVectorMake(fractionalCoefficient * differenceInPreviousAndCurrentPlayerPositions.dx, fractionalCoefficient * differenceInPreviousAndCurrentPlayerPositions.dy * _constants.Y_PARALLAX_COEFFICIENT);
            deco.position = CGPointMake(deco.position.x - parallaxAdjustedDifference.dx, deco.position.y - parallaxAdjustedDifference.dy);
        }
    }
    
}



@end
