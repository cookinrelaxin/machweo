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
#import "Decoration.h"
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

float MAX_AUDIO_VOLUME = .25f;







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
    
    NSMutableArray* skyPool;
    NSMutableDictionary* skyDict;
    
    BOOL endGameNotificationSent;
    BOOL gameOver;
    BOOL in_game;
    BOOL player_created;
    BOOL paused;
    //BOOL obstacles
    
    //UI
        SKLabelNode* logoLabel;
        SKLabelNode* muteLabelButton;
        SKLabelNode* pauseButton;
        SKLabelNode* returnToGameLabelButton;
    
        SKLabelNode* pauseLabel;

        SKLabelNode* scoreLabel;
        SKLabelNode* highscoreLabel;
        SKLabelNode* shareLabelButton;
        SKLabelNode* leaderboardLabelButton;
        SKLabelNode* retryLabelButton;
    
    //
    
    
    SKSpriteNode* sunNode;
    SKSpriteNode* moonNode;

    
    AVAudioPlayer* backgroundMusicPlayer;
    
    BOOL tutorial_mode_on;
    BOOL found_first_obstacle;
    BOOL passed_first_obstacle;
    BOOL popup_engaged;
    
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
    
    CGPoint finalPlayerPosition;


    
}

-(void)dealloc{
    NSLog(@"dealloc game scene");
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

/*
 _world: <SKEffectNode> name:'(null)' shouldEnableEffects:'YES' filter:'nil' position:{0, 0} accumulatedFrame:{{-7063.177734375, -175.1185302734375}, {8192, 591.1185302734375}}
 
 _world: <SKNode> name:'(null)' position:{0, 0} accumulatedFrame:{{-7052.7900390625, -172.73086547851562}, {8192, 588.7308349609375}}
 */

-(instancetype)initWithSize:(CGSize)size withinView:(SKView*)view{
    if (self = [super initWithSize:size]){
        _constants = [Constants sharedInstance];
        skyWidth = RAW_SKY_WIDTH;
        _world = [[SKNode alloc] init];
        self.shouldEnableEffects = true;
        [self addChild:_world];
        _hud = [SKNode node];
        [self addChild:_hud];
        _obstacles = [SKNode node];
        _terrain = [SKNode node];
        _decorations = [[SKNode alloc] init];
        _skies = [SKNode node];
        [_world addChild:_obstacles];
        [_world addChild:_terrain];
        [_world addChild:_decorations];
        [_world addChild:_skies];

        physicsComponent = [[ButsuLiKi alloc] initWithSceneSize:self.size];
        animationComponent = [AnimationComponent sharedInstance];
        arrayOfLines = [NSMutableArray array];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        skyDict = _constants.SKY_DICT;
        skyPool = [NSMutableArray array];
        worldStreamer = [[WorldStreamer alloc] initWithScene:self withObstacles:_obstacles andDecorations:_decorations withinView:view andLines:arrayOfLines withXOffset:0];
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
        [_hud addChild:distanceLabel];
        player = [Player player];
        //[self createPlayer];
        
        [self createLogoLabel];
        [self createMuteButton];
        [self createPauseButton];
        [self createPausedLabel];
        
        paused = false;

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
    
    [center addObserverForName:@"restart"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         [weakSelf restart];
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
            NSString* tenggriCountString = (currentIndexInTenggri < 10) ? [NSString stringWithFormat:@"0%lu", currentIndexInTenggri] : [NSString stringWithFormat:@"%lu", (unsigned long)currentIndexInTenggri];
            
            NSString* backgroundName = [NSString stringWithFormat:@"tenggriPS_%@", tenggriCountString];
            SKSpriteNode* background = [skyDict valueForKey:backgroundName];
            
            SKSpriteNode* lastBackground = [skyPool lastObject];

            

            if (!lastBackground) {
                background.position = CGPointMake(self.size.width - (background.size.width / 2), self.size.height / 2);
            }
            else{
                background.position = CGPointMake((lastBackground.position.x - lastBackground.size.width / 2) - (background.size.width / 2), self.size.height / 2);
            }
            //if (!background.parent) {
                [background removeFromParent];
                [_skies addChild:background];
            //}
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
        SKTexture *spriteTexture = [_constants.TEXTURE_DICT objectForKey:@"sun_decoration"];
        if (spriteTexture) {
            sunNode = [SKSpriteNode spriteNodeWithTexture:spriteTexture];
        }

        //sunNode.size = CGSizeMake(sunNode.size.width * _constants.SCALE_COEFFICIENT.dy, sunNode.size.height * _constants.SCALE_COEFFICIENT.dy);


        sunPanel = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(self.size.width, self.size.height)];
        centerOfSolarOrbit = CGPointMake(self.size.width / 2, (sunNode.size.height / 2));
        sunPanel.position = centerOfSolarOrbit;
        sunPanel.zRotation =  [self calculateInitialSolarRotation];
        sunPanel.zPosition = _constants.SUN_AND_MOON_Z_POSITION;

        [_world addChild:sunPanel];
        
        
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
        SKTexture *spriteTexture = [_constants.TEXTURE_DICT objectForKey:@"moon_decoration"];
        if (spriteTexture) {
            moonNode = [SKSpriteNode spriteNodeWithTexture:spriteTexture];
        }
        [_world addChild:moonNode];
        //moonNode.size = CGSizeMake(moonNode.size.width * _constants.SCALE_COEFFICIENT.dy, moonNode.size.height * _constants.SCALE_COEFFICIENT.dy);
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

-(void)muteSounds{
    backgroundMusicPlayer.volume = 0;
}

-(void)unmuteSounds{
    backgroundMusicPlayer.volume = MAX_AUDIO_VOLUME;
}

-(void)fadeVolumeIn {
    if ((backgroundMusicPlayer.volume < MAX_AUDIO_VOLUME)) {
        //NSLog(@"fade in");
        backgroundMusicPlayer.volume += 0.005;
        //[self performSelector:@selector(fadeVolumeIn) withObject:nil afterDelay:0.1];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self fadeVolumeIn];
        });
    }
}

-(void)fadeVolumeOut {
    //NSLog(@"backgroundMusicPlayer.volume: %f", backgroundMusicPlayer.volume);
    if (gameOver && (backgroundMusicPlayer.volume > 0)) {
        //NSLog(@"fade out");
        if ((backgroundMusicPlayer.volume - 0.05) < 0) {
            if (!endGameNotificationSent) {
                [self endGame];
            }
            //NSLog(@"nullify the background music");
            backgroundMusicPlayer = nil;
            return;
            
        }
        backgroundMusicPlayer.volume = backgroundMusicPlayer.volume - 0.05;
        [self performSelector:@selector(fadeVolumeOut) withObject:nil afterDelay:0.1];
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"_world: %@", _world);
    //NSLog(@"_decorations.zPosition: %f", _decorations.zPosition);
    
    UITouch* touch = [touches anyObject];
    CGPoint positionInSelf = [touch locationInNode:self];
    
    if ([muteLabelButton containsPoint:positionInSelf]) {
        if (backgroundMusicPlayer.volume > 0) {
            [self muteSounds];
        }
        else{
            [self unmuteSounds];
        }
        return;
    }
    
    if (paused) {
        //paused = false;
        [self unpauseAndReturnToGame];
        return;
    }
    
    if ([pauseButton containsPoint:positionInSelf]) {
        [self pause];
        return;
    }
    
    
  
    
    if (!in_game && !gameOver && !logoLabel) {
        [worldStreamer enableObstacles];
        distanceLabel.hidden = false;
        in_game = true;
    }
    
    player.touchesEnded = false;
    previousPoint = currentPoint = positionInSelf;

   
    
    Line *newLine = [[Line alloc] initWithTerrainNode:_terrain :self.size];
    [arrayOfLines addObject:newLine];
    //NSLog(@"arrayOfLines.count: %lu", arrayOfLines.count);
    if (arrayOfLines.count > 2) {
        Line* firstLine = nil;
        for (Line* line in arrayOfLines) {
            if (!line.shouldDeallocNodeArray) {
                firstLine = line;
                break;
            }
        }
        for (Terrain* ter in firstLine.terrainArray) {
            for (Decoration *deco in ter.decos) {
                [deco runAction:[SKAction fadeOutWithDuration:1]];
            }
            firstLine.shouldDeallocNodeArray = true;

            [ter runAction:[SKAction fadeOutWithDuration:1] completion:^{
                [ter removeFromParent];
                [arrayOfLines removeObject:firstLine];
        
            }];

        }
    }
    
    if (tutorial_mode_on && popup_engaged && _allowDismissPopup) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"remove popup" object:nil];
        self.view.paused = false;
        _allowDismissPopup = false;
    }
    
    
    
}

