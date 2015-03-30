//
//  SoundManager.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 3/29/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "SoundManager.h"
const u_int8_t maxVol_total = 2;
const u_int8_t maxVol_day = 1;
const u_int8_t maxVol_night = 1;



@implementation SoundManager{
    Constants* constants;
    AVAudioPlayer* currentTrack;
    Biome currentBiome;
}

-(instancetype)initTracks{
    if (self = [super init]) {
        constants = [Constants sharedInstance];
        NSError *error_day;
        _dayTrack = [[AVAudioPlayer alloc] initWithContentsOfURL:constants.dayTrackURL error:&error_day];
        NSError *error_night;
        _nightTrack = [[AVAudioPlayer alloc] initWithContentsOfURL:constants.nightTrackURL error:&error_night];
        NSError *error_savanna;
        _savannaTrack = [[AVAudioPlayer alloc] initWithContentsOfURL:constants.savannaTrackURL error:&error_savanna];
        _savannaTrack.numberOfLoops = -1;
        _savannaTrack.volume = 0;
        [_savannaTrack prepareToPlay];
        [_savannaTrack play];
        NSError *error_sahara;
        _saharaTrack = [[AVAudioPlayer alloc] initWithContentsOfURL:constants.saharaTrackURL error:&error_sahara];
        _saharaTrack.numberOfLoops = -1;
        _saharaTrack.volume = 0;
        [_saharaTrack prepareToPlay];
        [_saharaTrack play];
        NSError *error_jungle;
        _jungleTrack = [[AVAudioPlayer alloc] initWithContentsOfURL:constants.jungleTrackURL error:&error_jungle];
        _jungleTrack.numberOfLoops = -1;
        _jungleTrack.volume = 0;
        [_jungleTrack prepareToPlay];
        [_jungleTrack play];

        currentBiome = 9999;
    
    }
    return self;
}

-(void)startNatureSounds{
//    [_dayTrack prepareToPlay];
//    [_dayTrack play];
//    [_nightTrack prepareToPlay];
//    [_nightTrack play];

}

-(void)calculateNatureTrackVolumesForTimeOfDay:(u_int32_t)timeOfDay{
    _dayTrack.volume = [self calculateDayVolumeForTimeOfDay:timeOfDay];
    //NSLog(@"_dayTrack.volume: %f", _dayTrack.volume);
    _nightTrack.volume = [self calculateNightVolumeForTimeOfDay:timeOfDay];
    //NSLog(@"_nightTrack.volume: %f", _nightTrack.volume);

}

-(float)calculateDayVolumeForTimeOfDay:(u_int32_t)timeOfDay{
    return maxVol_total * (cosf((M_PI / 12) * (timeOfDay - 12)) + 1);
}

-(float)calculateNightVolumeForTimeOfDay:(u_int32_t)timeOfDay{
    return maxVol_total * (cosf((M_PI / 12) * (timeOfDay + 12)) + 1);
}

-(void)playMusicForBiome:(Biome)biome{
    if (biome != currentBiome) {
        currentBiome = biome;
        switch (biome) {
            case sahara:
                [self fadeVolumeOut:currentTrack];
                currentTrack = _saharaTrack;
                [self fadeVolumeIn:_saharaTrack];
                //_saharaTrack.currentTime = 0;
                //[_saharaTrack prepareToPlay];
                //[_saharaTrack play];
                return;
            case savanna:
                [self fadeVolumeOut:currentTrack];
                currentTrack = _savannaTrack;
                [self fadeVolumeIn:_savannaTrack];
                //_savannaTrack.currentTime = 0;
                //[_savannaTrack prepareToPlay];
                //[_savannaTrack play];
                return;
            case jungle:
                [self fadeVolumeOut:currentTrack];
                currentTrack = _jungleTrack;
                [self fadeVolumeIn:_jungleTrack];
               // _jungleTrack.currentTime = 0;
                //[_jungleTrack prepareToPlay];
                //[_jungleTrack play];
                return;
        }
    }

}
//
-(void)fadeVolumeIn:(AVAudioPlayer*)audioPlayer {
    if ((audioPlayer.volume < 1)) {
        //NSLog(@"fade in");
        audioPlayer.volume += 0.0010;
        double delayInSeconds = .01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self fadeVolumeIn:audioPlayer];
        });
    }
    else{
        audioPlayer.volume = 1;
        return;
    }
}

-(void)fadeVolumeOut:(AVAudioPlayer*)audioPlayer{
    //NSLog(@"backgroundMusicPlayer.volume: %f", backgroundMusicPlayer.volume);
        //NSLog(@"fade out");
        if ((audioPlayer.volume - 0.0040) < 0) {
            //NSLog(@"nullify the background music");
            audioPlayer.volume = 0;
            //currentTrack = newPlayer;
            //currentTrack.volume = 1;
//            [self fadeVolumeIn:currentTrack];
//            [currentTrack prepareToPlay];
//            [currentTrack play];
            //[currentTrack playAtTime:0];

            return;
        }
        audioPlayer.volume = audioPlayer.volume - 0.0020;
        //[self performSelector:@selector(fadeVolumeOut:audioPlayer) withObject:nil afterDelay:0.1];
        double delayInSeconds = .01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self fadeVolumeOut:audioPlayer];
        });

}

@end
