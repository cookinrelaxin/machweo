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
#import "WorldStreamer.h"
#import "Score.h"
#import "AnimationComponent.h"
#import <AVFoundation/AVFoundation.h>

int Y_THRESHOLD_FOR_SWITCH_LEVEL = 40;
int ALLOWABLE_X_DIFFERENCE = 10;
//from 1 to 16
int TENGGRI_COUNT = 16;
int RAW_SKY_WIDTH = 8192; // pixels
//int DIURNAL_PERIOD = 90; //seconds
//int LUNAR_PERIOD = 40; //seconds
int DIURNAL_PERIOD = 120; //seconds
int LUNAR_PERIOD = 70; //seconds





@implementation GameScene{
    Player *player;
    CGPoint previousPoint;
    CGPoint currentPoint;
    ButsuLiKi *physicsComponent;
    AnimationComponent *animationComponent;

    NSMutableArray *arrayOfLines;
    CGPoint currentDesiredPlayerPositionInView;
    //Score* playerScore;
    //Obstacle* nextObstacle;
    
    NSMutableArray* previousChunks;
    NSMutableDictionary* skyDict;
    NSMutableArray* skyPool;
    
    BOOL gameWon;
    BOOL restartGameNotificationSent;
    BOOL gameOver;
    BOOL in_game;
    
    SKLabelNode* logoLabel;
    SKSpriteNode* sunNode;
    SKSpriteNode* moonNode;

    
    AVAudioPlayer* backgroundMusicPlayer;
    
    CGPoint initialTouchPoint;
    
    BOOL tutorial_mode_on;
    BOOL found_first_obstacle;
    BOOL passed_first_obstacle;
    BOOL popup_engaged;
    //BOOL chunkLoading;
    
    TimeOfDay currentTimeOfDay;
    NSUInteger distance_traveled;
    
    float previousPlayerXPosition_hypothetical;
    float currentPlayerXPosition_hypothetical;
    
    SKLabelNode* distanceLabel;
    
    WorldStreamer* worldStreamer;
    
    float skyWidth;
    NSUInteger currentIndexInTenggri;
    float sky_displacement_coefficient;
    BOOL sunPathAdjusted;
    CGPoint centerOfSolarOrbit;
    float radiusOfSolarOrbit;

    CGPoint previousSunPos;
    SKSpriteNode* sunPanel;

    
}

-(void)dealloc{
    backgroundMusicPlayer = nil;
    NSLog(@"dealloc game scene");
}