-(void)pause{
    NSLog(@"pause");

    paused = true;
    SKAction *currentAnimation = [player actionForKey:@"runningMaasai"];
    if (!currentAnimation) {
        currentAnimation = [player actionForKey:@"jumpingMaasai"];
    }
    if (currentAnimation) {
        currentAnimation.speed = 0;
    }
    [pauseLabel runAction:[SKAction fadeAlphaTo:1 duration:.5]];
    pauseButton.hidden = true;
    
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"pause" object:nil];
}
             
-(void)unpauseAndReturnToGame{
    NSLog(@"unpause");
    [pauseLabel runAction:[SKAction fadeAlphaTo:0 duration:.5] completion:^{
        paused = false;
        pauseButton.hidden = false;
        SKAction *currentAnimation = [player actionForKey:@"runningMaasai"];
        if (!currentAnimation) {
            currentAnimation = [player actionForKey:@"jumpingMaasai"];
        }
        if (currentAnimation) {
            currentAnimation.speed = 1;
        }
    }];

}

-(void)restart{
    NSLog(@"restart");
    [self reset];
}

             

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    CGPoint locInSelf = [touch locationInNode:self];
    
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
    player_created = true;
    [self addChild:player];
    player.onGround = true;
    finalPlayerPosition = CGPointMake(self.view.bounds.origin.x + player.size.width / 2, [self convertPointToView:player.position].y);
    currentDesiredPlayerPositionInView = CGPointMake(self.size.width + player.size.width / 2, player.size.height / 2);
    [self setInitialAnimation];
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
        [ter generateDecorationAtVertex:newPoint fromTerrainPool:[worldStreamer getTerrainPool] inNode:_decorations withZposition:0 andSlope:((currentPoint.y - previousPoint.y) / (currentPoint.x - previousPoint.x))];
        
    }
    //[self removeLineIntersectionsBetween:previousPoint and:currentPoint];
    previousPoint = currentPoint;
    
}

