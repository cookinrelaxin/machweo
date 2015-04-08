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
#import "WorldStreamer.h"
#import "AnimationComponent.h"
#import "GKHelper.h"
#import "SoundManager.h"
#import "Terrain.h"

int Y_THRESHOLD_FOR_SWITCH_LEVEL = 40;
int ALLOWABLE_X_DIFFERENCE = 10;
//from 1 to 16
int TENGGRI_COUNT = 16;
int RAW_SKY_WIDTH = 8192; // pixels
int DIURNAL_PERIOD = 120; //seconds
int LUNAR_PERIOD = 50; //seconds
float MAX_AUDIO_VOLUME = .25f;
int METERS_PER_PIXEL = 50;

@implementation GameScene{
    Player *player;
    CGPoint previousPoint;
    CGPoint currentPoint;
    ButsuLiKi *physicsComponent;
    AnimationComponent *animationComponent;
    NSMutableArray *terrainArray;
    CGPoint currentDesiredPlayerPositionInView;
    NSMutableArray* skyPool;
    NSMutableDictionary* skyDict;
    BOOL endGameNotificationSent;
    BOOL logoPresented;
    BOOL gameOver;
    BOOL in_game;
    BOOL player_created;
    BOOL paused;
    //UI
        SKLabelNode* logoLabel;
        SKLabelNode* returnToGameLabelButton;
        SKLabelNode* pauseLabel;
        SKLabelNode* scoreLabel;
    //
    SKSpriteNode* sunNode;
    SKSpriteNode* moonNode;
    SKSpriteNode* localPlayerCairn;
    BOOL tutorial_mode_on;
    BOOL found_first_obstacle;
    BOOL passed_first_obstacle;
    BOOL popup_engaged;
    float distance_traveled;
    float previousPlayerXPosition_hypothetical;
    float currentPlayerXPosition_hypothetical;
    SKLabelNode* distanceLabel;
    WorldStreamer* worldStreamer;
    float skyWidth;
    NSUInteger currentIndexInTenggri;
    float sky_displacement_coefficient;
    BOOL sunPathAdjusted;
    float sunMaxY;
    float sunMinY;
    CGPoint previousSunPos;
    SKSpriteNode* sunPanel;
    CGPoint finalPlayerPosition;
    SoundManager * soundManager;
    NSTimeInterval previousTime;
    NSString* greeting;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)initWithSize:(CGSize)size withinView:(SKView*)view{
    if (self = [super initWithSize:size]){
        _constants = [Constants sharedInstance];
        skyWidth = RAW_SKY_WIDTH;
        _world = [[SKNode alloc] init];
        self.shouldEnableEffects = true;
        [self addChild:_world];
        _hud = [SKNode node];
        _hud.physicsBody = nil;
        [self addChild:_hud];
        _obstacles = [SKNode node];
        _terrain = [SKNode node];
        _terrain.physicsBody = nil;
        _decorations = [[SKNode alloc] init];
        _decorations.physicsBody = nil;
        _skies = [SKNode node];
        _skies.physicsBody = nil;
        _cairns = [SKNode node];
        _cairns.physicsBody = nil;
        [_world addChild:_obstacles];
        [_world addChild:_terrain];
        [_world addChild:_decorations];
        [_world addChild:_skies];
        [_world addChild:_cairns];
        physicsComponent = [[ButsuLiKi alloc] initWithSceneSize:self.size];
        animationComponent = [AnimationComponent sharedInstance];
        terrainArray = [NSMutableArray array];
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        skyDict = _constants.SKY_DICT;
        skyPool = [NSMutableArray array];
        worldStreamer = [[WorldStreamer alloc] initWithScene:self withObstacles:_obstacles andDecorations:_decorations withinView:view andLines:terrainArray withXOffset:0];
        soundManager = [SoundManager sharedInstance];
//        [self runAction:[SKAction playSoundFileNamed:@"Loading_6.mp3" waitForCompletion:YES] completion:^(void){
//            [soundManager startSounds];
//        }];
        [self generateBackgrounds :false];
        [self organizeTheHeavens];
        [self setupObservers];
        distanceLabel = [SKLabelNode labelNodeWithFontNamed:_constants.DISTANCE_LABEL_FONT_NAME];
        distanceLabel.fontSize = _constants.DISTANCE_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dy;
        distanceLabel.fontColor = _constants.DISTANCE_LABEL_FONT_COLOR;
        distanceLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - distanceLabel.fontSize);
        distanceLabel.zPosition = _constants.HUD_Z_POSITION;
        distanceLabel.text = @"0";
        distanceLabel.hidden = true;
        [_hud addChild:distanceLabel];
        player = [Player player];
        [self createLogoLabel];
        //[self createPauseButton];
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
    [center addObserverForName:@"unpause"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         [weakSelf unpauseAndReturnToGame];
     }];
    [center addObserverForName:@"pause"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         if (!gameOver) {
             [weakSelf pauseWithVisibleLabel:YES];
         }
     }];
}

