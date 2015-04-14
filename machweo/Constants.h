//
//  Constants.h
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 10/23/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//extern float RoundTo(float number, float to);
extern float RoundDownTo(float number, float to);
extern int midpoint(int n1, int n2);

typedef enum TimesOfDay
{
    AM_12,
    AM_1,
    AM_2,
    AM_3,
    AM_4,
    AM_5,
    AM_6,
    AM_7,
    AM_8,
    AM_9,
    AM_10,
    AM_11,
    PM_12,
    PM_1,
    PM_2,
    PM_3,
    PM_4,
    PM_5,
    PM_6,
    PM_7,
    PM_8,
    PM_9,
    PM_10,
    PM_11
    
} TimeOfDay;

typedef enum Biomes
{
    savanna,
    sahara,
    jungle,
    numBiomes
    
} Biome;

typedef enum Devices
{
    iphone_4_5,
    iphone_6,
    iphone_6_plus,
    ipad
} Device;





@interface Constants : NSObject

@property (readonly, nonatomic) double GRAVITY;
@property (readonly, nonatomic) double AMBIENT_X_FORCE;
@property (readonly, nonatomic) double MAX_PLAYER_VELOCITY_DX;
@property (readonly, nonatomic) double MAX_PLAYER_VELOCITY_DY;
@property (readonly, nonatomic) double MIN_PLAYER_VELOCITY_DX;
@property (readonly, nonatomic) double MIN_PLAYER_VELOCITY_DY;
@property (readonly, nonatomic) double FRICTION_COEFFICIENT;
@property (readonly, nonatomic) double PHYSICS_SCALAR_MULTIPLIER;
@property (readonly, nonatomic) int TERRAIN_VERTEX_DECORATION_CHANCE_DENOM;
@property (readonly, nonatomic) int PLAYER_SIZE;
@property (readonly, nonatomic) int PLAYER_Z_POSITION;
@property (readonly, nonatomic) int OBSTACLE_Z_POSITION;
@property (readonly, nonatomic) int FOREGROUND_Z_POSITION;
@property (readonly, nonatomic) int BACKGROUND_Z_POSITION;
@property (readonly, nonatomic) float SUN_AND_MOON_Z_POSITION;
@property (readonly, nonatomic) int HUD_Z_POSITION;
@property (readonly, nonatomic) CGSize IDEAL_SCREEN_SIZE;
@property (readonly, nonatomic) CGVector SCALE_COEFFICIENT;
@property (readonly, nonatomic) float DISTANCE_LABEL_FONT_SIZE;
@property (readonly, nonatomic) UIColor* DISTANCE_LABEL_FONT_COLOR;
@property (readonly, nonatomic) NSString* DISTANCE_LABEL_FONT_NAME;
@property (readonly, nonatomic) float LOADING_LABEL_FONT_SIZE;
@property (readonly, nonatomic) UIColor* LOADING_LABEL_FONT_COLOR;
@property (readonly, nonatomic) UIColor* LOADING_SCREEN_BACKGROUND_COLOR;
@property (readonly, nonatomic) NSString* LOADING_LABEL_FONT_NAME;
@property (readonly, nonatomic) float PAUSED_LABEL_FONT_SIZE;
@property (readonly, nonatomic) float LOGO_LABEL_FONT_SIZE;
@property (readonly, nonatomic) UIColor* LOGO_LABEL_FONT_COLOR;
@property (readonly, nonatomic) NSString* LOGO_LABEL_FONT_NAME;
@property(readonly, nonatomic) int PLAYER_HIT_CATEGORY;
@property(readonly, nonatomic) int OBSTACLE_HIT_CATEGORY;
@property(nonatomic) NSMutableDictionary* BIOMES;
@property(nonatomic) NSMutableDictionary* OBSTACLE_SETS;
@property(nonatomic) NSMutableDictionary* SKY_DICT;
@property(nonatomic) NSMutableDictionary* OBSTACLE_POOL;
@property(nonatomic) NSMutableDictionary* SOUND_ACTIONS;
@property(nonatomic) NSMutableArray* TERRAIN_ARRAY;
@property(nonatomic, strong) NSMutableDictionary* ATLAS_FOR_DECO_NAME;
@property(nonatomic) BOOL jungle_textures_loaded;
@property(nonatomic) BOOL savanna_textures_loaded;
@property(nonatomic) BOOL sahara_textures_loaded;
@property(nonatomic) int NUMBER_OF_BACKGROUND_SIMUL;
@property(nonatomic) float DEFAULT_POPUP_WIDTH_TO_CHAR_RATIO;
@property(nonatomic) float DEFAULT_POPUP_HEIGHT_TO_CHAR_RATIO;
@property(nonatomic) float SPRITE_SCALE;
@property(nonatomic) CGSize MIN_POPUP_SIZE;
@property(nonatomic) CGSize MAX_POPUP_SIZE;
@property (nonatomic) NSString* POPUP_FONT_NAME;
@property (nonatomic) NSURL *dayTrackURL;
@property (nonatomic) NSURL *nightTrackURL;
@property (nonatomic) NSURL *savannaTrackURL;
//@property (nonatomic) BOOL enableHighResTextures;
@property (nonatomic) BOOL enableAds;
@property (nonatomic) Device deviceType;




+ (instancetype)sharedInstance;


@end
