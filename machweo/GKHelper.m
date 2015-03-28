//
//  GKHelper.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 3/25/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "GKHelper.h"

@implementation GKHelper{
    GKLeaderboard *leaderBoard;
    NSArray* topTenGlobalScores;
    NSArray* topTenFriendsScores;
    NSUInteger localHighScore;
}

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

-(void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    //Block is called each time GameKit automatically authenticates
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        NSLog(@"viewController: %@", viewController);
        
        //      [self setLastError:error];
        if (viewController)
        {
            [_presentingVC presentViewController:viewController animated:YES completion:nil];
            
        }
        if (localPlayer.isAuthenticated)
        {
            [self authenticatedPlayer];
            [self loadLeaderboardInfo];
        }
        else
        {
            [self disableGameCenter];
        }
    };
}

-(void)authenticatedPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    // [[NSNotificationCenter defaultCenter]postNotificationName:AUTHENTICATED_NOTIFICATION object:nil];
    NSLog(@"Local player:%@ authenticated into game center",localPlayer.playerID);
    _gcEnabled = true;
}

-(void)disableGameCenter
{
    //A notification so that every observer responds appropriately to disable game center features
    // [[NSNotificationCenter defaultCenter]postNotificationName:UNAUTHENTICATED_NOTIFICATION object:nil];
    NSLog(@"Disabled game center");
    _gcEnabled = false;
}

- (void) showGameCenter
{
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = _presentingVC;
        [_presentingVC presentViewController: gameCenterController animated: YES completion:nil];
    }
}

- (void) reportScore: (int64_t) score{
    if (score > localHighScore) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"congratulate player on new high score" object:nil];
    }
    //for (GKLeaderboard* lb in _leaderboards) {
        GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier: leaderBoard.identifier];
        scoreReporter.value = score;
        scoreReporter.context = 0;
        NSArray *scores = @[scoreReporter];
        [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
           // NSLog(@"score reported for %@", lb.identifier);
            //Do something interesting here.
            //no, haha jk
        }];
    //}
}

- (void) loadLeaderboardInfo
{
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
        leaderBoard = leaderboards.firstObject;
        //NSLog(@"leaderBoard: %@", leaderBoard);
        [self loadTopTenFriendScores];
        [self loadTopTenGlobalScores];
       

    }];
}

- (void) loadTopTenGlobalScores
{
    if (leaderBoard != nil)
    {
        leaderBoard.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderBoard.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderBoard.range = NSMakeRange(1,10);
        [leaderBoard loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if (error != nil)
            {
                // handle the error.
            }
            if (scores != nil)
            {
                // process the score information.
            }
            //return scores;
            topTenGlobalScores = scores;
            //NSLog(@"top10GlobalScores: %@", topTenGlobalScores);

        }];
    }
    //return leaderboardRequest.scores;



}

- (void) loadTopTenFriendScores
{
    if (leaderBoard != nil)
    {
        leaderBoard.playerScope = GKLeaderboardPlayerScopeFriendsOnly;
        leaderBoard.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderBoard.range = NSMakeRange(1,10);
        [leaderBoard loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if (error != nil)
            {
                // handle the error.
            }
            if (scores != nil)
            {
                // process the score information.
            }
            //return scores;
            topTenFriendsScores = scores;
           // NSLog(@"topTenFriendsScores: %@", topTenFriendsScores);
            localHighScore = (NSUInteger)leaderBoard.localPlayerScore.value;
           // NSLog(@"localHighScore: %lu", localHighScore);

        }];
    }
    
}

-(NSArray*) retrieveTopTenFriendScores{
    return topTenFriendsScores;
}

-(NSArray*) retrieveTopTenGlobalScores{
    return topTenGlobalScores;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static GKHelper* sharedSingleton = nil;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[GKHelper alloc] init];
    });
    return sharedSingleton;
}

@end
