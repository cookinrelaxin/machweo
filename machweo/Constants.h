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
@property (readonly, nonatomic) int LINE_Z_POSITION;
@property (readonly, nonatomic) int HUD_Z_POSITION;


@property (readonly, nonatomic) float BRUSH_FRACTION_OF_PLAYER_SIZE;
@property (readonly, nonatomic) int OBSTACLE_SIZE_MINIMUM;
@property (readonly, nonatomic) int OBSTACLE_SIZE_MAXIMUM;

@property (readonly, nonatomic) CGSize IDEAL_SCREEN_SIZE;
@property (readonly, nonatomic) CGVector SCALE_COEFFICIENT;
@property (readonly, nonatomic) float Y_PARALLAX_COEFFICIENT;

//HUD
@property (readonly, nonatomic) float TIMER_LABEL_FONT_SIZE;
@property (readonly, nonatomic) UIColor* TIMER_LABEL_FONT_COLOR;

@property (readonly, nonatomic) float LOADING_LABEL_FONT_SIZE;
@property (readonly, nonatomic) UIColor* LOADING_LABEL_FONT_COLOR;
@property (readonly, nonatomic) NSString* LOADING_LABEL_FONT_NAME;

@property (readonly, nonatomic) float RESTART_LABEL_FONT_SIZE;
@property (readonly, nonatomic) UIColor* RESTART_LABEL_FONT_COLOR;
@property (readonly, nonatomic) NSString* RESTART_LABEL_FONT_NAME;


@property (readonly, nonatomic) float RETURN_TO_MENU_LABEL_FONT_SIZE;
@property (readonly, nonatomic) UIColor* RETURN_TO_MENU_LABEL_FONT_COLOR;
@property (readonly, nonatomic) NSString* RETURN_TO_MENU_LABEL_FONT_NAME;

@property(readonly, nonatomic) int PLAYER_HIT_CATEGORY;
@property(readonly, nonatomic) int OBSTACLE_HIT_CATEGORY;

@property(readonly, nonatomic) int DEFAULT_COIN_VALUE;


+ (instancetype)sharedInstance;


@end
