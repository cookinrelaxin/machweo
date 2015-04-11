//
//  SoundManager.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 3/29/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "SoundManager.h"
#import <SpriteKit/SpriteKit.h>

float maxVol_day_savanna = .05;
float maxVol_day_sahara = .025;
float maxVol_day_jungle = .08;
float maxVol_night_savanna = .05;
float maxVol_night_sahara = .025;
float maxVol_night_jungle = .08;
float maxVol_music = .6;

@implementation SoundManager{
    Constants* constants;
    Biome currentBiome;
    
    BOOL firstNaturePlayed;
    BOOL isDay;
    BOOL muted;
    
    BOOL musicStopped;
}

-(instancetype)initTracks{
    if (self = [super init]) {
        constants = [Constants sharedInstance];
        NSError *error_day;
        _dayTrack = [[AVAudioPlayer alloc] initWithContentsOfURL:constants.dayTrackURL error:&error_day];
        _dayTrack.numberOfLoops = -1;
        _dayTrack.volume = 0;
        [_dayTrack prepareToPlay];
        NSError *error_night;
        _nightTrack = [[AVAudioPlayer alloc] initWithContentsOfURL:constants.nightTrackURL error:&error_night];
        _nightTrack.numberOfLoops = -1;
        _nightTrack.volume = 0;
        [_nightTrack prepareToPlay];
        NSError *error_savanna;
        _savannaTrack = [[AVAudioPlayer alloc] initWithContentsOfURL:constants.savannaTrackURL error:&error_savanna];
        _savannaTrack.numberOfLoops = -1;
        _savannaTrack.volume = maxVol_music;
        [_savannaTrack prepareToPlay];
        //[_savannaTrack play];
        
        [self preloadSounds];

    }
    return self;
}

-(void)preloadSounds{
    [constants.SOUND_ACTIONS setValue:[self getSoundActionForName:@"button2" andVolume:1] forKey:@"button2.mp3"];
    //[constants.SOUND_ACTIONS setValue:[self getSoundActionForName:@"jump" andVolume:.5] forKey:@"jump.mp3"];
    [constants.SOUND_ACTIONS setValue:[self getSoundActionForName:@"swoosh" andVolume:1] forKey:@"swoosh.mp3"];
    [constants.SOUND_ACTIONS setValue:[self getSoundActionForName:@"projectorDown" andVolume:1] forKey:@"projectorDown.mp3"];
    [constants.SOUND_ACTIONS setValue:[self getSoundActionForName:@"projectorUp" andVolume:1] forKey:@"projectorUp.mp3"];
    [constants.SOUND_ACTIONS setValue:[self getSoundActionForName:@"treegrow2" andVolume:.4] forKey:@"treegrow2.mp3"];
    [constants.SOUND_ACTIONS setValue:[self getSoundActionForName:@"treegrow" andVolume:.6] forKey:@"treegrow.mp3"];

    //[constants.SOUND_ACTIONS setValue:[self getSoundActionForName:@"flagFlap" andVolume:1] forKey:@"flagFlap.mp3"];
    //[constants.SOUND_ACTIONS setValue:[self getSoundActionForName:@"line" andVolume:.1] forKey:@"line.mp3"];
}

-(SKAction*)getSoundActionForName:(NSString*)name andVolume:(float)volume{
    NSError *error;
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"mp3"];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    [player setVolume:volume];
    [player prepareToPlay];
    SKAction* playAction = [SKAction runBlock:^{
        [player play];
    }];
    return playAction;
}

-(void)startSounds{
    [self startMusic];
    [self startNatureSounds];
}

-(void)startNatureSounds{
    [_nightTrack play];
    [_dayTrack play];
}

-(void)startMusic{
    musicStopped = false;
    [_savannaTrack play];
}

-(void)fadeIntoNightForBiome:(Biome)biome{
    isDay = false;
    currentBiome = biome;
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

-(void)fadeVolumeOut:(AVAudioPlayer*)audioPlayer minVol:(float)minVol{
    if ((audioPlayer.volume - 0.015) < minVol) {
        audioPlayer.volume = minVol;
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
        audioPlayer.volume = maxVol;
        return;
    }
}

-(void)mute{
    if (muted) {
        muted = false;
        NSLog(@"muted = false");
        [_dayTrack play];
        [_nightTrack play];
        if (!musicStopped) {
            [_savannaTrack play];
        }
    }
    else{
        muted = true;
        NSLog(@"muted = true");
        [_dayTrack pause];
        [_nightTrack pause];
        if (!musicStopped) {
            [_savannaTrack pause];
        }
    }
}

-(void)restoreSounds{
    [self mute];
}
-(void)stopMusic{
    musicStopped = true;
    [_savannaTrack pause];
    _savannaTrack.currentTime = 0;
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
