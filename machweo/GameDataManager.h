//
//  GameDataManager.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 1/23/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface GameDataManager : NSObject

+ (instancetype)sharedInstance;
-(void)loadGameData;

- (void)saveContext;
- (NSManagedObjectContext *)managedObjectContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSURL *)applicationDocumentsDirectory;

@end
