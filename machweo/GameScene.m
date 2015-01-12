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
#import "Brush.h"

@implementation GameScene{
    Player *player;
    CGPoint previousPoint;
    CGPoint currentPoint;
    ButsuLiKi *physicsComponent;
    NSMutableArray *arrayOfLines;
    CGPoint currentDesiredPlayerPositionInView;
    int playerScore;
    Obstacle* nextObstacle;
    NSMutableArray* shapeNodes;
    
    int previousTime;
    int timerTime;
    
    //HUD
    SKLabelNode* timerLabel;
    SKLabelNode* restartButton;
    SKLabelNode* returnToMenuButton;
    
    BOOL stopScrolling;
    Brush* testBrush;
    
    
    
}

-(void)dealloc{
    NSLog(@"dealloc game scene");
}

-(instancetype)initWithSize:(CGSize)size forLevel:(NSString *)levelName{
    if (self = [super initWithSize:size]){
        _constants = [Constants sharedInstance];
        _obstacles = [SKNode node];
        _backgrounds = [SKNode node];
        _decorations = [SKNode node];
        [self addChild:_obstacles];
        [self addChild:_backgrounds];
        [self addChild:_decorations];
        physicsComponent = [[ButsuLiKi alloc] init];
        arrayOfLines = [NSMutableArray array];
        shapeNodes = [NSMutableArray array];
        
        testBrush = [Brush brushWithColors:@[[UIColor blackColor], [UIColor redColor], [UIColor brownColor], [UIColor grayColor], [UIColor cyanColor], [UIColor blackColor] ] lineThickness:5 andLineSpacing:5];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        //init hud
        
        timerLabel = [SKLabelNode labelNodeWithFontNamed:@"helvetica"];
        timerLabel.fontSize = _constants.TIMER_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dy;
        timerLabel.fontColor = _constants.TIMER_LABEL_FONT_COLOR;
        timerLabel.position = CGPointMake(CGRectGetMidX(self.frame), timerLabel.fontSize / 4);
        timerLabel.zPosition = _constants.HUD_Z_POSITION;
        [self addChild:timerLabel];
        
        restartButton = [SKLabelNode labelNodeWithText:@"restart"];
        restartButton.fontSize = _constants.RESTART_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dy;
        restartButton.fontName = _constants.RESTART_LABEL_FONT_NAME;
        restartButton.fontColor = _constants.RESTART_LABEL_FONT_COLOR;
        restartButton.position = CGPointMake(CGRectGetMaxX(self.frame) - restartButton.fontSize * 2, restartButton.fontSize / 4);
        restartButton.zPosition = _constants.HUD_Z_POSITION;
        [self addChild:restartButton];
        
        ChunkLoader *cl = [[ChunkLoader alloc] initWithFile:levelName];
        [cl loadWorld:self withBackgrounds:_backgrounds withObstacles:_obstacles andDecorations:_decorations withScaleCoefficient:_constants.SCALE_COEFFICIENT];
    }
    return self;
}

//-(void)didMoveToView:(SKView *)view{
//    NSLog(@"player.size.width: %f",player.size.width);
//
//}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    player.touchesEnded = false;
    UITouch* touch = [touches anyObject];
    CGPoint positionInSelf = [touch locationInNode:self];
    [self handleButtonPressesAtPoint:positionInSelf];
    previousPoint = currentPoint = positionInSelf;
//    if (!player) {
//        shouldCreateNewPlayer = true;
//    }
    
    Line *newLine = [[Line alloc] init];
    [arrayOfLines addObject:newLine];
    
}

