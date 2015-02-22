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
#import <AVFoundation/AVFoundation.h>
int Y_THRESHOLD_FOR_SWITCH_LEVEL = 40;
int ALLOWABLE_X_DIFFERENCE = 10;

@implementation GameScene{
    Player *player;
    CGPoint previousPoint;
    CGPoint currentPoint;
    ButsuLiKi *physicsComponent;
    NSMutableArray *arrayOfLines;
    CGPoint currentDesiredPlayerPositionInView;
    //Score* playerScore;
    //Obstacle* nextObstacle;
    
    NSMutableArray* terrainPool;
    
    double previousTime;
    BOOL stopScrolling;
    BOOL gameWon;
    BOOL restartGameNotificationSent;
    BOOL gameOver;
    BOOL in_game;
    
    SKLabelNode* logoLabel;
    SKSpriteNode* sunNode;
    
    AVAudioPlayer* backgroundMusicPlayer;
    
    CGPoint initialTouchPoint;
    
    BOOL tutorial_mode_on;
    BOOL found_first_obstacle;
    BOOL passed_first_obstacle;
    BOOL popup_engaged;
    //Obstacle* firstObstacle;

    
    
    
}

-(void)dealloc{
    backgroundMusicPlayer = nil;
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
        
        logoLabel = [SKLabelNode labelNodeWithFontNamed:_constants.LOGO_LABEL_FONT_NAME];
        logoLabel.fontSize = _constants.LOGO_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dx;
        //logoLabel.fontColor = _constants.LOGO_LABEL_FONT_COLOR;
        logoLabel.fontColor = [UIColor colorWithRed:243.0f/255.0f green:126.0f/255.0f blue:61.0f/255.0f alpha:1];
        //logoLabel.fontColor = [UIColor redColor];
        logoLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        logoLabel.zPosition = _constants.HUD_Z_POSITION;
        logoLabel.text = @"MACHWEO";
        //logoLabel.text = levelName;
        [self addChild:logoLabel];
        //SKAction* logoFadeIn = [SKAction fadeInWithDuration:1];
        logoLabel.alpha = 0.0f;
        SKAction* logoFadeIn = [SKAction fadeAlphaTo:1.0f duration:1];
        [logoLabel runAction:logoFadeIn completion:^{
            SKAction* logoFadeOut = [SKAction fadeAlphaTo:0.0f duration:.5];
            [logoLabel runAction:logoFadeOut completion:^{
                //NSLog(@"fade in again");
                logoLabel.text = levelName;
                SKAction* logoFadeInAgain = [SKAction fadeAlphaTo:1.0f duration:1];
                [logoLabel runAction:logoFadeInAgain completion:^{
                    SKAction* logoFadeOut = [SKAction fadeOutWithDuration:1];
                    [logoLabel runAction:logoFadeOut completion:^{
                        [logoLabel removeFromParent];
                        logoLabel = nil;
                        if ([levelName isEqualToString:@"The Journey Begins"]) {
                            tutorial_mode_on = true;
                            
                            NSMutableDictionary* popupDict = [NSMutableDictionary dictionary];
                            [popupDict setValue:@"draw a path with your finger" forKey:@"popup text"];
                            [popupDict setValue:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))] forKey:@"popup position"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"add popup" object:nil userInfo:popupDict];
                            
                            popup_engaged = true;
                        }

                    }];
                }];
            }];
        }];

        ChunkLoader *cl = [[ChunkLoader alloc] initWithFile:levelName];
                terrainPool = [NSMutableArray array];
        [cl loadWorld:self withObstacles:_obstacles andDecorations:_decorations andTerrain:_terrain withinView:view andLines:arrayOfLines andTerrainPool:terrainPool];
        
        [self performSunrise];
        [self startMusic];
        
        
    }
    return self;
}

-(void)performSunrise{
    sunNode = [SKSpriteNode spriteNodeWithImageNamed:@"sun_decoration"];
    [_decorations addChild:sunNode];
    sunNode.size = CGSizeMake(sunNode.size.width * _constants.SCALE_COEFFICIENT.dy, sunNode.size.height * _constants.SCALE_COEFFICIENT.dy);
    sunNode.zPosition = 1;
    sunNode.position = CGPointMake(self.position.x + self.size.width / 2, 0 - (sunNode.size.height / 2));
    SKAction* sunriseAction = [SKAction moveToY:(self.size.height - (sunNode.size.height / 2))  duration:2.0f];
    [sunNode runAction:sunriseAction];
}

-(void)performSunset{
    SKAction* sunsetAction = [SKAction moveToY:(0 - (sunNode.size.height / 2))  duration:2.0f];
    [sunNode runAction:sunsetAction];
}

