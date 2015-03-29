//
//  GKHelper.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 3/25/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "MainMenuControllerViewController.h"

@interface GKHelper : NSObject
+ (instancetype)sharedInstance;
- (void)authenticateLocalPlayer;
- (void) reportScore: (int64_t) score;
- (void) showGameCenter;
- (NSArray*) retrieveTopTenGlobalScores;
- (NSArray*) retrieveTopTenFriendScores;


//- (void) loadLeaderboardInfo;


@property (nonatomic, strong) MainMenuControllerViewController* presentingVC;
@property (nonatomic) BOOL gcEnabled;
@property (nonatomic) NSUInteger localHighScore;
@property (nonatomic) NSString* playerName;


//@property (nonatomic, strong) UIViewController* authenticationVC;
//@property (nonatomic, strong) UIViewController* generalGKVC;



@end
