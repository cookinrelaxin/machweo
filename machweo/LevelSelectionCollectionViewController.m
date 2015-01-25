//
//  LevelSelectionCollectionViewController.m
//  tgrrn
//
//  Created by John Feldcamp on 1/6/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "LevelSelectionCollectionViewController.h"
#import "LevelCollectionViewCell.h"
#import "GameViewController.h"
#import <CoreData/CoreData.h>
#import "GameDataManager.h"

@implementation LevelSelectionCollectionViewController{
    NSArray* levels;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Level"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"chapter", _chapter];
    [fetchRequest setPredicate:predicate];
    NSError *fetchError = nil;
    if (!fetchError) {
        levels = [[GameDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];

    } else {
        NSLog(@"Error fetching data.");
        NSLog(@"%@, %@", fetchError, fetchError.localizedDescription);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return levels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LevelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"levelViewCell" forIndexPath:indexPath];
    
    NSManagedObject* currentLevel = [levels objectAtIndex:[indexPath row]];
    cell.cellLabel.text = [currentLevel valueForKey:@"name"];
    cell.cellImageView.image = [UIImage imageNamed:[currentLevel valueForKey:@"imageName"]];
    cell.timeToBeatLevelLabel.text = [self calculateBestTimeStringForCurrentLevel:currentLevel];
    return cell;
}

-(NSString*)calculateBestTimeStringForCurrentLevel:(NSManagedObject*)level{
    NSString* timeString;
    
    double bestTime = [(NSNumber*)[level valueForKey:@"timeToBeatLevel"] doubleValue];
    if (bestTime == 0) {
        timeString = @"not beaten yet!";
    }
    else{
        NSString* rawTimeString = [[NSString stringWithFormat:@"%f", bestTime] substringToIndex:4];
        timeString = [NSString stringWithFormat:@"best time: %@ seconds!", rawTimeString];

    }
    return timeString;
}

-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView* view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"levelsHeader" forIndexPath:indexPath];
    return view;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"level selection to game"])
    {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        NSManagedObject* relevantLevel = [levels objectAtIndex:selectedIndexPath.row];
        GameViewController *destination = [segue destinationViewController];
        destination.level = relevantLevel;
    }
}
@end
