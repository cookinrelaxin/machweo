//
//  SoundManager.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 3/29/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "SoundManager.h"
//const u_int8_t maxVol_total = 2;
//const u_int8_t maxVol_day = 1;
//const u_int8_t maxVol_night = 1;

//float maxVol_day_savanna = .11;
//float maxVol_day_sahara = .025;
//float maxVol_day_jungle = .16;
//float maxVol_night_savanna = .11;
//float maxVol_night_sahara = .025;
//float maxVol_night_jungle = .16;

float maxVol_day_savanna = .05;
float maxVol_day_sahara = .025;
float maxVol_day_jungle = .08;
float maxVol_night_savanna = .05;
float maxVol_night_sahara = .025;
float maxVol_night_jungle = .08;

float maxVol_music = .8;

@implementation SoundManager{
    Constants* constants;
   // AVAudioPlayer* currentTrack;
    Biome currentBiome;
    BOOL firstNaturePlayed;
    BOOL isDay;
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
       // [_savannaTrack play];
//        NSError *error_sahara;
//        _saharaTrack = [[AVAudioPlayer alloc] initWithContentsOfURL:constants.saharaTrackURL error:&error_sahara];
//        _saharaTrack.numberOfLoops = -1;
//        _saharaTrack.volume = 1;
//        //[_saharaTrack prepareToPlay];
//        //[_saharaTrack play];
//        NSError *error_jungle;
//        _jungleTrack = [[AVAudioPlayer alloc] initWithContentsOfURL:constants.jungleTrackURL error:&error_jungle];
//        _jungleTrack.numberOfLoops = -1;
//        _jungleTrack.volume = 1;
//        //[_jungleTrack prepareToPlay];
//        //[_jungleTrack play];
//
//        currentBiome = 9999;
    
    }
    return self;
}
-(void)startSounds{
   // [_dayTrack prepareToPlay];
    [_dayTrack play];
   // [_nightTrack prepareToPlay];
    [_nightTrack play];
   // [_savannaTrack prepareToPlay];
    [_savannaTrack play];
}

-(void)fadeIntoNightForBiome:(Biome)biome{
    isDay = false;
    currentBiome = biome;
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
}



-(void)fadeIntoDayForBiome:(Biome)biome{
    isDay = true;
    currentBiome = biome;
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
}

-(void)adjustNatureVolumeToBiome:(Biome)biome{
    if (biome != currentBiome) {
        currentBiome = biome;
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
    }
}

//-(void)calculateNatureTrackVolumesForTimeOfDay:(u_int32_t)timeOfDay{
//    _dayTrack.volume = [self calculateDayVolumeForTimeOfDay:timeOfDay];
//    //NSLog(@"_dayTrack.volume: %f", _dayTrack.volume);
//    _nightTrack.volume = [self calculateNightVolumeForTimeOfDay:timeOfDay];
//    //NSLog(@"_nightTrack.volume: %f", _nightTrack.volume);
//
//}
//
//-(float)calculateDayVolumeForTimeOfDay:(u_int32_t)timeOfDay{
//    return maxVol_total * (cosf((M_PI / 12) * (timeOfDay - 12)) + 1);
//}
//
//-(float)calculateNightVolumeForTimeOfDay:(u_int32_t)timeOfDay{
//    return maxVol_total * (cosf((M_PI / 12) * (timeOfDay + 12)) + 1);
//}

//-(void)playMusicForBiome:(Biome)biome{
//    if (biome != currentBiome) {
//        currentBiome = biome;
//        switch (biome) {
//            case sahara:{
//                //[_saharaTrack prepareToPlay];
//                [self fadeVolumeOut:currentTrack andThenFadeIn:_saharaTrack];
//                currentTrack = _saharaTrack;
//                return;
//            }
//            case savanna:{
//                //[_savannaTrack prepareToPlay];
//                [self fadeVolumeOut:currentTrack andThenFadeIn:_savannaTrack];
//                currentTrack = _savannaTrack;
//                return;
//            }
//            case jungle:{
//                //[_jungleTrack prepareToPlay];
//                [self fadeVolumeOut:currentTrack andThenFadeIn:_jungleTrack];
//                currentTrack = _jungleTrack;
//                return;
//            }
//        }
//    }
//
//}
//
//-(void)fadeVolumeIn:(AVAudioPlayer*)audioPlayer {
//    if ((audioPlayer.volume < 1)) {
//        audioPlayer.volume += -.1;
//        double delayInSeconds = 0.01;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [self fadeVolumeIn:audioPlayer];
//        });
//    }
//    else{
//        audioPlayer.volume = 1;
//        return;
//    }
//}

//-(void)fadeVolumeOut:(AVAudioPlayer*)audioPlayer andThenFadeIn:(AVAudioPlayer*)newPlayer{
//    if (!firstTrackPlayed) {
//        firstTrackPlayed = true;
//        newPlayer.volume = 1;
//        [newPlayer play];
//        return;
//    }
//        if ((audioPlayer.volume - 0.01) < 0) {
//            audioPlayer.volume = 0;
//            [audioPlayer stop];
//            newPlayer.currentTime = 0;
//            newPlayer.volume = 1;
//            [newPlayer prepareToPlay];
//            [newPlayer play];
//            return;
//        }
//        audioPlayer.volume = audioPlayer.volume - .005;
//        double delayInSeconds = .001;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [self fadeVolumeOut:audioPlayer andThenFadeIn:newPlayer];
//        });
//
//}

-(void)fadeVolumeOut:(AVAudioPlayer*)audioPlayer minVol:(float)minVol{
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

@end
