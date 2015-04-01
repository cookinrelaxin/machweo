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
    NSUInteger currentScore;
}

-(instancetype)init{
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSUInteger theHighScore = [defaults integerForKey:@"Highscore"];
        _localHighScore = theHighScore;
       // NSLog(@"theHighScore: %lu", (unsigned long)theHighScore);
        
    }
    return self;
}

-(void)setCurrentScore:(NSUInteger)score{
    currentScore = score;
}

-(void)authenticateLocalPlayer
{
    __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    //Block is called each time GameKit automatically authenticates
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
       // NSLog(@"viewController: %@", viewController);
        
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
    _gcEnabled = true;
    _playerName = localPlayer.alias;
}

-(void)disableGameCenter
{
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

- (void) reportScore{
    if (currentScore > _localHighScore) {
        if (_gcEnabled) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"congratulate player on new high score" object:nil];
            GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier: leaderBoard.identifier];
            scoreReporter.value = currentScore;
            scoreReporter.context = 0;
            NSArray *scores = @[scoreReporter];
            [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
            }];
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:(u_int64_t)currentScore forKey:@"Highscore"];
        [defaults synchronize];
    }
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
            if ((NSUInteger)leaderBoard.localPlayerScore.value > _localHighScore) {
                _localHighScore = (NSUInteger)leaderBoard.localPlayerScore.value;
            }
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