-(void)generateBackgrounds:(BOOL)forceLoad{
    SKSpriteNode* firstBackground = [skyPool firstObject];
    if (firstBackground || forceLoad) {
        CGPoint positionInScene = [self convertPoint:firstBackground.position fromNode:_skies];
        float leftEdgeOfFirstBackground = positionInScene.x - (firstBackground.size.width / 2);
        if ((leftEdgeOfFirstBackground > self.size.width) || forceLoad) {
            NSString* tenggriCountString = (currentIndexInTenggri < 10) ? [NSString stringWithFormat:@"0%lu", (unsigned long)currentIndexInTenggri] : [NSString stringWithFormat:@"%lu", (unsigned long)currentIndexInTenggri];
            NSString* backgroundName = [NSString stringWithFormat:@"tenggriPS_%@", tenggriCountString];
            SKSpriteNode* background = [skyDict valueForKey:backgroundName];
            SKSpriteNode* lastBackground = [skyPool lastObject];
            if (!lastBackground) {
                background.position = CGPointMake(self.size.width - (background.size.width / 2), self.size.height / 2);
            }
            else{
                background.position = CGPointMake((lastBackground.position.x - lastBackground.size.width / 2) - (background.size.width / 2), self.size.height / 2);
            }
            [background removeFromParent];
            [_skies addChild:background];
            if (!forceLoad) {
                [skyPool removeObject:firstBackground];
            }
            [skyPool addObject:background];
            if (!forceLoad) {
                if (currentIndexInTenggri == 7) {
                    [soundManager fadeIntoDayForBiome:[worldStreamer getCurrentBiome]];
                }
                else if (currentIndexInTenggri == 12) {
                    [soundManager fadeIntoNightForBiome:[worldStreamer getCurrentBiome]];
                }
            }
            currentIndexInTenggri --;
            if (currentIndexInTenggri < 1) {
                currentIndexInTenggri = TENGGRI_COUNT;
            }
        }
    }
    else{
        currentIndexInTenggri = [self calculateInitialSkyImageIndex];
        for (int i = 16; i >= 1; i --) {
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

-(NSUInteger)calculateInitialSkyImageIndex{
    float time = [self getCurrentActualTime];
    NSUInteger roundedTime = (6 * floor((time / 6.0) + 0.5));
    NSUInteger index = 1;
    if ((roundedTime == 24) || (roundedTime == 0)) {
        [soundManager fadeIntoNightForBiome:[worldStreamer getCurrentBiome]];
        index = 11;
    }
    else if (roundedTime == 6) {
        [soundManager fadeIntoNightForBiome:[worldStreamer getCurrentBiome]];
        index = 8;
    }
    else if (roundedTime == 12) {
        [soundManager fadeIntoDayForBiome:[worldStreamer getCurrentBiome]];
        index = 3;
    }
    else if (roundedTime == 18) {
        [soundManager fadeIntoDayForBiome:[worldStreamer getCurrentBiome]];
        index = 14;
    }
    return index;
}

-(float)getCurrentActualTime{
    NSDateComponents *components = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    float time = (float)components.hour + (((float)components.minute) / 60.0);
    //NSLog(@"time: %f", time);
    if (!greeting) {
        if (time >= 18) {
            greeting = @"good evening";
        }
        else if (time >= 12) {
            greeting = @"good afternoon";
        }
        else if (time >= 6) {
            greeting = @"good morning";
        }
        else{
            greeting = @"good evening";
        }
        //NSLog(@"greeting: %@", greeting);
    }
    return time;
}

-(float)calculateInitialSolarRotation{
    float time = [self getCurrentActualTime];
    float rotation = -((time * (M_PI / 12.0)) + M_PI_2);
    return rotation;
}

-(void)organizeTheHeavens{
    {
        SKTexture *spriteTexture = [_constants.TEXTURE_DICT objectForKey:@"sun2_decoration"];
        if (spriteTexture) {
            sunNode = [SKSpriteNode spriteNodeWithTexture:spriteTexture];
            sunNode.physicsBody = nil;
        }
        sunPanel = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(self.size.width, self.size.height)];
        sunPanel.physicsBody = nil;
        CGPoint centerOfSolarOrbit = CGPointMake(self.size.width / 2, (sunNode.size.height / 2));
        sunPanel.position = centerOfSolarOrbit;
        sunPanel.zRotation =  [self calculateInitialSolarRotation];
        sunPanel.zPosition = _constants.SUN_AND_MOON_Z_POSITION;
        [_world addChild:sunPanel];
        float radiusOfSolarOrbit = self.size.height * .6;
        UIBezierPath *sunPath = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:radiusOfSolarOrbit startAngle:0 endAngle:2 * M_PI clockwise:NO];
        [sunPath closePath];
        SKAction* sunriseAction = [SKAction followPath:sunPath.CGPath asOffset:NO orientToPath:NO duration:DIURNAL_PERIOD];
        [sunNode runAction:[SKAction repeatActionForever:sunriseAction] completion:^{
        }];
        [sunPanel addChild:sunNode];
        sunMaxY = centerOfSolarOrbit.y + radiusOfSolarOrbit;
        sunMinY = centerOfSolarOrbit.y - radiusOfSolarOrbit;
        sky_displacement_coefficient = skyWidth / (2 * M_PI * radiusOfSolarOrbit);
    }
    
    {
        SKTexture *spriteTexture = [_constants.TEXTURE_DICT objectForKey:@"moon_decoration"];
        if (spriteTexture) {
            moonNode = [SKSpriteNode spriteNodeWithTexture:spriteTexture];
            moonNode.physicsBody = nil;
        }
        [_world addChild:moonNode];
        moonNode.zPosition = _constants.SUN_AND_MOON_Z_POSITION;
        UIBezierPath *moonPath = [UIBezierPath bezierPath];
        float moonOrbitRadius = self.size.height * .6;
        CGPoint moonOrbitCenter = CGPointMake(self.size.width / 2, moonNode.size.height / 2);
        [moonPath addArcWithCenter:moonOrbitCenter radius:moonOrbitRadius startAngle:0 endAngle:2 * M_PI clockwise:NO];
        SKAction* moonriseAction = [SKAction followPath:moonPath.CGPath asOffset:NO orientToPath:NO duration:LUNAR_PERIOD];
        [moonNode runAction:[SKAction repeatActionForever:moonriseAction] completion:^{
        }];
    }
}

-(void)performSunset{
    SKAction* sunsetAction = [SKAction moveToY:(0 - (sunNode.size.height / 2)) duration:2.0f];
    [sunNode runAction:sunsetAction];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint positionInSelf = [touch locationInNode:self];
    if (popup_engaged && _allowDismissPopup) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"remove message" object:nil];
        _allowDismissPopup = false;
        return;
    }
    if (paused && !popup_engaged) {
        [self unpauseAndReturnToGame];
        return;
    }
    if (!in_game && !gameOver && !logoLabel) {
        [worldStreamer enableObstacles];
        distanceLabel.hidden = false;
        in_game = true;
    }
    player.touchesEnded = false;
    if (positionInSelf.y < 50) {
        previousPoint = currentPoint = CGPointMake(positionInSelf.x, 0);
    }
    else{
        previousPoint = currentPoint = positionInSelf;
    }
    Terrain *terrain = [[Terrain alloc] initWithSceneSize:self.size];
    //[terrain runAction:[SKAction repeatActionForever:[_constants.SOUND_ACTIONS valueForKey:@"line.mp3"]] withKey:@"lineSound"];
    [terrainArray addObject:terrain];
    [_terrain addChild:terrain];
    if (terrainArray.count > 2) {
        Terrain* firstTer = [terrainArray firstObject];
        for (Decoration *deco in firstTer.decos) {
            [deco runAction:[SKAction fadeOutWithDuration:1]];
        }
        firstTer.shouldDeallocNodeArray = true;
        [firstTer runAction:[SKAction fadeOutWithDuration:1] completion:^{
            [firstTer removeFromParent];
            [terrainArray removeObject:firstTer];
        }];
    }
}

