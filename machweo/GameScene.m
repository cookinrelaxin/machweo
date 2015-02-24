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

typedef enum TimesOfDay
{
    AM_8
} TimeOfDay;

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
    NSMutableArray* backgroundPool;
    NSMutableArray* previousChunks;
    NSMutableDictionary* textureDict;
    

    
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
    BOOL chunkLoading;
    //Obstacle* firstObstacle;
    
    TimeOfDay currentTimeOfDay;


    
    
    
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
        
//        logoLabel = [SKLabelNode labelNodeWithFontNamed:_constants.LOGO_LABEL_FONT_NAME];
//        logoLabel.fontSize = _constants.LOGO_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dx;
//        //logoLabel.fontColor = _constants.LOGO_LABEL_FONT_COLOR;
//        logoLabel.fontColor = [UIColor colorWithRed:243.0f/255.0f green:126.0f/255.0f blue:61.0f/255.0f alpha:1];
//        //logoLabel.fontColor = [UIColor redColor];
//        logoLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
//        logoLabel.zPosition = _constants.HUD_Z_POSITION;
//        logoLabel.text = @"MACHWEO";
//        //logoLabel.text = levelName;
//        [self addChild:logoLabel];
//        //SKAction* logoFadeIn = [SKAction fadeInWithDuration:1];
//        logoLabel.alpha = 0.0f;
//        SKAction* logoFadeIn = [SKAction fadeAlphaTo:1.0f duration:1];
//        [logoLabel runAction:logoFadeIn completion:^{
//            SKAction* logoFadeOut = [SKAction fadeAlphaTo:0.0f duration:.5];
//            [logoLabel runAction:logoFadeOut completion:^{
//                //NSLog(@"fade in again");
//                logoLabel.text = levelName;
//                SKAction* logoFadeInAgain = [SKAction fadeAlphaTo:1.0f duration:1];
//                [logoLabel runAction:logoFadeInAgain completion:^{
//                    SKAction* logoFadeOut = [SKAction fadeOutWithDuration:1];
//                    [logoLabel runAction:logoFadeOut completion:^{
//                        [logoLabel removeFromParent];
//                        logoLabel = nil;
//                        if ([levelName isEqualToString:[_constants.LEVEL_ARRAY firstObject]]) {
//                            tutorial_mode_on = true;
//                            
//                            NSMutableDictionary* popupDict = [NSMutableDictionary dictionary];
//                            [popupDict setValue:@"draw a path with your finger" forKey:@"popup text"];
//                            [popupDict setValue:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))] forKey:@"popup position"];
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"add popup" object:nil userInfo:popupDict];
//                            
//                            popup_engaged = true;
//                        }
//
//                    }];
//                }];
//            }];
//        }];

        ChunkLoader *cl = [[ChunkLoader alloc] initWithFile:levelName];
        terrainPool = [NSMutableArray array];
        previousChunks = [NSMutableArray array];
       // NSMutableArray* bucket = [NSMutableArray array];
        //[previousChunkBuckets addObject:bucket];
        [cl loadWorld:self withObstacles:_obstacles andDecorations:_decorations andBucket:previousChunks withinView:view andLines:arrayOfLines andTerrainPool:terrainPool withXOffset:0];
        
        backgroundPool = [NSMutableArray array];
        textureDict = _constants.TEXTURE_DICT;
        currentTimeOfDay = AM_8;
        [self generateBackgrounds];

        [self performSunrise];
        [self startMusic];
        [self setupObservers];

        
        
        
        
    }
    return self;
}

-(void)setupObservers{
    __weak GameScene *weakSelf = self;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserverForName:@"allow dismiss popup"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         weakSelf.allowDismissPopup = true;
     }];
}

