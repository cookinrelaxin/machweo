//
//  SoundManager.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 3/29/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"

@interface SoundManager : NSObject
//nature tracks
@property(nonatomic, strong) AVAudioPlayer* dayTrack;
@property(nonatomic, strong) AVAudioPlayer* nightTrack;

@property(nonatomic, strong) AVAudioPlayer* savannaTrack; //the og beats
@property(nonatomic, strong) AVAudioPlayer* jungleTrack;
@property(nonatomic, strong) AVAudioPlayer* saharaTrack;
-(instancetype)initTracks;
//defined over [0, 24] in hours;
-(void)calculateNatureTrackVolumesForTimeOfDay:(u_int32_t)timeOfDay;
-(void)startNatureSounds;
-(void)playMusicForBiome:(Biome)biome;



@end