-(void)pauseWithVisibleLabel:(BOOL)labelIsVisible{
    paused = true;
    SKAction *currentAnimation = [player actionForKey:@"runningMaasai"];
    if (!currentAnimation) {
        currentAnimation = [player actionForKey:@"jumpingMaasai"];
    }
    if (currentAnimation) {
        currentAnimation.speed = 0;
    }
    if (labelIsVisible) {
        [pauseLabel runAction:[SKAction fadeAlphaTo:1 duration:.5]];
    }
    //pauseButton.hidden = true;
}
             
-(void)unpauseAndReturnToGame{
    [pauseLabel runAction:[SKAction fadeAlphaTo:0 duration:.5] completion:^{
        paused = false;
        //pauseButton.hidden = false;
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
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        Terrain* lastTer = [terrainArray lastObject];
        //[lastTer removeActionForKey:@"lineSound"];
        [lastTer correctSpriteZsBeforeVertex:currentPoint againstSlope:NO];
        lastTer.complete = true;
        player.touchesEnded = true;
    });
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
    Terrain* currentTer = [terrainArray lastObject];
    NSMutableArray *currentPointArray = currentTer.vertices;
    CGPoint lastPoint = [(NSValue*)[currentPointArray lastObject] CGPointValue];
    if (lastPoint.x > currentPoint.x) {
        return;
    }
    if (currentPointArray.count == 0) {
        if (player.position.y > currentPoint.y) {
            currentTer.belowPlayer = true;
        }
        else{
            currentTer.belowPlayer = false;
        }
    }
    [currentPointArray addObject:[NSValue valueWithCGPoint:currentPoint]];
    CGPoint newPoint = CGPointMake(currentPoint.x, currentPoint.y);
    [currentTer.vertices addObject:[NSValue valueWithCGPoint:[currentTer convertPoint:newPoint fromNode:self]]];
    if (!currentTer.permitDecorations){
        [currentTer changeDecorationPermissions:newPoint];
    }
    [currentTer generateDecorationAtVertex:newPoint inNode:_decorations andSlope:((currentPoint.y - previousPoint.y) / (currentPoint.x - previousPoint.x)) andCurrentBiome:[worldStreamer getCurrentBiome]];
    previousPoint = currentPoint;
}

