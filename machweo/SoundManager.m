//
//  SoundManager.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 3/29/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "SoundManager.h"

float maxVol_day_savanna = .05;
float maxVol_day_sahara = .025;
float maxVol_day_jungle = .08;
float maxVol_night_savanna = .05;
float maxVol_night_sahara = .025;
float maxVol_night_jungle = .08;

float maxVol_music = .8;

@implementation SoundManager{
    Constants* constants;
    Biome currentBiome;
    BOOL firstNaturePlayed;
    BOOL isDay;
    BOOL muted;
    
  //  float previousDayVolume;
   // float previousNightVolume;

}

-(instancetype)initTracks{
    if (self = [super init]) {
        constants = [Constants sharedInstance];
        NSError *error_day;
        _dayTrack = [[AVAudioPlayer alloc] initWithContentsOfURL:constants.dayTrackURL error:&error_day];
        _dayTrack.numberOfLoops = -1;
        _dayTrack.volume = 0;
        [_dayTrack prepareToPlay];
//        [_dayTrack play];

        NSError *error_night;
        _nightTrack = [[AVAudioPlayer alloc] initWithContentsOfURL:constants.nightTrackURL error:&error_night];
        _nightTrack.numberOfLoops = -1;
        _nightTrack.volume = 0;
        [_nightTrack prepareToPlay];
       // [_nightTrack play];

        NSError *error_savanna;
        _savannaTrack = [[AVAudioPlayer alloc] initWithContentsOfURL:constants.savannaTrackURL error:&error_savanna];
        _savannaTrack.numberOfLoops = -1;
        _savannaTrack.volume = maxVol_music;
        [_savannaTrack prepareToPlay];
        [_savannaTrack play];
    }
    return self;
}
-(void)startSounds{
    [_dayTrack play];
    [_nightTrack play];
    [_savannaTrack play];
}

-(void)fadeIntoNightForBiome:(Biome)biome{

    isDay = false;
    currentBiome = biome;
  //  if (!muted) {
        //NSLog(@"fadeIntoNight");
            [self fadeVolumeOut:_dayTrack minVol:0];
        float maxVol;
        switch (biome) {
            case jungle:
                maxVol = maxVol_night_jungle;
                break;
            case sahara:
                maxVol = maxVol_night_sahara;
                break;
            case savanna:
                maxVol = maxVol_night_savanna;
                break;
            default:
                break;
        }
        [self fadeVolumeIn:_nightTrack maxVol:maxVol];
   // }
}



-(void)fadeIntoDayForBiome:(Biome)biome{
    isDay = true;
    currentBiome = biome;
    //if (!muted) {
        //NSLog(@"fadeIntoDay");
            [self fadeVolumeOut:_nightTrack minVol:0];
        float maxVol;
        switch (biome) {
            case jungle:
                maxVol = maxVol_day_jungle;
                break;
            case sahara:
                maxVol = maxVol_day_sahara;
                break;
            case savanna:
                maxVol = maxVol_day_savanna;
                break;
            default:
            break;
        }
            [self fadeVolumeIn:_dayTrack maxVol:maxVol];
    //}
}

