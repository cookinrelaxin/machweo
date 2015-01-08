//
//  AppDelegate.m
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 10/19/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "LevelCellParser.h"
#import "ChapterCellParser.h"

//#import "LevelCell.h"
//#import "ChapterCell.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(void)loadSingletons{
    [Constants sharedInstance];
    [LevelCellParser sharedInstance];
    
    
//    for (NSString* key in [LevelCellParser sharedInstance].levels) {
//        LevelCell* levelCell = [[LevelCellParser sharedInstance].levels objectForKey:key];
//        NSLog(@"levelCell.name: %@", levelCell.name);
//        NSLog(@"levelCell.imageName: %@", levelCell.imageName);
//
//    }
    
    [ChapterCellParser sharedInstance];
    
//    for (ChapterCell* chapterCell in [ChapterCellParser sharedInstance].chapters) {
//        NSLog(@"chapterCell.name: %@", chapterCell.name);
//        NSLog(@"chapterCell.imageName: %@", chapterCell.imageName);
//        for (LevelCell* levelCell in chapterCell.levelCells) {
//            NSLog(@"levelCell.name: %@", levelCell.name);
//            NSLog(@"levelCell.imageName: %@", levelCell.imageName);
//        }
//
//    }
}

#warning incomplete method
-(void)setUpNavigationBar{
   // UINavigationController* nav = (UINavigationController *)self.window.rootViewController;
//    NSLog(@"nav: %@", nav);
//    if ([nav respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        nav.interactivePopGestureRecognizer.enabled = NO;
//    }
    //nav.interactivePopGestureRecognizer.enabled = NO;

    
}
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self loadSingletons];
    [self setUpNavigationBar];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