-(void)drawLines{
    for (Terrain* ter in terrainArray) {
        [ter closeLoopAndFillTerrainInView:self.view withCurrentSunYPosition:[self convertPoint:sunNode.position fromNode:sunNode.parent].y minY:sunMinY andMaxY:sunMaxY];
    }
}

-(void)updateDistanceLabelWithDistance:(NSUInteger)distance{
    NSString* distanceString = [NSString stringWithFormat:@"%lu m", (unsigned long)distance];
    distanceLabel.text = distanceString;
}

-(void)updateDistance{
    currentPlayerXPosition_hypothetical += player.velocity.dx;
    double difference = currentPlayerXPosition_hypothetical - previousPlayerXPosition_hypothetical;
    if (difference > METERS_PER_PIXEL) {
        distance_traveled += (difference / METERS_PER_PIXEL);
        [self updateDistanceLabelWithDistance:distance_traveled];
        currentPlayerXPosition_hypothetical = previousPlayerXPosition_hypothetical;
    }
}

-(void)setDecoFilter{
    float maxY = sunMaxY;
    float minY = sunMinY;
    float sunY = [self convertPoint:sunNode.position fromNode:sunNode.parent].y;
    float minBrightnessMultiplier = 1.0 / 5.0;
    float maxBrightnessMultiplier = 1.0;
    float brightness = sunY / maxY;
    float maxDistanceFromApex = maxY - minY;
    float distanceFromApex = maxY - sunY;
    float brightnessMultiplier = (distanceFromApex / maxDistanceFromApex) / 2.0;
    brightnessMultiplier = (brightnessMultiplier > maxBrightnessMultiplier) ? maxBrightnessMultiplier : brightnessMultiplier;
    brightnessMultiplier = (brightnessMultiplier < minBrightnessMultiplier) ? minBrightnessMultiplier : brightnessMultiplier;
    brightness *= brightnessMultiplier;
    float minB = -.20;
    float maxB = .15;
    brightness = (brightness < minB) ? minB : brightness;
    brightness = (brightness > maxB) ? maxB : brightness;
    CGColorRef filterColor = [UIColor colorWithHue:1 saturation:0 brightness:0 alpha:1].CGColor;
    CIColor *convertedColor = [CIColor colorWithCGColor:filterColor];
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setValue:[CIImage imageWithColor:convertedColor] forKey:kCIInputImageKey];
    [lighten setValue:@(brightness) forKey:@"inputBrightness"];
    self.filter = lighten;
}