-(instancetype)initWithSize:(CGSize)size withinView:(SKView*)view{
    if (self = [super initWithSize:size]){
        //playerScore = [[Score alloc] init];
        _constants = [Constants sharedInstance];
        //skyWidth = RAW_SKY_WIDTH * _constants.SCALE_COEFFICIENT.dy;
        skyWidth = RAW_SKY_WIDTH;
        //NSLog(@"skyWidth: %f", skyWidth);
        //sky_displacement_per_frame = SKY_WIDTH / (60 * DIURNAL_PERIOD);
        //NSLog(@"sky_displacement_per_frame: %d", sky_displacement_per_frame);

        _obstacles = [SKNode node];
        _terrain = [SKNode node];
        _decorations = [SKNode node];
        _skies = [SKNode node];
        [self addChild:_obstacles];
        [self addChild:_terrain];
        [self addChild:_decorations];
        [self addChild:_skies];

        physicsComponent = [[ButsuLiKi alloc] init];
        animationComponent = [[AnimationComponent alloc] initAnimationDictionary];
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
//
//                        if ([levelName isEqualToString:[_constants.LEVEL_ARRAY firstObject]]) {
//                            tutorial_mode_on = true;
//                            
//                            NSMutableDictionary* popupDict = [NSMutableDictionary dictionary];
//                            [popupDict setValue:@"Draw a path for Maasai, and don't let him touch the ground!" forKey:@"popup text"];
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

        //ChunkLoader *cl = [[ChunkLoader alloc] initWithFile:levelName];
        //[cl loadWorld:self withObstacles:_obstacles andDecorations:_decorations andBucket:previousChunks withinView:view andLines:arrayOfLines andTerrainPool:terrainPool withXOffset:0];
        
        
        skyDict = [NSMutableDictionary dictionary];
        skyPool = [NSMutableArray array];
        currentTimeOfDay = AM_8;
        worldStreamer = [[WorldStreamer alloc] initWithWorld:self withObstacles:_obstacles andDecorations:_decorations withinView:view andLines:arrayOfLines withXOffset:0 andTimeOfDay:currentTimeOfDay];
        [self generateBackgrounds :false];

        [self organizeTheHeavens];
        [self startMusic];
        [self setupObservers];
        
        distanceLabel = [SKLabelNode labelNodeWithFontNamed:_constants.DISTANCE_LABEL_FONT_NAME];
        distanceLabel.fontSize = _constants.DISTANCE_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dy;
        distanceLabel.fontColor = _constants.DISTANCE_LABEL_FONT_COLOR;
        distanceLabel.position = CGPointMake(CGRectGetMidX(self.frame), distanceLabel.fontSize / 4);
        distanceLabel.zPosition = _constants.HUD_Z_POSITION;
        distanceLabel.text = @"0";
        distanceLabel.hidden = true;
        [self addChild:distanceLabel];
        
//        CGColorRef filterColor = [UIColor colorWithHue:1 saturation:1 brightness:1 alpha:1].CGColor;
//        CIColor *convertedColor = [CIColor colorWithCGColor:filterColor];
//        // CIColor *filterColor = [CIColor color]
//        CIFilter* bloomFilter = [CIFilter filterWithName:@"CIBloom"];
//        [bloomFilter setValue:[CIImage imageWithColor:convertedColor] forKey:kCIInputImageKey];
//        [bloomFilter setValue:@(50.0) forKey:@"inputRadius"];
//        [bloomFilter setValue:@(2.0) forKey:@"inputIntensity"];
//
//       // SKEffectNode* bloomEffect = [SKEffectNode node];
//       // bloomEffect.filter = bloomFilter;
//        //bloomEffect.shouldEnableEffects = true;
//
//        self.filter = bloomFilter;
//        self.shouldEnableEffects = true;
        
//        CGColorRef filterColor = [UIColor colorWithHue:1 saturation:1 brightness:1 alpha:1].CGColor;
//        CIColor *convertedColor = [CIColor colorWithCGColor:filterColor];
//        // CIColor *filterColor = [CIColor color]
//        CIFilter* pixellateFilter = [CIFilter filterWithName:@"CIPixellate"];
//        [pixellateFilter setValue:[CIImage imageWithColor:convertedColor] forKey:kCIInputImageKey];
//        [pixellateFilter setValue:@(20.00) forKey:@"inputScale"];
//
//        self.filter = pixellateFilter;
//        self.shouldEnableEffects = true;
        
        //CGColorRef filterColor = [UIColor colorWithHue:1 saturation:1 brightness:1 alpha:1].CGColor;
        //CIColor *convertedColor = [CIColor colorWithCGColor:filterColor];
        // CIColor *filterColor = [CIColor color]
        //CIFilter* blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
        //[blurFilter setValue:[CIImage imageWithColor:convertedColor] forKey:kCIInputImageKey];
        //[blurFilter setValue:@(10.00) forKey:@"inputRadius"];

        //self.filter = blurFilter;
        //self.shouldEnableEffects = true;
        
        

        
        
        
        
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
    
    [center addObserverForName:@"stop scrolling"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         weakSelf.stopScrolling = true;
     }];
}

