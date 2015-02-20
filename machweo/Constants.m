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
  //  NSLog(@"initialize Constants singleton");

    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    //NSLog(@"screenSize: %f, %f", screenSize.width, screenSize.height);
    
    _IDEAL_SCREEN_SIZE = CGSizeMake(1366, 768);
    _SCALE_COEFFICIENT = CGVectorMake(screenSize.width / _IDEAL_SCREEN_SIZE.width, screenSize.height / _IDEAL_SCREEN_SIZE.height);
    _PLAYER_SIZE = 30;
    
    _PLAYER_Z_POSITION = 100;
    _FOREGROUND_Z_POSITION = _PLAYER_Z_POSITION + 1;
    _OBSTACLE_Z_POSITION = _FOREGROUND_Z_POSITION + 1;
    _HUD_Z_POSITION = _OBSTACLE_Z_POSITION + 1;
    _BRUSH_FRACTION_OF_PLAYER_SIZE = 1;
    
    _TERRAIN_VERTEX_DECORATION_CHANCE_DENOM = 5;
    _TERRAIN_LAYER_COUNT = 1;
    _ZPOSITION_DIFFERENCE_PER_LAYER = 40;
    
    _Y_PARALLAX_COEFFICIENT = 0;

    
    _PLAYER_HIT_CATEGORY = 1;
    _OBSTACLE_HIT_CATEGORY = 2;
    
    _TIMER_LABEL_FONT_SIZE = 50;
    _TIMER_LABEL_FONT_COLOR = [UIColor whiteColor];
    
    _LOADING_LABEL_FONT_SIZE = 100;
    _LOADING_LABEL_FONT_COLOR = [UIColor whiteColor];
    _LOADING_LABEL_FONT_NAME = @"DamascusBold";
    
    _RESTART_LABEL_FONT_SIZE = 40;
    _RESTART_LABEL_FONT_COLOR = [UIColor whiteColor];
    _RESTART_LABEL_FONT_NAME = @"DamascusBold";
    
    _LOGO_LABEL_FONT_SIZE = 150;
    _LOGO_LABEL_FONT_COLOR = [UIColor colorWithRed:243 green:126 blue:61 alpha:1];
    _LOGO_LABEL_FONT_NAME = @"Skranji";
    
    
    float scaleFactor = [[UIScreen mainScreen] scale];
    _PHYSICS_SCALAR_MULTIPLIER =_SCALE_COEFFICIENT.dy * scaleFactor;
    //NSLog(@"_SCALE_COEFFICIENT: %f",_SCALE_COEFFICIENT.dy);
   // NSLog(@"_PHYSICS_SCALAR_MULTIPLIER: %f", _PHYSICS_SCALAR_MULTIPLIER);
    
    _AMBIENT_X_FORCE = .06f;
    _MAX_PLAYER_VELOCITY_DX = 9;
    _MAX_PLAYER_VELOCITY_DY = 8;
    _MIN_PLAYER_VELOCITY_DX = -1;
    _MIN_PLAYER_VELOCITY_DY = -8;
    //_FRICTION_COEFFICIENT = .9875f;
    _FRICTION_COEFFICIENT = .995f;

    _GRAVITY = .30;
    
    _CURRENT_INDEX_IN_LEVEL_ARRAY = 0;
    

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