-(void)update:(CFTimeInterval)currentTime {
    NSTimeInterval deltaTime = currentTime - previousTime;
    if (deltaTime > 1) {
        deltaTime = 1/60;
    }
    previousTime = currentTime;
    [soundManager adjustNatureVolumeToBiome:[worldStreamer getCurrentBiome]];
    [self generateBackgrounds :false];
    [self setDecoFilter];
    float dx = sunNode.position.x - previousSunPos.x;
    float dy = sunNode.position.y - previousSunPos.y;
    float r = sqrtf(powf(dx, 2) + powf(dy, 2));
    _skies.position = CGPointMake(_skies.position.x + (r * sky_displacement_coefficient), _skies.position.y);
    previousSunPos = sunNode.position;
    if (!paused) {
        if (logoPresented) {
            if (tutorial_mode_on && !found_first_obstacle) {
                [self tutorialCheckForFirstObstacle];
            }
            if (tutorial_mode_on && !passed_first_obstacle) {
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
                //[self checkForCloseCall];
                [self updateDistance];
                [self checkForLostGame];
            }
            if (!gameOver) {
                [worldStreamer updateWithPlayerDistance:distance_traveled andDeltaTime:deltaTime];
                [self centerCameraOnPlayer];
                [self checkForNewAnimationState];
                [player resetMinsAndMaxs];
                [player updateEdges];
                [physicsComponent calculatePlayerPosition:player withTerrainArray:terrainArray];
                [self drawLines];
            }
            
        }
        [self fadeMoon];
    }
}