-(void)adjustNatureVolumeToBiome:(Biome)biome{
    if (biome != currentBiome) {
        currentBiome = biome;
        //if (!muted) {
            switch (biome) {
                case jungle:{
                    if (isDay) {
                        if (_dayTrack.volume > maxVol_day_jungle) {
                            [self fadeVolumeOut:_dayTrack minVol:maxVol_day_jungle];
                        }
                        else if (_dayTrack.volume < maxVol_day_jungle) {
                            [self fadeVolumeIn:_dayTrack maxVol:maxVol_day_jungle];
                        }
                    }
                    else{
                        if (_nightTrack.volume > maxVol_night_jungle) {
                            [self fadeVolumeOut:_nightTrack minVol:maxVol_night_jungle];
                        }
                        else if (_nightTrack.volume < maxVol_night_jungle) {
                            [self fadeVolumeIn:_nightTrack maxVol:maxVol_night_jungle];
                        }
                    }
                }
                    break;
                case sahara:{
                    if (isDay) {
                        if (_dayTrack.volume > maxVol_day_sahara) {
                            [self fadeVolumeOut:_dayTrack minVol:maxVol_day_sahara];
                        }
                        else if (_dayTrack.volume < maxVol_day_sahara) {
                            [self fadeVolumeIn:_dayTrack maxVol:maxVol_day_sahara];
                        }
                    }
                    else{
                        if (_nightTrack.volume > maxVol_night_sahara) {
                            [self fadeVolumeOut:_nightTrack minVol:maxVol_night_sahara];
                        }
                        else if (_nightTrack.volume < maxVol_night_sahara) {
                            [self fadeVolumeIn:_nightTrack maxVol:maxVol_night_sahara];
                        }
                    }
                }
                    break;
                case savanna:{
                    if (isDay) {
                        if (_dayTrack.volume > maxVol_day_savanna) {
                            [self fadeVolumeOut:_dayTrack minVol:maxVol_day_savanna];
                        }
                        else if (_dayTrack.volume < maxVol_day_savanna) {
                            [self fadeVolumeIn:_dayTrack maxVol:maxVol_day_savanna];
                        }
                    }
                    else{
                        if (_nightTrack.volume > maxVol_night_savanna) {
                            [self fadeVolumeOut:_nightTrack minVol:maxVol_night_savanna];
                        }
                        else if (_nightTrack.volume < maxVol_night_savanna) {
                            [self fadeVolumeIn:_nightTrack maxVol:maxVol_night_savanna];
                        }
                    }
                }
                    break;
                default:
                    break;
            }
       // }
    }
}

-(void)fadeVolumeOut:(AVAudioPlayer*)audioPlayer minVol:(float)minVol{
//    if (muted) {
//        audioPlayer.volume = 0;
//        return;
//    }
    if ((audioPlayer.volume - 0.015) < minVol) {
        audioPlayer.volume = minVol;
        //NSLog(@"%@ faded out", audioPlayer);

        return;
    }
    audioPlayer.volume = audioPlayer.volume - .001;
    double delayInSeconds = .05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fadeVolumeOut:audioPlayer minVol:minVol];
    });

}

-(void)fadeVolumeIn:(AVAudioPlayer*)audioPlayer maxVol:(float)maxVol{
//    if (muted) {
//        audioPlayer.volume = 0;
//        return;
//    }
    if (!firstNaturePlayed) {
        firstNaturePlayed = true;
        audioPlayer.volume = maxVol;
        return;
    }
    if ((audioPlayer.volume < maxVol)) {
        audioPlayer.volume += .001;
        double delayInSeconds = .05;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self fadeVolumeIn:audioPlayer maxVol:maxVol];
        });
    }
    else{
       // NSLog(@"%@ faded in", audioPlayer);
        audioPlayer.volume = maxVol;
        return;
    }
}

-(void)mute{
   // NSLog(@"mute");
    if (muted) {
        muted = false;
//        _savannaTrack.volume = maxVol_music;
//        _dayTrack.volume = previousDayVolume;
//        _nightTrack.volume = previousNightVolume;
        [_dayTrack play];
        [_nightTrack play];
        [_savannaTrack play];
    }
    else{
        muted = true;
        [_dayTrack pause];
        [_nightTrack pause];
        [_savannaTrack pause];
        
//        previousDayVolume = _dayTrack.volume;
//        _dayTrack.volume = 0;
//        previousNightVolume = _nightTrack.volume;
//        _nightTrack.volume = 0;
//        _savannaTrack.volume = 0;
    }
}

-(void)restoreSounds{
    [self mute];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static SoundManager* sharedSingleton = nil;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[SoundManager alloc] initTracks];
    });
    return sharedSingleton;
}

@end