-(void)generateBackgrounds{
    // assume for now that we should load four backgrounds at a time
    //something like if the right edge of the first entry in backgroundPool isnt visible on the screen, remove it and add a new background
    SKSpriteNode* firstBackground = [backgroundPool firstObject];
    if (firstBackground) {
        //NSLog(@"firstBackground");
        CGPoint positionInView = [self convertPoint:firstBackground.position fromNode:_decorations];
        float rightEdgeOfFirstBackground = positionInView.x + (firstBackground.size.width / 2);
        if (rightEdgeOfFirstBackground < 0) {
            NSLog(@"(rightEdgeOfFirstBackground < 0)");
            NSString* backgroundName;
            switch (currentTimeOfDay) {
                case AM_8:
                    backgroundName = @"AM_8";
                    break;
            }
            
            SKTexture *backgroundTexture = [_constants.TEXTURE_DICT objectForKey:backgroundName];
            if (backgroundTexture == nil) {
                backgroundTexture = [SKTexture textureWithImageNamed:backgroundName];
                [textureDict setValue:backgroundTexture forKey:backgroundName];
            }
            
            SKSpriteNode* lastBackground = [backgroundPool lastObject];
            SKSpriteNode* background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
            background.zPosition = _constants.BACKGROUND_Z_POSITION;
            background.size = CGSizeMake(background.size.width * _constants.SCALE_COEFFICIENT.dy, background.size.height * _constants.SCALE_COEFFICIENT.dy);
            background.position = CGPointMake(background.size.width + lastBackground.position.x, self.size.height / 2);
            [_decorations addChild:background];
            [backgroundPool removeObject:firstBackground];
            [backgroundPool addObject:background];
        }
    }
    else{
        

        NSString* backgroundName;
        switch (currentTimeOfDay) {
            case AM_8:
                backgroundName = @"AM_8";
                break;
        }
        
        SKTexture *backgroundTexture = [_constants.TEXTURE_DICT objectForKey:backgroundName];
        if (backgroundTexture == nil) {
            backgroundTexture = [SKTexture textureWithImageNamed:backgroundName];
            [textureDict setValue:backgroundTexture forKey:backgroundName];
        }
        
        if (backgroundTexture) {
            for (int i = 1; i < _constants.NUMBER_OF_BACKGROUND_SIMUL; i ++) {
                SKSpriteNode* background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
                background.zPosition = _constants.BACKGROUND_Z_POSITION;
                background.position = CGPointMake(i * (backgroundTexture.size.width / 2), self.size.height / 2);
                background.size = CGSizeMake(background.size.width * _constants.SCALE_COEFFICIENT.dy, background.size.height * _constants.SCALE_COEFFICIENT.dy);
                background.position = CGPointMake(background.position.x * _constants.SCALE_COEFFICIENT.dy, background.position.y);
                [_decorations addChild:background];
                [backgroundPool addObject:background];
            }
            
        }
    }
    
}

-(void)performSunrise{
    sunNode = [SKSpriteNode spriteNodeWithImageNamed:@"sun_decoration"];
    [self addChild:sunNode];
    sunNode.size = CGSizeMake(sunNode.size.width * _constants.SCALE_COEFFICIENT.dy, sunNode.size.height * _constants.SCALE_COEFFICIENT.dy);
    sunNode.zPosition = _constants.SUN_AND_MOON_Z_POSITION;
    sunNode.position = CGPointMake(self.position.x + self.size.width / 2, 0 - (sunNode.size.height / 2));
    SKAction* sunriseAction = [SKAction moveToY:(self.size.height - (sunNode.size.height / 2))  duration:2.0f];
    [sunNode runAction:sunriseAction];
    
}

-(void)performSunset{
    SKAction* sunsetAction = [SKAction moveToY:(0 - (sunNode.size.height / 2))  duration:2.0f];
    [sunNode runAction:sunsetAction];
}

//-(void)loadPreviousLevel{
//    
//    Constants* constants = [Constants sharedInstance];
//    NSMutableArray* levelArray = constants.LEVEL_ARRAY;
//    int newIndex = constants.CURRENT_INDEX_IN_LEVEL_ARRAY - 1;
//    if ((newIndex >= 0) && (newIndex < levelArray.count)) {
//        constants.CURRENT_INDEX_IN_LEVEL_ARRAY --;
//        //NSLog(@"loadPreviousLevel");
//        [self winGame];
//    }
//}
//
//-(void)loadNextLevel{
//    Constants* constants = [Constants sharedInstance];
//    NSMutableArray* levelArray = constants.LEVEL_ARRAY;
//    int newIndex = constants.CURRENT_INDEX_IN_LEVEL_ARRAY + 1;
//    if ((newIndex >= 0) && (newIndex < levelArray.count)) {
//        constants.CURRENT_INDEX_IN_LEVEL_ARRAY ++;
//        //NSLog(@"loadNextLevel");
//        [self winGame];
//    }
//}

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
                //restartGameNotificationSent = true;
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"restart game" object:nil];
                [self restartGame];
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
//        Line *currentLine = [arrayOfLines lastObject];
//        for (Terrain* ter in currentLine.terrainArray) {
            //NSLog(@"ter.color: %@", ter.color);
            //
//            for (SKSpriteNode* deco in ter.decos) {
//                SKAction *fadeAction = [SKAction fadeAlphaTo:0.75f duration:1];
//                [deco runAction:fadeAction];
//            }
//            
//            SKAction *fadeAction = [SKAction fadeAlphaTo:0.75f duration:1];
//            [ter runAction:fadeAction];
//        }
        Line *newLine = [[Line alloc] initWithTerrainNode:_terrain :self.size];
        [arrayOfLines addObject:newLine];
        
        if (tutorial_mode_on && popup_engaged && _allowDismissPopup) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"remove popup" object:nil];
            self.view.paused = false;
            _allowDismissPopup = false;
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
    [self checkForLastObstacle];
    [self generateBackgrounds];
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
    [self drawLines];
}