-(void)generateBackgrounds:(BOOL)forceLoad{
    // assume for now that we should load four backgrounds at a time
    //something like if the right edge of the first entry in backgroundPool isnt visible on the screen, remove it and add a new background
    SKSpriteNode* firstBackground = [skyPool firstObject];
    if (firstBackground || forceLoad) {
        //NSLog(@"firstBackground");
        CGPoint positionInScene = [self convertPoint:firstBackground.position fromNode:_skies];
        float leftEdgeOfFirstBackground = positionInScene.x - (firstBackground.size.width / 2);
        //NSLog(@"rightEdgeOfFirstBackground: %f", rightEdgeOfFirstBackground);
        if ((leftEdgeOfFirstBackground > self.size.width) || forceLoad) {
           // NSLog(@"(rightEdgeOfFirstBackground < 0)");
            NSString* tenggriCountString = (currentIndexInTenggri < 10) ? [NSString stringWithFormat:@"0%lu", currentIndexInTenggri] : [NSString stringWithFormat:@"%lu", currentIndexInTenggri];
            
            NSString* backgroundName = [NSString stringWithFormat:@"tenggriPS_%@", tenggriCountString];
            SKSpriteNode* background = [skyDict valueForKey:backgroundName];
            if (!background) {
                background = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:backgroundName]];
                [skyDict setValue:background forKey:backgroundName];
            }
            
            SKSpriteNode* lastBackground = [skyPool lastObject];

            

            background.zPosition = _constants.BACKGROUND_Z_POSITION;
            background.size = CGSizeMake(background.size.width, background.size.height * _constants.SCALE_COEFFICIENT.dy);
            if (!lastBackground) {
                background.position = CGPointMake(self.size.width - (background.size.width / 2), self.size.height / 2);
            }
            else{
                background.position = CGPointMake((lastBackground.position.x - lastBackground.size.width / 2) - (background.size.width / 2), self.size.height / 2);
            }
            if (!background.parent) {
                [_skies addChild:background];
            }
            if (!forceLoad) {
                [skyPool removeObject:firstBackground];
            }
            [skyPool addObject:background];
            
            currentIndexInTenggri --;
            if (currentIndexInTenggri < 1) {
                currentIndexInTenggri = TENGGRI_COUNT;
            }
        }
    }
    else{
        
        currentIndexInTenggri = [self calculateInitialSkyImageIndex];
        
        // there are 16 sky images / tenggri in 16 parts
        for (int i = 16; i >= 1; i --) {
//            NSString* tenggriCountString = (currentIndexInTenggri < 10) ? [NSString stringWithFormat:@"0%lu", currentIndexInTenggri] : [NSString stringWithFormat:@"%lu", currentIndexInTenggri];
//            NSString* backgroundName = [NSString stringWithFormat:@"tenggriPS_%@", tenggriCountString];
//            SKTexture * tex = [SKTexture textureWithImageNamed:backgroundName];
//            [skyDict setValue:tex forKey:backgroundName];
            [self generateBackgrounds :true];


        }
        return;
        
    }
    
}

-(void)fadeMoon{
    float sunY = [self convertPoint:sunNode.position fromNode:sunNode.parent].y;
    if (sunY > 0) {
        if (moonNode.alpha == 1) {
            [moonNode runAction:[SKAction fadeAlphaTo:0 duration:3]];
        }
    }
    
    if (sunY < 0) {
        if (moonNode.alpha == 0) {
            [moonNode runAction:[SKAction fadeAlphaTo:1 duration:3]];
        }
    }
}


// this method is absolutely unacceptable right now
-(NSUInteger)calculateInitialSkyImageIndex{
    float time = [self getCurrentTime];
    NSUInteger roundedTime = (6 * floor((time / 6.0) + 0.5));
    NSUInteger index = 1;
    if ((roundedTime == 24) || (roundedTime == 0)) {
        index = 11;
    }
    if (roundedTime == 6) {
        index = 8;
    }
    if (roundedTime == 12) {
        index = 2;
    }
    if (roundedTime == 18) {
        index = 14;
    }
    
    
    //NSLog(@"index:%lu", (unsigned long)index);
    //NSLog(@"roundedTime:%lu", (unsigned long)roundedTime);

    return index;
}

-(float)getCurrentTime{
    NSDateComponents *components = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    
    float time = (float)components.hour + (((float)components.minute) / 60.0);
    //NSLog(@"time: %f", time);
    return time;
}

-(float)calculateInitialSolarRotation{
    
    float time = [self getCurrentTime];
    float rotation = -((time * (M_PI / 12.0)) + M_PI_2);
    //NSLog(@"rotation: %f", rotation);
    return rotation;

}

