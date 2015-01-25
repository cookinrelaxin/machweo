//
//  ChapterSelectionCollectionViewController.m
//  tgrrn
//
//  Created by John Feldcamp on 1/5/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "ChapterSelectionCollectionViewController.h"
#import "LevelCellParser.h"
#import "ChapterCellParser.h"
#import "LevelSelectionCollectionViewController.h"
#import "GameDataManager.h"

@implementation ChapterSelectionCollectionViewController{
    //full of NSStrings for the names of the files
    //NSMutableArray* levels;
    NSArray* chapters;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //chapters = [ChapterCellParser sharedInstance].chapters;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Chapter"];
    NSError *fetchError = nil;
   // NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
   // chapters = [[GameDataManager sharedInstance].managedObjectContext
    chapters = [[GameDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
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
    return chapters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChapterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"chapterViewCell" forIndexPath:indexPath];
    NSManagedObject* currentChapter = [chapters objectAtIndex:[indexPath row]];
    
   // ChapterCell* currentChapterCell = [chapters objectAtIndex:[indexPath row]];
    cell.cellLabel.text = [currentChapter valueForKey:@"name"];
    cell.cellImageView.image = [UIImage imageNamed:[currentChapter valueForKey:@"imageName"]];
    return cell;
}

-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView* view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"chaptersHeader" forIndexPath:indexPath];
    return view;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"chapter to level"])
    {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        NSManagedObject* relevantChapter = [chapters objectAtIndex:selectedIndexPath.row];
        LevelSelectionCollectionViewController *destination = [segue destinationViewController];
        destination.chapter = relevantChapter;
        
        
    }
}



@end
