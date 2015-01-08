//
//  Constants.m
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 10/23/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "Constants.h"

float RoundDownTo(float number, float to)
{
    return to * floorf(number / to);

}

int midpoint(int n1, int n2)
{
    return (n1 + n2) / 2;
}

@implementation Constants

-(instancetype)initSingleton{
    NSLog(@"initialize Constants singleton");

    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    //NSLog(@"screenSize: %f, %f", screenSize.width, screenSize.height);
    
    _IDEAL_SCREEN_SIZE = CGSizeMake(1136, 640);
    _SCALE_COEFFICIENT = CGVectorMake(screenSize.width / _IDEAL_SCREEN_SIZE.width, screenSize.height / _IDEAL_SCREEN_SIZE.height);
  
    _PLAYER_SIZE = 30;
    _OBSTACLE_Z_POSITION = 10;
    _PLAYER_Z_POSITION = _OBSTACLE_Z_POSITION + 1;
    _LINE_Z_POSITION = _PLAYER_Z_POSITION + 1;
    _HUD_Z_POSITION = _LINE_Z_POSITION + 1;
    _BRUSH_FRACTION_OF_PLAYER_SIZE = 1;
    
    _Y_PARALLAX_COEFFICIENT = .1f;
    
    _PLAYER_HIT_CATEGORY = 1;
    _OBSTACLE_HIT_CATEGORY = 2;
    
    _TIMER_LABEL_FONT_SIZE = 50;
    _TIMER_LABEL_FONT_COLOR = [UIColor blackColor];
    
    _LOADING_LABEL_FONT_SIZE = 100;
    _LOADING_LABEL_FONT_COLOR = [UIColor blackColor];
    _LOADING_LABEL_FONT_NAME = @"DamascusBold";
    
    _RESTART_LABEL_FONT_SIZE = 40;
    _RESTART_LABEL_FONT_COLOR = [UIColor blackColor];
    _RESTART_LABEL_FONT_NAME = @"DamascusBold";
    
    _RETURN_TO_MENU_LABEL_FONT_SIZE = 60;
    _RETURN_TO_MENU_LABEL_FONT_COLOR = [UIColor blackColor];
    _RETURN_TO_MENU_LABEL_FONT_NAME = @"DamascusBold";
    
    
    float scaleFactor = [[UIScreen mainScreen] scale];
    CGSize scaledScreenSize = CGSizeMake(screenSize.width * scaleFactor, screenSize.height * scaleFactor);
    float physicsScalarMultiplier = ((scaledScreenSize.width / _IDEAL_SCREEN_SIZE.width) + (scaledScreenSize.height / _IDEAL_SCREEN_SIZE.height)) / 2;

    
    _AMBIENT_X_FORCE = .080 * physicsScalarMultiplier;
    _MAX_PLAYER_VELOCITY_DX = 6 * physicsScalarMultiplier;
    _MAX_PLAYER_VELOCITY_DY = 6 * physicsScalarMultiplier;
    _MIN_PLAYER_VELOCITY_DX = -1 * physicsScalarMultiplier;
    _MIN_PLAYER_VELOCITY_DY = -5 * physicsScalarMultiplier;
    _FRICTION_COEFFICIENT = .99;
    _GRAVITY = .2 * physicsScalarMultiplier;
    
//    
//    NSLog(@"_AMBIENT_X_FORCE: %f", _AMBIENT_X_FORCE);
//    NSLog(@"_MAX_PLAYER_VELOCITY_DX: %f", _MAX_PLAYER_VELOCITY_DX);
//    NSLog(@"_MAX_PLAYER_VELOCITY_DY: %f", _MAX_PLAYER_VELOCITY_DY);
//    NSLog(@"_MIN_PLAYER_VELOCITY_DX: %f", _MIN_PLAYER_VELOCITY_DX);
//    NSLog(@"_MIN_PLAYER_VELOCITY_DY: %f", _MIN_PLAYER_VELOCITY_DY);
//    NSLog(@"_GRAVITY: %f", _GRAVITY);
    

 
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static Constants* sharedSingleton = nil;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[Constants alloc] initSingleton];
    });
    return sharedSingleton;
}

@end
