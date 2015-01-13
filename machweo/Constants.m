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
    _PHYSICS_SCALAR_MULTIPLIER =_SCALE_COEFFICIENT.dy * scaleFactor;
    NSLog(@"_SCALE_COEFFICIENT: %f",_SCALE_COEFFICIENT.dy);
    NSLog(@"_PHYSICS_SCALAR_MULTIPLIER: %f", _PHYSICS_SCALAR_MULTIPLIER);
    
    _AMBIENT_X_FORCE = .06f;
    _MAX_PLAYER_VELOCITY_DX = 15;
    _MAX_PLAYER_VELOCITY_DY = 6;
    _MIN_PLAYER_VELOCITY_DX = -1;
    _MIN_PLAYER_VELOCITY_DY = -5;
    //_FRICTION_COEFFICIENT = .9875f;
    _FRICTION_COEFFICIENT = 1;
    _GRAVITY = .20;

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