-(void)checkForLastObstacle{
    if (!chunkLoading) {
        
        Obstacle* lastObstacle = [_obstacles.children lastObject];
        CGPoint lastObstaclePosInSelf = [self convertPoint:lastObstacle.position fromNode:_obstacles];
        //NSLog(@"lastObstaclePos: %f, %f", lastObstacle.position.x, lastObstacle.position.y);
        //NSLog(@"lastObstaclePosInSelf: %f, %f", lastObstaclePosInSelf.x, lastObstaclePosInSelf.y);

        CGPoint lastObstaclePosInView = [self.view convertPoint:lastObstaclePosInSelf fromScene:self];
        //if (lastObstaclePosInView.x < (self.view.bounds.size.width * 3/4)) {
          if (lastObstaclePosInView.x < self.view.bounds.size.width) {
            //NSLog(@"lastObstacle: %@", lastObstacle);

            //NSLog(@"(lastObstaclePosInView.x < (self.view.bounds.size.width * 3/4))");
            NSMutableArray* levelArray = _constants.LEVEL_ARRAY;
            int newIndex = _constants.CURRENT_INDEX_IN_LEVEL_ARRAY + 1;
            //NSLog(@"newIndex: %i", newIndex);
            //NSLog(@"levelArray.count: %i", levelArray.count);

            if ((newIndex >= 0) && (newIndex < levelArray.count)) {
                _constants.CURRENT_INDEX_IN_LEVEL_ARRAY ++;
                NSLog(@"load next chunk");
                NSString* nextChunk = [_constants.LEVEL_ARRAY objectAtIndex:newIndex];
                NSLog(@"next chunk: %@", nextChunk);
                //NSLog(@"lastObstaclePosInSelf: %f, %f", lastObstaclePosInSelf.x, lastObstaclePosInSelf.y);
                //if (previousChunks.count > 1) {
                    
                    NSMutableArray* trash = [NSMutableArray array];
                    for (SKSpriteNode* sprite in previousChunks) {
                        CGPoint posInSelf = [self convertPoint:CGPointMake(sprite.position.x + (sprite.size.width / 2), sprite.position.y) fromNode:sprite.parent];
                        if (posInSelf.x > 0) {
                            continue;
                        }
                        
                        [sprite removeFromParent];
                        [trash addObject:sprite];
                    }
                    for (SKSpriteNode* sprite in trash) {
                        //NSLog(@"sprite: %@", sprite);
                        [previousChunks removeObject:sprite];
                    }
                    trash = nil;
                //}
                chunkLoading = true;
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                    ChunkLoader *cl = [[ChunkLoader alloc] initWithFile:nextChunk];
                    //dispatch_sync(dispatch_get_main_queue(), ^{
                        [cl loadWorld:self withObstacles:_obstacles andDecorations:_decorations andBucket:previousChunks withinView:self.view andLines:arrayOfLines andTerrainPool:terrainPool withXOffset:lastObstaclePosInSelf.x];
                        chunkLoading = false;
                    //});
                });
                
                
                //[self winGame];
            }
            else{
                stopScrolling = true;
            }
            
        }
    }
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
-(void)checkForWonGame{
    if (player.position.x > self.size.width + player.size.width / 2) {
        //[self loadNextLevel];
    }
}


-(void)loseGame{
    gameOver = true;
    [self performSunset];
    [self fadeVolumeOut];
    //_constants.CURRENT_INDEX_IN_LEVEL_ARRAY = 0;
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
    //_constants.CURRENT_INDEX_IN_LEVEL_ARRAY = 0;

//    if (!restartGameNotificationSent) {
//        restartGameNotificationSent = true;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"restart game" object:nil];
//    }
}



-(void)tellObstaclesToMove{
    for (Obstacle* obs in _obstacles.children) {
        [obs move];
    }
}



-(void)restartGame{
    //self.view.paused = false;
    restartGameNotificationSent = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restart game" object:nil];

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
        [popupDict setValue:[NSValue valueWithCGPoint:CGPointMake(obsPositionInView.x, obsPositionInView.y + 50)] forKey:@"popup position"];

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
            float fractionalCoefficient = deco.zPosition / _constants.OBSTACLE_Z_POSITION;
            CGVector parallaxAdjustedDifference = CGVectorMake(fractionalCoefficient * differenceInPreviousAndCurrentPlayerPositions.dx, fractionalCoefficient * differenceInPreviousAndCurrentPlayerPositions.dy * _constants.Y_PARALLAX_COEFFICIENT);
            deco.position = CGPointMake(deco.position.x - parallaxAdjustedDifference.dx, deco.position.y - parallaxAdjustedDifference.dy);
        }
    }
    
}



@end