-(void)organizeTheHeavens{
    {
        sunNode = [SKSpriteNode spriteNodeWithImageNamed:@"sun_decoration"];
        sunNode.size = CGSizeMake(sunNode.size.width * _constants.SCALE_COEFFICIENT.dy, sunNode.size.height * _constants.SCALE_COEFFICIENT.dy);


        sunPanel = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(self.size.width, self.size.height)];
        centerOfSolarOrbit = CGPointMake(self.size.width / 2, (sunNode.size.height / 2));
        sunPanel.position = centerOfSolarOrbit;
        sunPanel.zRotation =  [self calculateInitialSolarRotation];
        sunPanel.zPosition = _constants.SUN_AND_MOON_Z_POSITION;

        [self addChild:sunPanel];
        
        
        //sunNode.zPosition = _constants.SUN_AND_MOON_Z_POSITION;
        radiusOfSolarOrbit = self.size.height * .6;
        UIBezierPath *sunPath = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:radiusOfSolarOrbit startAngle:0 endAngle:2 * M_PI clockwise:NO];
        //UIBezierPath *sunPath = [UIBezierPath bezierPathWithArcCenter:centerOfSolarOrbit radius:radiusOfSolarOrbit startAngle:0 endAngle:2 * M_PI clockwise:NO];
        [sunPath closePath];
        SKAction* sunriseAction = [SKAction followPath:sunPath.CGPath asOffset:NO orientToPath:NO duration:DIURNAL_PERIOD];
        [sunNode runAction:[SKAction repeatActionForever:sunriseAction] completion:^{
        }];
        [sunPanel addChild:sunNode];
 

        //sunPathAdjusted = true;
        
        sky_displacement_coefficient = skyWidth / (2 * M_PI * radiusOfSolarOrbit);
    }
    
    {
        moonNode = [SKSpriteNode spriteNodeWithImageNamed:@"moon_decoration"];
        [self addChild:moonNode];
        moonNode.size = CGSizeMake(moonNode.size.width * _constants.SCALE_COEFFICIENT.dy, moonNode.size.height * _constants.SCALE_COEFFICIENT.dy);
        moonNode.zPosition = _constants.SUN_AND_MOON_Z_POSITION;
        UIBezierPath *moonPath = [UIBezierPath bezierPath];
        float moonOrbitRadius = self.size.height * .6;
        CGPoint moonOrbitCenter = CGPointMake(self.size.width / 2, moonNode.size.height / 2);
        [moonPath addArcWithCenter:moonOrbitCenter radius:moonOrbitRadius startAngle:0 endAngle:2 * M_PI clockwise:NO];
        SKAction* moonriseAction = [SKAction followPath:moonPath.CGPath asOffset:NO orientToPath:NO duration:LUNAR_PERIOD];
        [moonNode runAction:[SKAction repeatActionForever:moonriseAction] completion:^{
        }];
    }
    //[self setupSunAndMoonGlow];

}

-(void)performSunset{
    SKAction* sunsetAction = [SKAction moveToY:(0 - (sunNode.size.height / 2)) duration:2.0f];
    [sunNode runAction:sunsetAction];
}

-(void)startMusic{
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
        distanceLabel.hidden = false;
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"dismiss logo" object:nil];
        in_game = true;
        //return;
    }
    
    player.touchesEnded = false;
    UITouch* touch = [touches anyObject];
    CGPoint positionInSelf = [touch locationInNode:self];
    previousPoint = currentPoint = initialTouchPoint = positionInSelf;
    
    if (player) {
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
//    
//    [player runAction:[SKAction repeatActionForever:
//                      [SKAction animateWithTextures:animationComponent.runningFrames
//                                       timePerFrame:0.05f
//                                             resize:NO
//                                            restore:YES]] withKey:@"runningMaasai"];
//    
////    SKAction* logoFadeOut = [SKAction fadeOutWithDuration:1];
////    [logoLabel runAction:logoFadeOut completion:^{[logoLabel removeFromParent];}];
//    

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
        [ter generateDecorationAtVertex:newPoint fromTerrainPool:[worldStreamer getTerrainPool] inNode:_decorations withZposition:0 andSlope:((currentPoint.y - previousPoint.y) / (currentPoint.x - previousPoint.x))];
        
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
                [ter closeLoopAndFillTerrainInView:self.view withCurrentSunYPosition:[self convertPoint:sunNode.position fromNode:sunNode.parent].y minY:centerOfSolarOrbit.y - radiusOfSolarOrbit andMaxY:centerOfSolarOrbit.y + radiusOfSolarOrbit];
            }
        }
   // });
    }
}

-(void)updateDistanceLabelWithDistance:(NSUInteger)distance{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        NSString* distanceString = [NSString stringWithFormat:@"%lu m", (unsigned long)distance];
        dispatch_sync(dispatch_get_main_queue(), ^{
            distanceLabel.text = distanceString;
        });

    });
}

-(void)updateDistance{
//    if (previousTime == 0) {
//        previousTime = currentTime;
//    }
    currentPlayerXPosition_hypothetical += player.velocity.dx;
    
    double difference = currentPlayerXPosition_hypothetical - previousPlayerXPosition_hypothetical;
    if (difference > 50) {
        distance_traveled += 1;
        [self updateDistanceLabelWithDistance:distance_traveled];
        currentPlayerXPosition_hypothetical = previousPlayerXPosition_hypothetical;
    }
}