-(void)checkForNewAnimationState{
    if ((player.roughlyOnLine || player.onGround) && [player actionForKey:@"midAirMaasai"]) {
        [player removeActionForKey:@"midAirMaasai"];
//        NSLog(@"[player actionForKey:flagFlap]: %@", [player actionForKey:@"flagFlap"]);
        //SKAction* flagFlap = [player actionForKey:@"flagFlap"];
        
        [player removeActionForKey:@"flagFlap"];
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
        SKAction* midAirAction = [SKAction repeatActionForever:
                                  [SKAction animateWithTextures:animationComponent.midairFrames
                                                   timePerFrame:0.05f
                                                         resize:NO
                                                        restore:YES]];
        [player runAction:[SKAction sequence:@[jumpAction, midAirAction]] withKey:@"jumpingMaasai"];
        //[player runAction:[_constants.SOUND_ACTIONS valueForKey:@"jump.mp3"]];
    }
    else if([player actionForKey:@"jumpingMaasai"]){
        
        [player removeActionForKey:@"jumpingMaasai"];
        SKAction* midAirAction = [SKAction repeatActionForever:
        [SKAction animateWithTextures:animationComponent.midairFrames
                        timePerFrame:0.05f
                              resize:NO
                             restore:YES]];
        [player runAction:midAirAction withKey:@"midAirMaasai"];
        //[player runAction:[_constants.SOUND_ACTIONS valueForKey:@"flagFlap.mp3"] withKey:@"flagFlap"];
        //NSLog(@"[player actionForKey:flagFlap]: %@", [player actionForKey:@"flagFlap"]);

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
    }
//    else{
//        if (player.shouldWoosh && !player.wooshing) {
//            player.wooshing = true;
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^(void){
//                [player runAction:[_constants.SOUND_ACTIONS valueForKey:@"swoosh.mp3"]];
//            });
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                player.wooshing = false;
//                player.shouldWoosh = false;
//            });
//            
//        }
//    }
}

//-(void)checkForCloseCall{
//    if (!player.wooshing) {
//        CGPoint playerPositionInObstacles = [_obstacles convertPoint:player.position fromNode:self];
//        float leftSideOfPlayerInObstacles = playerPositionInObstacles.x - (player.size.width / 2);
//        CGPoint playerOriginInObstacles = [_obstacles convertPoint:player.frame.origin fromNode:self];
//        CGRect playerFrameInObstacles = CGRectMake(playerOriginInObstacles.x, playerOriginInObstacles.y, player.size.width, player.size.height);
//        for (Obstacle* obs in _obstacles.children) {
//            if ((leftSideOfPlayerInObstacles > obs.position.x) && CGRectIntersectsRect(obs.frame, playerFrameInObstacles)) {
//                player.shouldWoosh = true;
//                return;
//            }
//        }
//    }
//}

-(void)sendMessageNotificationWithText:(NSString*)text andPosition:(CGPoint)position andShouldPause:(BOOL)shouldPause{
    NSMutableDictionary* popupDict = [NSMutableDictionary dictionary];
    [popupDict setValue:text forKey:@"popup text"];
    [popupDict setValue:[NSValue valueWithCGPoint:position] forKey:@"popup position"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"add popup" object:nil userInfo:popupDict];
    _allowDismissPopup = false;
    popup_engaged = true;
    if (shouldPause) {
        [self pauseWithVisibleLabel:NO];
    }
}

-(void)loseGame{
    gameOver = true;
    [player runAction:[SKAction fadeOutWithDuration:1]];
    [player runAction:[_constants.SOUND_ACTIONS valueForKey:@"treegrow2.mp3"]];
    [soundManager stopMusic];
    //pauseButton.hidden = true;
    //[self blurScreen];
    distanceLabel.hidden = true;
    GKHelper* gkhelper = [GKHelper sharedInstance];
    [gkhelper setCurrentScore:distance_traveled];
    [gkhelper reportScore];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lose game" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:distance_traveled] forKey:@"distance"]];
}

-(void)tellObstaclesToMove{
    for (Obstacle* obs in _obstacles.children) {
        [obs moveWithScene:self];
    }
}

-(void)endGame{
    endGameNotificationSent = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"end game" object:nil];
}

-(void)tutorialCheckForFirstObstacle{
    Obstacle *obs = [_obstacles.children firstObject];
    CGPoint obsPositionInView = [self.view convertPoint:[self convertPoint:obs.position fromNode:_obstacles] fromScene:self];

    if ((obsPositionInView.x < (self.view.bounds.size.width * 3/4)) && (obsPositionInView.x > 0)) {
        found_first_obstacle = true;
        [self sendMessageNotificationWithText:@"Avoid the obstacles!" andPosition:CGPointMake(obsPositionInView.x, self.view.bounds.size.height / 2) andShouldPause:YES];
    }
}

