//
//  LevelSelectionCollectionViewController.h
//  tgrrn
//
//  Created by John Feldcamp on 1/6/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface LevelSelectionCollectionViewController : UICollectionViewController
@property (nonatomic, strong) NSManagedObject* chapter;

@end