-(void)loadPreviousLevel{
    
    Constants* constants = [Constants sharedInstance];
    NSMutableArray* levelArray = constants.LEVEL_ARRAY;
    int newIndex = constants.CURRENT_INDEX_IN_LEVEL_ARRAY - 1;
    if ((newIndex >= 0) && (newIndex < levelArray.count)) {
        constants.CURRENT_INDEX_IN_LEVEL_ARRAY --;
        //NSLog(@"loadPreviousLevel");
        [self winGame];
    }
}

-(void)loadNextLevel{
    Constants* constants = [Constants sharedInstance];
    NSMutableArray* levelArray = constants.LEVEL_ARRAY;
    int newIndex = constants.CURRENT_INDEX_IN_LEVEL_ARRAY + 1;
    if ((newIndex >= 0) && (newIndex < levelArray.count)) {
        constants.CURRENT_INDEX_IN_LEVEL_ARRAY ++;
        //NSLog(@"loadNextLevel");
        [self winGame];
    }
}

-(void)startMusic{
    //[self runAction:[SKAction playSoundFileNamed:@"gametrack.mp3" waitForCompletion:NO]];
    
    NSError *error;
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"gametrack" withExtension:@"mp3"];
    backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    backgroundMusicPlayer.numberOfLoops = -1;
    [backgroundMusicPlayer prepareToPlay];
    [backgroundMusicPlayer setVolume: 0.0];
    [self fadeVolumeIn];
    [backgroundMusicPlayer play];
}

-(void)fadeVolumeIn {
    if (!gameOver && backgroundMusicPlayer && (backgroundMusicPlayer.volume < .25)) {
        //NSLog(@"fade in");
        backgroundMusicPlayer.volume = backgroundMusicPlayer.volume + 0.005;
        [self performSelector:@selector(fadeVolumeIn) withObject:nil afterDelay:0.1];
    }
}

-(void)fadeVolumeOut {
    //NSLog(@"backgroundMusicPlayer.volume: %f", backgroundMusicPlayer.volume);
    if (gameOver && (backgroundMusicPlayer.volume > 0)) {
        //NSLog(@"fade out");
        if ((backgroundMusicPlayer.volume - 0.05) < 0) {
            if (!restartGameNotificationSent) {
                restartGameNotificationSent = true;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"restart game" object:nil];
            }
            //NSLog(@"nullify the background music");
            backgroundMusicPlayer = nil;
            
        }
        backgroundMusicPlayer.volume = backgroundMusicPlayer.volume - 0.05;
        [self performSelector:@selector(fadeVolumeOut) withObject:nil afterDelay:0.1];
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!player && !gameOver && !logoLabel) {
        [self createPlayer];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"dismiss logo" object:nil];
        in_game = true;
        //return;
    }
    
    player.touchesEnded = false;
    UITouch* touch = [touches anyObject];
    CGPoint positionInSelf = [touch locationInNode:self];
    previousPoint = currentPoint = initialTouchPoint = positionInSelf;
    
    if (player) {
        Line *currentLine = [arrayOfLines lastObject];
        for (Terrain* ter in currentLine.terrainArray) {
            //NSLog(@"ter.color: %@", ter.color);
            //
            for (SKSpriteNode* deco in ter.decos) {
                SKAction *fadeAction = [SKAction fadeAlphaTo:0.75f duration:1];
                [deco runAction:fadeAction];
            }
            
            SKAction *fadeAction = [SKAction fadeAlphaTo:0.75f duration:1];
            [ter runAction:fadeAction];
        }
        Line *newLine = [[Line alloc] initWithTerrainNode:_terrain :self.size];
        [arrayOfLines addObject:newLine];
        
        if (tutorial_mode_on && popup_engaged) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"remove popup" object:nil];
            self.view.paused = false;
        }
    }
    
    
    
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    CGPoint locInSelf = [touch locationInNode:self];
    
//    if (!in_game) {
//        float y_difference = locInSelf.y - initialTouchPoint.y;
//        float absolute_x_difference = fabs(locInSelf.x - initialTouchPoint.x);
//        
//        if (!gameOver) {
//            if (absolute_x_difference < ALLOWABLE_X_DIFFERENCE) {
//                if (y_difference > Y_THRESHOLD_FOR_SWITCH_LEVEL) {
//                    //gameOver = true;
//                    [self loadNextLevel];
//                }
//                if (y_difference < -Y_THRESHOLD_FOR_SWITCH_LEVEL) {
//                    //gameOver = true;
//                    [self loadPreviousLevel];
//                }
//            }
//        }
//    }

    
    currentPoint = locInSelf;

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
    
//    SKAction* logoFadeOut = [SKAction fadeOutWithDuration:1];
//    [logoLabel runAction:logoFadeOut completion:^{[logoLabel removeFromParent];}];
    

}

