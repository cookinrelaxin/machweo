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
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    float scaleFactor = [[UIScreen mainScreen] nativeScale];
    //NSLog(@"screenSize: %f, %f", screenSize.width, screenSize.height);
   // NSLog(@"scaleFactor: %f", scaleFactor);
    _IDEAL_SCREEN_SIZE = CGSizeMake(1366, 1024);
    _SCALE_COEFFICIENT = CGVectorMake(screenSize.width / _IDEAL_SCREEN_SIZE.width, screenSize.height / _IDEAL_SCREEN_SIZE.height);
    //NSLog(@"_SCALE_COEFFICIENT: %f, %f", _SCALE_COEFFICIENT.dx, _SCALE_COEFFICIENT.dy);
    _PLAYER_SIZE = 100;
    _PLAYER_Z_POSITION = 100;
    _FOREGROUND_Z_POSITION = _PLAYER_Z_POSITION + 1;
    //_OBSTACLE_Z_POSITION = _FOREGROUND_Z_POSITION + 1;
    _OBSTACLE_Z_POSITION = _PLAYER_Z_POSITION;
    _BACKGROUND_Z_POSITION = 1;
    _SUN_AND_MOON_Z_POSITION = _BACKGROUND_Z_POSITION + .1;
    _HUD_Z_POSITION = 120;
    _BRUSH_FRACTION_OF_PLAYER_SIZE = 1;
    _TERRAIN_VERTEX_DECORATION_CHANCE_DENOM = 5;
    _TERRAIN_LAYER_COUNT = 1;
    _ZPOSITION_DIFFERENCE_PER_LAYER = 40;
    _Y_PARALLAX_COEFFICIENT = 0;
    _PLAYER_HIT_CATEGORY = 1;
    _OBSTACLE_HIT_CATEGORY = 2;
    _DISTANCE_LABEL_FONT_SIZE = 100;
    _DISTANCE_LABEL_FONT_COLOR = [UIColor whiteColor];
    _DISTANCE_LABEL_FONT_NAME = @"Skranji";
    _LOADING_LABEL_FONT_SIZE = 100;
    _LOADING_LABEL_FONT_COLOR = [UIColor whiteColor];
    _LOADING_LABEL_FONT_NAME = @"Skranji";
    _MENU_LABEL_FONT_SIZE = 80;
    _PAUSED_LABEL_FONT_SIZE = 150;
    _LOGO_LABEL_FONT_SIZE = 120;
    _LOGO_LABEL_FONT_COLOR = [UIColor colorWithRed:243.0f/255.0f green:126.0f/255.0f blue:61.0f/255.0f alpha:1];
    _LOGO_LABEL_FONT_NAME = @"Skranji";
    _PHYSICS_SCALAR_MULTIPLIER =_SCALE_COEFFICIENT.dy * scaleFactor;
    _AMBIENT_X_FORCE = .06f;
    _MAX_PLAYER_VELOCITY_DX = 9;
    _MAX_PLAYER_VELOCITY_DY = 8;
    _MIN_PLAYER_VELOCITY_DX = -1;
    _MIN_PLAYER_VELOCITY_DY = -8;
    _FRICTION_COEFFICIENT = .995f;
    _GRAVITY = .30;
    _TEXTURE_DICT = [NSMutableDictionary dictionary];
    _TERRAIN_ARRAY = [NSMutableArray array];
    _NUMBER_OF_BACKGROUND_SIMUL = 8;
    _DEFAULT_POPUP_WIDTH_TO_CHAR_RATIO = 250 / 20;
    _DEFAULT_POPUP_HEIGHT_TO_CHAR_RATIO = 100 / 20;
    _MIN_POPUP_SIZE = CGSizeMake((screenSize.width / 4), (screenSize.height / 6));
    _MAX_POPUP_SIZE = CGSizeMake((screenSize.width / 2), (screenSize.height / 4));
    _POPUP_FONT_NAME = @"Skranji";
    _jungle_textures_loaded = _sahara_textures_loaded = _savanna_textures_loaded = false;
    _dayTrackURL = [[NSBundle mainBundle] URLForResource:@"Tropical_Birds_and_Insects" withExtension:@"mp3"];
    _nightTrackURL = [[NSBundle mainBundle] URLForResource:@"Insects_Tropical" withExtension:@"mp3"];
    _savannaTrackURL = [[NSBundle mainBundle] URLForResource:@"supertrack3" withExtension:@"mp3"];
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