-(void)handleButtonPressesAtPoint:(CGPoint)point{
    if (CGRectContainsPoint(restartButton.frame, point) ) {
        [restartButton removeFromParent];
        [self restartGame];
    }
    if (CGRectContainsPoint(returnToMenuButton.frame, point) ) {
        [returnToMenuButton removeFromParent];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"return to menu" object:nil userInfo:nil];
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    currentPoint = [touch locationInNode:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    Line *currentLine = [arrayOfLines lastObject];
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
    
    [currentPointArray addObject:[NSValue valueWithCGPoint:currentPoint]];
    [self removeLineIntersectionsBetween:previousPoint and:currentPoint];
    previousPoint = currentPoint;
    
}

-(void)removeLineIntersectionsBetween:(CGPoint)a and:(CGPoint)b{
    NSMutableArray* nodesToDeleteFromNodeArray = [NSMutableArray array];
    for (Line *previousLine in arrayOfLines) {
        if (previousLine == arrayOfLines.lastObject) {
            break;
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
        
    }
    
}

-(void)updateScore{
    
}

-(void)deallocOldLines{
    NSMutableArray* oldLines = [NSMutableArray array];
    for (Line *thisLine in arrayOfLines) {
        if (thisLine.shouldDeallocNodeArray) {
            [oldLines addObject:thisLine];

        }
    }
    for (Line* oldLine in oldLines) {
        [arrayOfLines removeObject:oldLine];
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
           // SKSpriteNode* lastNode = nodeArray.lastObject;
            NSValue* lastNode = nodeArray.lastObject;
            //CGPoint lastNodePositionInScene = [self convertPoint:lastNode.position fromNode:_lines];
            CGPoint lastNodePositionInView = [self convertPointToView: lastNode.CGPointValue];
            if (lastNodePositionInView.x < 0) {
                thisLine.shouldDeallocNodeArray = true;
            }
        }
    }
}

-(void)dispatchLineDrawing{
   // float lineWidth =  player.size.height * _constants.BRUSH_FRACTION_OF_PLAYER_SIZE;
  //  int layerCount = 5;
    
    //for (int i = 0; i <= layerCount; i ++) {
//        for (SKShapeNode* shapeNode in shapeNodes) {
//            SKShapeNode* copy = [SKShapeNode copy];
//            copy.position = CGPointMake(shapeNode.position.x, shapeNode.position.y - i * lineWidth);
//            [self addChild:copy];
//            [shapeNodes addObject:copy];
//        }
//    [self drawLinesWithThickness:lineWidth andYOffset:0 * lineWidth :NO :[UIColor blackColor]];
//    [self drawLinesWithThickness:lineWidth andYOffset:1 * lineWidth :NO :[UIColor whiteColor]];
//    [self drawLinesWithThickness:lineWidth andYOffset:2 * lineWidth :NO :[UIColor blackColor]];
//    [self drawLinesWithThickness:lineWidth andYOffset:3 * lineWidth :NO :[UIColor whiteColor]];
//    [self drawLinesWithThickness:lineWidth andYOffset:4 * lineWidth :NO :[UIColor blackColor]];

    //}
    [testBrush drawInScene:self forLines:arrayOfLines andShapeNodes:shapeNodes];
    
}


-(void)cleanUpShapeNodes{
    for (SKShapeNode* node in shapeNodes) {
        [node removeFromParent];
    }
    shapeNodes = [NSMutableArray array];

}

-(void)updateTimerLabel{
    timerLabel.text = [NSString stringWithFormat:@"%d", timerTime];

}

-(void)update:(CFTimeInterval)currentTime {
    
  //  dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        if (currentTime >= (previousTime + 1)) {
            [self updateTimerLabel];
            previousTime = currentTime;
            timerTime ++;
        }
    //});

  //  dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        [self checkForOldLines];
   // });
    [self deallocOldLines];
    
    [self cleanUpShapeNodes];
    if (!player.touchesEnded) {
        [self createLineNode];
    }

    [self checkForLostGame];
    
    if (!player) {
        [self createPlayer];
    }

    if (player) {
        [self centerCameraOnPlayer];
        [player resetMinsAndMaxs];
        [player updateEdges];
        [physicsComponent calculatePlayerPosition:player withLineArray:arrayOfLines];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"update velocity" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"{%f, %f}", player.velocity.dx, player.velocity.dy] forKey:@"velocity"]];
    [self updateScore];
    [self dispatchLineDrawing];
}

