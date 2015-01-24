//
//  GameDataManager.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 1/23/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "GameDataManager.h"
#import "LevelCellParser.h"
#import "ChapterCellParser.h"
@interface GameDataManager ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation GameDataManager

-(instancetype)initSingleton{
    //  NSLog(@"initialize GameDataManager singleton");

    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static GameDataManager* sharedSingleton = nil;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[GameDataManager alloc] initSingleton];
    });
    return sharedSingleton;
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
            NSLog(@"chapter name: %@", [managedObject valueForKey:@"name"]);
            NSLog(@"chapter image name: %@", [managedObject valueForKey:@"imageName"]);
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Level"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"chapter", managedObject];
            [fetchRequest setPredicate:predicate];
            NSError *fetchError = nil;
            NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
            
            if (!fetchError) {
                for (NSManagedObject* levelObject in result) {
                    NSLog(@"level name: %@", [levelObject valueForKey:@"name"]);
                    NSLog(@"level image name: %@", [levelObject valueForKey:@"imageName"]);
                    NSLog(@"time to beat level: %@", [levelObject valueForKey:@"timeToBeatLevel"]);

                }
                
                
            } else {
                NSLog(@"Error fetching data.");
                NSLog(@"%@, %@", fetchError, fetchError.localizedDescription);
            }

        }
        
    }
    else {
        NSLog(@"Error fetching data.");
        NSLog(@"%@, %@", fetchError, fetchError.localizedDescription);
    }
}

-(void)prepopulateGameData{
    [[LevelCellParser alloc] prepopulateLevelCells];
    [[ChapterCellParser alloc] prepopulateLevelCells];

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