//-(void)removeLineIntersectionsBetween:(CGPoint)a and:(CGPoint)b{
//    NSMutableArray* nodesToDeleteFromNodeArray = [NSMutableArray array];
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_apply(arrayOfLines.count, queue, ^(size_t i) {
//        Line* previousLine = [arrayOfLines objectAtIndex:i];
//   // for (Line *previousLine in arrayOfLines) {
//        if ((previousLine == arrayOfLines.lastObject) || previousLine.allowIntersections) {
//            return;
//        }
//        
//        NSMutableArray *previousPointArray = previousLine.nodeArray;
//        BOOL killTheRest = false;
//        for (NSValue* node in previousPointArray) {
//            CGPoint nodePosInScene = node.CGPointValue;
//
//            //yes, 50 is a magic number. but it is a necessary cushion.
//            if (killTheRest || (nodePosInScene.x >= a.x)) {
//                if (killTheRest || ((nodePosInScene.y <= a.y) && (nodePosInScene.y >= b.y)) || ((nodePosInScene.y >= a.y) && (nodePosInScene.y <= b.y))) {
//                    [nodesToDeleteFromNodeArray addObject:node];
//                    killTheRest = true;
//                }
//            }
//        }
//        for (NSValue* node in nodesToDeleteFromNodeArray) {
//            [previousPointArray removeObject:node];
//        }
//        });
//        
//   // }
//    
//}

-(void)drawLines{
    for (Line* line in arrayOfLines) {
        if (line.shouldDraw) {
            for (Terrain* ter in line.terrainArray) {
                [ter closeLoopAndFillTerrainInView:self.view withCurrentSunYPosition:[self convertPoint:sunNode.position fromNode:sunNode.parent].y minY:centerOfSolarOrbit.y - radiusOfSolarOrbit andMaxY:centerOfSolarOrbit.y + radiusOfSolarOrbit];
            }
        }
    }
}

-(void)updateDistanceLabelWithDistance:(NSUInteger)distance{
    NSString* distanceString = [NSString stringWithFormat:@"%lu m", (unsigned long)distance];
    distanceLabel.text = distanceString;
}

-(void)updateDistance{
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
    {
        CGColorRef filterColor = [UIColor colorWithHue:1 saturation:0 brightness:0 alpha:1].CGColor;
        CIColor *convertedColor = [CIColor colorWithCGColor:filterColor];
        CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
        [lighten setValue:[CIImage imageWithColor:convertedColor] forKey:kCIInputImageKey];
        
        self.filter = lighten;
    }
//    {
//        _world.zPosition = -1;
//        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
//        [filter setDefaults];
//        [filter setValue:@(10) forKey:@"inputRadius"]; // blur radius may change
//        _world.filter = filter;
//    }
}


-(void)update:(CFTimeInterval)currentTime {
//    [self fadeVolumeIn];
    [self setDecoFilter];
    [self generateBackgrounds :false];
    float dX = sqrtf(powf(sunNode.position.x - previousSunPos.x, 2) + powf(sunNode.position.y - previousSunPos.y, 2));
    _skies.position = CGPointMake(_skies.position.x + (dX * sky_displacement_coefficient), _skies.position.y);
    previousSunPos = sunNode.position;
    
    if (!paused) {
        
        if (tutorial_mode_on) {
            
            if (!found_first_obstacle) {
                [self tutorialCheckForFirstObstacle];
            }
            if (!passed_first_obstacle) {
                [self tutorialCheckForFirstEvasion];
            }
            
        }
        
        if (!player.touchesEnded) {
            [self createLineNode];
        }
        [self tellObstaclesToMove];
        if (!player_created) {
            [self createPlayer];
        }
        if (player_created && !gameOver) {
            if (in_game) {
                [self updateDistance];
                [self checkForLostGame];
            }
            [worldStreamer updateWithPlayerDistance:distance_traveled];
            [self centerCameraOnPlayer];
            [self checkForNewAnimationState];
            [player resetMinsAndMaxs];
            [player updateEdges];
            [physicsComponent calculatePlayerPosition:player withLineArray:arrayOfLines];
            [self drawLines];

        }
        [self fadeMoon];
        //NSLog(@"_decorations.children.count: %lu", _decorations.children.count);
    }
}

-(void)checkForNewAnimationState{
    if ((player.roughlyOnLine || player.onGround) && [player actionForKey:@"midAirMaasai"]) {
        [player removeAllActions];
        [player runAction:[SKAction repeatActionForever:
                           [SKAction animateWithTextures:animationComponent.runningFrames
                                            timePerFrame:0.04f
                                                  resize:NO
                                                 restore:YES]] withKey:@"runningMaasai"];
    }
    
    else if (player.endOfLine && ![player actionForKey:@"jumpingMaasai"] && ![player actionForKey:@"midAirMaasai"]) {
        
        [player removeAllActions];
        SKAction* jumpAction = [SKAction animateWithTextures:animationComponent.jumpingFrames
                                                timePerFrame:0.1f
                                                      resize:NO
                                                     restore:YES];
        //[player runAction:jumpAction withKey:@"jumpingMaasai"];
        SKAction* midAirAction = [SKAction repeatActionForever:
                                  [SKAction animateWithTextures:animationComponent.midairFrames
                                                   timePerFrame:0.05f
                                                         resize:NO
                                                        restore:YES]];
        
        //[player runAction:midAirAction withKey:@"jumpingMaasai"];
        [player runAction:[SKAction sequence:@[jumpAction, midAirAction]] withKey:@"jumpingMaasai"];
        
    }
    else if([player actionForKey:@"jumpingMaasai"]){
        [player removeAllActions];
        SKAction* midAirAction = [SKAction repeatActionForever:
        [SKAction animateWithTextures:animationComponent.midairFrames
                        timePerFrame:0.05f
                              resize:NO
                             restore:YES]];

        [player runAction:midAirAction withKey:@"midAirMaasai"];

    }
    
}

-(void)setInitialAnimation{
    [player runAction:[SKAction repeatActionForever:
                       [SKAction animateWithTextures:animationComponent.runningFrames
                                        timePerFrame:0.04f
                                              resize:NO
                                             restore:YES]] withKey:@"runningMaasai"];
    
}


-(void)checkForLostGame{

    if (player.physicsBody.allContactedBodies.count > 0) {
        [self loseGame];
//        NSMutableDictionary* popupDict = [NSMutableDictionary dictionary];
//        [popupDict setValue:@"Uh oh, you hit an obstacle. Try again!" forKey:@"popup text"];
//        [popupDict setValue:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))] forKey:@"popup position"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"add popup" object:nil userInfo:popupDict];

    }
}

-(void)loseGame{
    
    gameOver = true;
    //[self performSunset];
    [self fadeVolumeOut];
    //[self reset];
    pauseButton.hidden = true;
    muteLabelButton.hidden = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lose game" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:distance_traveled] forKey:@"distance"]];

}

-(void)tellObstaclesToMove{
    for (Obstacle* obs in _obstacles.children) {
        [obs moveWithScene:self];
    }
}



-(void)endGame{
    //self.view.paused = false;
    endGameNotificationSent = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"end game" object:nil];
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
        if (currentDesiredPlayerPositionInView.x > finalPlayerPosition.x) {
            currentDesiredPlayerPositionInView = CGPointMake(currentDesiredPlayerPositionInView.x - 2, [self convertPointToView:player.position].y);
        }
        else{
            currentDesiredPlayerPositionInView = CGPointMake(currentDesiredPlayerPositionInView.x, [self convertPointToView:player.position].y);
        }
        
        player.position = [self convertPointFromView:currentDesiredPlayerPositionInView];
        CGVector differenceInPreviousAndCurrentPlayerPositions = CGVectorMake(player.velocity.dx, 0);
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

-(void)reset{
    NSLog(@"reset");
    {
        [player removeFromParent];
        player = [Player player];
        player_created = false;

    }
    
    previousPoint = currentPoint = CGPointZero;
    [physicsComponent reset];
    [self resetLines];
    endGameNotificationSent = false;
    gameOver = false;
    in_game = false;
    //player_created = false;
    [self startMusic];
    tutorial_mode_on = false;
    found_first_obstacle = false;
    passed_first_obstacle = false;
    popup_engaged = false;
    previousPlayerXPosition_hypothetical = currentPlayerXPosition_hypothetical = 0;
    distanceLabel.text = @"0";
    [worldStreamer resetWithFinalDistance:distance_traveled];
    distance_traveled = 0;
    [self reappearButtons];
}

-(void)reappearButtons{
    pauseButton.hidden = false;
    muteLabelButton.hidden = false;
}

-(void)resetLines{
    for (Line* line in arrayOfLines) {
        for (Terrain* ter in line.terrainArray) {
            [ter removeFromParent];
        }
    }
    [arrayOfLines removeAllObjects];
}

-(void)createLogoLabel{
    logoLabel = [SKLabelNode labelNodeWithFontNamed:_constants.LOGO_LABEL_FONT_NAME];
    logoLabel.fontSize = _constants.LOGO_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dx;
    logoLabel.fontColor = _constants.LOGO_LABEL_FONT_COLOR;
    logoLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    logoLabel.zPosition = _constants.HUD_Z_POSITION;
    logoLabel.text = @"MACHWEO";
    //logoLabel.text = levelName;
    [_hud addChild:logoLabel];
    logoLabel.alpha = 0.0f;
    SKAction* greaten = [SKAction scaleBy:1.5 duration:3];
    [logoLabel runAction:greaten];
    SKAction* logoFadeIn = [SKAction fadeAlphaTo:1.0f duration:3];
    [logoLabel runAction:logoFadeIn completion:^{
        SKAction* logoFadeOut = [SKAction fadeAlphaTo:0.0f duration:2];
        [logoLabel runAction:logoFadeOut completion:^{
            [logoLabel removeFromParent];
            logoLabel = nil;
//                    //NSLog(@"fade in again");
//                    logoLabel.text = levelName;
//                    SKAction* logoFadeInAgain = [SKAction fadeAlphaTo:1.0f duration:1];
//                    [logoLabel runAction:logoFadeInAgain completion:^{
//                        SKAction* logoFadeOut = [SKAction fadeOutWithDuration:1];
//                        [logoLabel runAction:logoFadeOut completion:^{
//                            [logoLabel removeFromParent];
//                            logoLabel = nil;
//    
//                            if ([levelName isEqualToString:[_constants.LEVEL_ARRAY firstObject]]) {
//                                tutorial_mode_on = true;
//    
//                                NSMutableDictionary* popupDict = [NSMutableDictionary dictionary];
//                                [popupDict setValue:@"Draw a path for Maasai, and don't let him touch the ground!" forKey:@"popup text"];
//                                [popupDict setValue:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))] forKey:@"popup position"];
//                                [[NSNotificationCenter defaultCenter] postNotificationName:@"add popup" object:nil userInfo:popupDict];
//    
//                                popup_engaged = true;
//                            }
//    
//                        }];
        }];
    }];
}

-(void)createMuteButton{
    muteLabelButton = [SKLabelNode labelNodeWithFontNamed:_constants.LOGO_LABEL_FONT_NAME];
    muteLabelButton.fontSize = _constants.MENU_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dx;
    muteLabelButton.fontColor = _constants.LOGO_LABEL_FONT_COLOR;
    muteLabelButton.zPosition = _constants.HUD_Z_POSITION;
    muteLabelButton.text = @"mute";
    CGPoint posInScene = CGPointMake(CGRectGetMaxX(self.frame) - (muteLabelButton.frame.size.width / 2) - (muteLabelButton.frame.size.width / 4), CGRectGetMaxY(self.frame) - muteLabelButton.frame.size.height);
    muteLabelButton.position = [_hud convertPoint:posInScene fromNode:self];
    [_hud addChild:muteLabelButton];
}

-(void)createPauseButton{
    pauseButton = [SKLabelNode labelNodeWithFontNamed:_constants.LOGO_LABEL_FONT_NAME];
    pauseButton.fontSize = _constants.MENU_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dx;
    pauseButton.fontColor = _constants.LOGO_LABEL_FONT_COLOR;
    pauseButton.zPosition = _constants.HUD_Z_POSITION;
    pauseButton.text = @"pause";
    CGPoint posInScene = CGPointMake(pauseButton.frame.size.width / 2 + (pauseButton.frame.size.width / 4), CGRectGetMaxY(self.frame) - pauseButton.frame.size.height);
    pauseButton.position = [_hud convertPoint:posInScene fromNode:self];
    [_hud addChild:pauseButton];
}

-(void)createPausedLabel{
    pauseLabel = [SKLabelNode labelNodeWithFontNamed:_constants.LOGO_LABEL_FONT_NAME];
    pauseLabel.fontSize = _constants.PAUSED_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dx;
    pauseLabel.fontColor = _constants.LOGO_LABEL_FONT_COLOR;
    pauseLabel.zPosition = _constants.HUD_Z_POSITION;
    pauseLabel.text = @"PAUSED";
    pauseLabel.alpha = 0;
    CGPoint posInScene = CGPointMake(self.size.width / 2, self.size.height * .6);
    pauseLabel.position = [_hud convertPoint:posInScene fromNode:self];
    [_hud addChild:pauseLabel];
}

@end