-(void)checkForLostGame{

    if (player.physicsBody.allContactedBodies.count > 0) {
        [self loseGame];
    }
    if (player.position.y < 0 - (player.size.height / 2)) {
        [self loseGame];
    }

}
-(void)loseGame{

    //[[NSNotificationCenter defaultCenter] postNotificationName:@"return to menu" object:nil userInfo:nil];
    self.view.paused = true;
    
    returnToMenuButton = [SKLabelNode labelNodeWithText:@"you lose. return to menu?"];
    returnToMenuButton.fontSize = _constants.RETURN_TO_MENU_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dy;
    returnToMenuButton.fontName = _constants.RETURN_TO_MENU_LABEL_FONT_NAME;
    returnToMenuButton.fontColor = _constants.RETURN_TO_MENU_LABEL_FONT_COLOR;
    //returnToMenuButton.position = CGPointMake(CGRectGetMidX(self.frame) * _constants.SCALE_COEFFICIENT.dx, CGRectGetMidY(self.frame) * _constants.SCALE_COEFFICIENT.dy);
    returnToMenuButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    returnToMenuButton.zPosition = _constants.HUD_Z_POSITION;
    [self addChild:returnToMenuButton];
}

-(void)checkForWonGame{
    CGPoint playerPosInView = [self convertPointToView:player.position];
    if (playerPosInView.x > (self.view.bounds.size.width + player.size.width / 2)) {
        [self winGame];
    }
}

-(void)winGame{
    
    self.view.paused = true;
    
    returnToMenuButton = [SKLabelNode labelNodeWithText:@"you win! return to menu?"];
    returnToMenuButton.fontSize = _constants.RETURN_TO_MENU_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dy;
    returnToMenuButton.fontName = _constants.RETURN_TO_MENU_LABEL_FONT_NAME;
    returnToMenuButton.fontColor = _constants.RETURN_TO_MENU_LABEL_FONT_COLOR;
    //returnToMenuButton.position = CGPointMake(CGRectGetMidX(self.frame) * _constants.SCALE_COEFFICIENT.dx, CGRectGetMidY(self.frame) * _constants.SCALE_COEFFICIENT.dy);
    returnToMenuButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    returnToMenuButton.zPosition = _constants.HUD_Z_POSITION;
    [self addChild:returnToMenuButton];
    
}

-(void)restartGame{
    self.view.paused = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restart game" object:nil userInfo:nil];

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
        }
        
        _obstacles.position = CGPointMake(_obstacles.position.x - differenceInPreviousAndCurrentPlayerPositions.dx, _obstacles.position.y);
        
        for (SKSpriteNode* deco in _decorations.children) {
            if ([deco.name isEqualToString:@"rightMostNode"]) {
                CGPoint posInScene = [self convertPoint:deco.position fromNode:_decorations];
                CGPoint posInView = [self convertPointToView:posInScene];
                float rightEdge = posInView.x + (deco.size.width / 2);
                if (rightEdge <= self.view.bounds.size.width){
                    stopScrolling = true;
                    return;
                }

            }
            float fractionalCoefficient = deco.zPosition / _constants.OBSTACLE_Z_POSITION;
            CGVector parallaxAdjustedDifference = CGVectorMake(fractionalCoefficient * differenceInPreviousAndCurrentPlayerPositions.dx, fractionalCoefficient * differenceInPreviousAndCurrentPlayerPositions.dy * _constants.Y_PARALLAX_COEFFICIENT);
            deco.position = CGPointMake(deco.position.x - parallaxAdjustedDifference.dx, deco.position.y - parallaxAdjustedDifference.dy);
        }
    }
}



@end