-(void)tutorialCheckForFirstEvasion{
    Obstacle *obs = [_obstacles.children firstObject];
    CGPoint obsPositionInView = [self.view convertPoint:[self convertPoint:obs.position fromNode:_obstacles] fromScene:self];
    if ((obsPositionInView.x <  player.position.x) && (obsPositionInView.x > 0)) {
        passed_first_obstacle = true;
        [self sendMessageNotificationWithText:@"Great! That's about it. Now see how far you can run!" andPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) andShouldPause:YES];
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
        CGVector differenceInPreviousAndCurrentPlayerPositions = CGVectorMake(player.velocity.dx * _constants.PHYSICS_SCALAR_MULTIPLIER, player.velocity.dy * _constants.PHYSICS_SCALAR_MULTIPLIER);
        for (Terrain* ter in terrainArray) {
            for (int i = 0; i < ter.vertices.count; i ++) {
                NSValue* pointNode = [ter.vertices objectAtIndex:i];
                CGPoint pointNodePosition = pointNode.CGPointValue;
//                if (pointNodePosition.x < 0) {
//                    [ter.vertices removeObject:pointNode];
//                    continue;
//                }
                [ter.vertices replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:CGPointMake(pointNodePosition.x - differenceInPreviousAndCurrentPlayerPositions.dx, pointNodePosition.y)]];
            }
        }
        _obstacles.position = CGPointMake(_obstacles.position.x - differenceInPreviousAndCurrentPlayerPositions.dx, _obstacles.position.y);
        if (in_game) {
            _cairns.position = CGPointMake(_cairns.position.x - differenceInPreviousAndCurrentPlayerPositions.dx, _cairns.position.y);
        }
        for (SKSpriteNode* deco in _decorations.children) {
            float fractionalCoefficient = deco.zPosition / _constants.OBSTACLE_Z_POSITION;
            CGVector parallaxAdjustedDifference = CGVectorMake(fractionalCoefficient * differenceInPreviousAndCurrentPlayerPositions.dx, 0);
            deco.position = CGPointMake(deco.position.x - parallaxAdjustedDifference.dx, deco.position.y);
        }
    }
    //NSLog(@"_cairns.position.x: %f", _cairns.position.x);
}

-(void)reset{
    {
        [player removeFromParent];
        player = [Player player];
        player.hidden = false;
        player_created = false;
    }
    previousPoint = currentPoint = CGPointZero;
    [physicsComponent reset];
    [self resetLines];
    [self resetCairns];
    endGameNotificationSent = false;
    gameOver = false;
    in_game = false;
    previousPlayerXPosition_hypothetical = currentPlayerXPosition_hypothetical = 0;
    distanceLabel.text = @"0";
    [worldStreamer resetWithFinalDistance:distance_traveled];
    distance_traveled = 0;
    [soundManager startMusic];

}

-(void)resetCairns{
    for (SKSpriteNode* cairn in _cairns.children){
        if (cairn == localPlayerCairn) {
            NSUInteger scoreDifference = distance_traveled - [GKHelper sharedInstance].localHighScore;
            if (scoreDifference > 0) {
                cairn.position = CGPointMake(cairn.position.x + (scoreDifference * METERS_PER_PIXEL), cairn.position.y);
            }
        }
    }
    _cairns.position = CGPointMake(_cairns.position.x + (distance_traveled * METERS_PER_PIXEL), _cairns.position.y);
}

-(void)resetLines{
    for (Terrain* ter in terrainArray) {
        [ter fadeOutAndDelete];
    }
    [terrainArray removeAllObjects];
}

