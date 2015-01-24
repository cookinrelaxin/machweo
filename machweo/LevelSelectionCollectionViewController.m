////
////  LevelSelectionCollectionViewController.m
////  tgrrn
////
////  Created by John Feldcamp on 1/6/15.
////  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
////
//
//#import "LevelSelectionCollectionViewController.h"
//#import "LevelCollectionViewCell.h"
//#import "GameViewController.h"
//
//@implementation LevelSelectionCollectionViewController{
//    NSArray* levels;
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    levels = [_chapter levelCells];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//#pragma mark <UICollectionViewDataSource>
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 1;
//}
//
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return levels.count;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    LevelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"levelViewCell" forIndexPath:indexPath];
//    
//    LevelCell* currentLevelCell = [levels objectAtIndex:[indexPath row]];
//    cell.cellLabel.text = currentLevelCell.name;
//    cell.cellImageView.image = [UIImage imageNamed:currentLevelCell.imageName];
//    cell.timeToBeatLevelLabel.text = [NSString stringWithFormat:@"%d", currentLevelCell.timeToBeatLevel];;
//    return cell;
//}
//
//-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    UICollectionReusableView* view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"levelsHeader" forIndexPath:indexPath];
//    return view;
//    
//}
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"level selection to game"])
//    {
//        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
//        LevelCell* relevantLevel = [levels objectAtIndex:selectedIndexPath.row];
//        GameViewController *destination = [segue destinationViewController];
//        destination.levelToLoad = relevantLevel.name;
//        destination.currentChapter = _chapter;
//    }
//}
//@end