-(void)createLineNode{
    Line *currentLine = [arrayOfLines lastObject];
    NSMutableArray *currentPointArray = currentLine.nodeArray;
    
//    for (int i = (int)currentPointArray.count - 1; (i >= 0) && (i > currentPointArray.count - 1 - 5); i --) {
//        NSValue* node = [currentPointArray objectAtIndex:i];
//        float nodeXPos = [node CGPointValue].x;
//        if (currentPoint.x < nodeXPos) {
//            return;
//        }
//    }
    CGPoint lastPoint = [(NSValue*)[currentPointArray lastObject] CGPointValue];
    if (lastPoint.x > currentPoint.x) {
        return;
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

-(void)update:(CFTimeInterval)currentTime {
    if (tutorial_mode_on) {
        
        if (!found_first_obstacle) {
            [self tutorialCheckForFirstObstacle];
        }
        if (!passed_first_obstacle) {
            [self tutorialCheckForFirstEvasion];
        }
        
    }

    [self checkForOldLines];
    [self deallocOldLines];
    if (!player.touchesEnded) {
        [self createLineNode];
    }
    [self tellObstaclesToMove];
    if (!gameOver) {
        [self checkForWonGame];
        [self checkForLostGame];
    }
    if (player && !gameOver) {
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
    gameOver = true;
    [self performSunset];
    [self fadeVolumeOut];
//    if (!restartGameNotificationSent) {
//        restartGameNotificationSent = true;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"restart game" object:nil];
//    }

   // self.view.paused = true;
}

-(void)winGame{
    gameOver = true;
    [self performSunset];
    [self fadeVolumeOut];
//    if (!restartGameNotificationSent) {
//        restartGameNotificationSent = true;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"restart game" object:nil];
//    }
}

-(void)checkForWonGame{
    if (player.position.x > self.size.width + player.size.width / 2) {
        [self loadNextLevel];
    }
}

-(void)tellObstaclesToMove{
    for (Obstacle* obs in _obstacles.children) {
        [obs move];
    }
}



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

-(void)tutorialCheckForFirstObstacle{
    Obstacle *obs = [_obstacles.children firstObject];
    CGPoint obsPositionInView = [self.view convertPoint:[self convertPoint:obs.position fromNode:_obstacles] fromScene:self];

    if (obsPositionInView.x < (self.view.bounds.size.width * 3/4)) {
        found_first_obstacle = true;
        popup_engaged = true;
        self.view.paused = true;
        NSMutableDictionary* popupDict = [NSMutableDictionary dictionary];
        [popupDict setValue:@"Avoid the masks!" forKey:@"popup text"];
        [popupDict setValue:[NSValue valueWithCGPoint:CGPointMake(obsPositionInView.x, obsPositionInView.y + 100)] forKey:@"popup position"];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"add popup" object:nil userInfo:popupDict];
    }
        
}

-(void)tutorialCheckForFirstEvasion{
    Obstacle *obs = [_obstacles.children firstObject];
    CGPoint obsPositionInView = [self.view convertPoint:[self convertPoint:obs.position fromNode:_obstacles] fromScene:self];

    //CGPoint playerPositionInView = [self.view convertPoint:player.position fromScene:self];
    
    if (obsPositionInView.x < 0) {
        passed_first_obstacle = true;
        popup_engaged = true;
        self.view.paused = true;
        NSMutableDictionary* popupDict = [NSMutableDictionary dictionary];
        [popupDict setValue:@"Great! Now run to the end of the level." forKey:@"popup text"];
        [popupDict setValue:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))] forKey:@"popup position"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"add popup" object:nil userInfo:popupDict];
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

            for (Terrain* ter in line.terrainArray) {
                float fractionalCoefficient = ter.zPosition / _constants.OBSTACLE_Z_POSITION;
                CGVector parallaxAdjustedDifference = CGVectorMake(fractionalCoefficient * differenceInPreviousAndCurrentPlayerPositions.dx, fractionalCoefficient * differenceInPreviousAndCurrentPlayerPositions.dy * _constants.Y_PARALLAX_COEFFICIENT);
                ter.position = CGPointMake(ter.position.x - parallaxAdjustedDifference.dx, ter.position.y);
//
            }
        }
        
        _obstacles.position = CGPointMake(_obstacles.position.x - differenceInPreviousAndCurrentPlayerPositions.dx, _obstacles.position.y);
        
        //NSLog(@"[_obstacles calculateAccumulatedFrame].origin.x: %f", [_obstacles calculateAccumulatedFrame].origin.x);
        //NSLog(@"self.size.width: %f", self.size.width);
        
        for (SKSpriteNode* deco in _decorations.children) {
            if ([deco.name isEqualToString:@"rightMostNode"]) {
                CGPoint posInScene = [self convertPoint:CGPointMake(CGRectGetMaxX(deco.frame), deco.position.y) fromNode:_decorations];
                if (posInScene.x <= self.size.width){
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
