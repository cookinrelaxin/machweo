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

#import "LevelCell.h"
#import "ChapterCell.h"

@interface AppDelegate ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation AppDelegate

-(void)prepopulateGameData{
    LevelCellParser* cellParser = [LevelCellParser sharedInstance];
    for (LevelCell* LevelCell in cellParser.levels) {
        <#statements#>
    }
    
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

-(void)loadGameData{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Chapter"];
    // Execute Fetch Request
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    if (result.count == 0) {
        [self prepopulateGameData];
    }
    
    if (!fetchError) {
        for (NSManagedObject *managedObject in result) {
            NSLog(@"%@, %@", [managedObject valueForKey:@"name"], [managedObject valueForKey:@"imageName"]);
        }
        
    } else {
        NSLog(@"Error fetching data.");
        NSLog(@"%@, %@", fetchError, fetchError.localizedDescription);
    }

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
    [Constants sharedInstance];
    [self loadGameData];
    [self setUpNavigationBar];
    
   // NSLog(@"self.managedObjectContext: %@", self.managedObjectContext);
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

#pragma mark - Core Data Stack
- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "yea.coredatatest" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"gameModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"gameModel.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end