-(void)createLogoLabel{
    logoLabel = [SKLabelNode labelNodeWithFontNamed:_constants.LOGO_LABEL_FONT_NAME];
    logoLabel.fontSize = _constants.LOGO_LABEL_FONT_SIZE * _constants.SCALE_COEFFICIENT.dx;
    logoLabel.fontColor = _constants.LOGO_LABEL_FONT_COLOR;
    logoLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    logoLabel.zPosition = _constants.HUD_Z_POSITION;
    logoLabel.text = @"MACHWEO";
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
            logoPresented = true;
            GKHelper *gkhelper = [GKHelper sharedInstance];
            NSString* nameString;
            if (gkhelper.gcEnabled) {
                nameString = gkhelper.playerName;
            }
            if (gkhelper.localHighScore == 1) {
                tutorial_mode_on = true;
                if (nameString) {
                    [self sendMessageNotificationWithText:[NSString stringWithFormat:@"%@, welcome to Machweo!", nameString] andPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) andShouldPause:YES];
                }
                else{
                    [self sendMessageNotificationWithText:@"Welcome to Machweo!" andPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) andShouldPause:YES];
                }
                [self sendMessageNotificationWithText:@"Draw a path for Maasai, and don't let him touch the ground!" andPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) andShouldPause:YES];
            }
            else{
                if (nameString) {
                    [self sendMessageNotificationWithText:[NSString stringWithFormat:@"%@, %@! Can you beat your high score of %lu?", nameString, greeting, (unsigned long)gkhelper.localHighScore] andPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) andShouldPause:YES];
                }
                else{
                    [self sendMessageNotificationWithText:[NSString stringWithFormat:@"%@! Can you beat your high score of %lu?", greeting, (unsigned long)gkhelper.localHighScore] andPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) andShouldPause:YES];
                }
                //[self sendMessageNotificationWithText:[NSString stringWithFormat:@"Can you beat your high score of %lu?", (unsigned long)gkhelper.localHighScore] andPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) andShouldPause:YES];
            }
        }];
    }];
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

-(void)setupCairns{
    GKHelper* gkhelper = [GKHelper sharedInstance];
    if (gkhelper.gcEnabled) {
        SKTexture *cairnTexture = [_constants.TEXTURE_DICT objectForKey:@"cairn_decoration"];
        NSArray* top10GlobalScores = [gkhelper retrieveTopTenGlobalScores];
        NSArray* top10FriendScores = [gkhelper retrieveTopTenFriendScores];
        UIColor* labelColor = [UIColor blackColor];
        float cairnZ = _constants.OBSTACLE_Z_POSITION;
        float labelSize = 45 * _constants.SCALE_COEFFICIENT.dx;
        for (GKScore* score in top10GlobalScores) {
            SKSpriteNode* cairn = [SKSpriteNode spriteNodeWithTexture:cairnTexture];
            cairn.physicsBody = nil;
            cairn.zPosition = cairnZ;
            cairn.position = CGPointMake((score.value * METERS_PER_PIXEL * _constants.PHYSICS_SCALAR_MULTIPLIER) + (cairn.size.width / 2), cairn.size.height / 2);
            [_cairns addChild:cairn];
            SKLabelNode* playerNameLabel = [SKLabelNode labelNodeWithText:score.player.alias];
            playerNameLabel.fontSize = labelSize;
            playerNameLabel.fontName = _constants.LOADING_LABEL_FONT_NAME;
            playerNameLabel.fontColor = labelColor;
            playerNameLabel.position = CGPointMake(0, cairn.size.height / 2);
            [cairn addChild:playerNameLabel];
        }
        for (GKScore* score in top10FriendScores) {
            if ([top10GlobalScores containsObject:score]) {
                continue;
            }
            SKSpriteNode* cairn = [SKSpriteNode spriteNodeWithTexture:cairnTexture];
            cairn.physicsBody = nil;
            cairn.zPosition = cairnZ;
            cairn.position = CGPointMake((score.value * METERS_PER_PIXEL) + (cairn.size.width / 2), cairn.size.height / 2);
            [_cairns addChild:cairn];
            SKLabelNode* playerNameLabel = [SKLabelNode labelNodeWithText:score.player.alias];
            playerNameLabel.fontSize = labelSize;
            playerNameLabel.fontName = _constants.LOADING_LABEL_FONT_NAME;
            playerNameLabel.fontColor = labelColor;
            playerNameLabel.position = CGPointMake(0, cairn.size.height / 2);
            [cairn addChild:playerNameLabel];
            if ([score.player.alias isEqualToString:gkhelper.playerName]) {
                localPlayerCairn = cairn;
            }
        }
    }
}

-(void)didMoveToView:(SKView *)view{
    [self setupCairns];
    //[soundManager startSounds];
}

@end