-(void)setDecoFilter{
    float maxY = centerOfSolarOrbit.y + radiusOfSolarOrbit;
    float minY = centerOfSolarOrbit.y - radiusOfSolarOrbit;
    float sunY = [self convertPoint:sunNode.position fromNode:sunNode.parent].y;
    
    float minBrightnessMultiplier = 1.0 / 5.0;
    float maxBrightnessMultiplier = 1.0;
    
    float brightness = sunY / maxY;
    float maxDistanceFromApex = maxY - minY;
    float distanceFromApex = maxY - sunY;
    float brightnessMultiplier = (distanceFromApex / maxDistanceFromApex) / 2.0;
    brightnessMultiplier = (brightnessMultiplier > maxBrightnessMultiplier) ? maxBrightnessMultiplier : brightnessMultiplier;
    brightnessMultiplier = (brightnessMultiplier < minBrightnessMultiplier) ? minBrightnessMultiplier : brightnessMultiplier;

    //NSLog(@"brightnessMultiplier: %f", brightnessMultiplier);
    brightness *= brightnessMultiplier;
    float minB = -.20;
    float maxB = .15;
    brightness = (brightness < minB) ? minB : brightness;
    brightness = (brightness > maxB) ? maxB : brightness;
    
    //NSLog(@"rawBrightness: %f", rawBrightness);
    //NSLog(@"brightness: %f", brightness);
    
    CGColorRef filterColor = [UIColor colorWithHue:1 saturation:0 brightness:0 alpha:1].CGColor;
    CIColor *convertedColor = [CIColor colorWithCGColor:filterColor];
   // CIColor *filterColor = [CIColor color]
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setValue:[CIImage imageWithColor:convertedColor] forKey:kCIInputImageKey];
    [lighten setValue:@(brightness) forKey:@"inputBrightness"];
    
    self.filter = lighten;
    self.shouldEnableEffects = true;
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
    [self setDecoFilter];
    [self updateDistance];
    [worldStreamer updateWithPlayerDistance:distance_traveled andTimeOfDay:currentTimeOfDay];
    [self generateBackgrounds :false];
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
        [self checkForNewAnimationState];
        [player resetMinsAndMaxs];
        [player updateEdges];
        [physicsComponent calculatePlayerPosition:player withLineArray:arrayOfLines];
    }
    [self drawLines];
    [self fadeMoon];
    
    float dX = sqrtf(powf(sunNode.position.x - previousSunPos.x, 2) + powf(sunNode.position.y - previousSunPos.y, 2));
    _skies.position = CGPointMake(_skies.position.x + (dX * sky_displacement_coefficient), _skies.position.y);
    previousSunPos = sunNode.position;
    
    //NSLog(@"_decorations.children.count: %lu", _decorations.children.count);
}

-(void)checkForNewAnimationState{
    if (player.roughlyOnLine && ![player actionForKey:@"runningMaasai"]) {
        [player removeAllActions];
        [player runAction:[SKAction repeatActionForever:
                           [SKAction animateWithTextures:animationComponent.runningFrames
                                            timePerFrame:0.04f
                                                  resize:NO
                                                 restore:YES]] withKey:@"runningMaasai"];
    }
    
    if (player.endOfLine && ![player actionForKey:@"jumpingMaasai"]) {
        
        [player removeAllActions];
        [player runAction:
                           [SKAction animateWithTextures:animationComponent.jumpingFrames
                                            timePerFrame:0.05f
                                                  resize:NO
                                                 restore:YES] withKey:@"jumpingMaasai"];
    }
    
    
}


-(void)checkForLostGame{

    if (player.physicsBody.allContactedBodies.count > 0) {
        [self loseGame];
//        NSMutableDictionary* popupDict = [NSMutableDictionary dictionary];
//        [popupDict setValue:@"Uh oh, you hit an obstacle. Try again!" forKey:@"popup text"];
//        [popupDict setValue:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))] forKey:@"popup position"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"add popup" object:nil userInfo:popupDict];

    }
    if (player.position.y < 0 - (player.size.height / 2)) {
        [self loseGame];
//        NSMutableDictionary* popupDict = [NSMutableDictionary dictionary];
//        [popupDict setValue:@"Oops! You fell off the path. That's ok, have another try." forKey:@"popup text"];
//        [popupDict setValue:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))] forKey:@"popup position"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"add popup" object:nil userInfo:popupDict];
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
    //[self performSunset];
    [self fadeVolumeOut];

}

-(void)winGame{
    gameOver = true;
    //[self performSunset];
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
        [line generateConnectingLinesInTerrainNode:_terrain withTerrainPool:[worldStreamer getTerrainPool] andDecoNode:_decorations :!player.touchesEnded];
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
        [popupDict setValue:@"Great! That's about it. Now see how far you can run!" forKey:@"popup text"];
        [popupDict setValue:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))] forKey:@"popup position"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"add popup" object:nil userInfo:popupDict];
    }
    
}



- (void)centerCameraOnPlayer {
    if (!_stopScrolling) {
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
