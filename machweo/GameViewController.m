//
//  GameViewController.m
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 10/19/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "LoadingScene.h"
#import "Constants.h"
#import "LevelSelectionCollectionViewController.h"

@implementation GameViewController{
    UILabel *scoreLabel;
    UILabel *velocityLabel;
    BOOL gameLoaded;
    BOOL observersLoaded;
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {

    //}
    if (!gameLoaded) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.navigationBarHidden = true;
        gameLoaded = true;
        [self initGame];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = false;

}

-(void)initGame{

    __weak GameViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        GameScene *newScene = [[GameScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height) forLevel:_levelToLoad];
        newScene.backgroundColor = [UIColor lightGrayColor];
        newScene.scaleMode = SKSceneScaleModeResizeFill;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            //[weakSelf initializeLabels];
            if (!observersLoaded) {
                [weakSelf setUpObservers];
                observersLoaded = true;
            }
            [weakSelf refreshView];
            [((SKView*)weakSelf.view) presentScene:newScene];
        });

    });
    
    SKView * skView = (SKView *)self.view;
  //  skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    skView.ignoresSiblingOrder = YES;
    [self refreshView];
    LoadingScene* loadingScene = [[LoadingScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
    loadingScene.backgroundColor = [UIColor redColor];
    loadingScene.scaleMode = SKSceneScaleModeResizeFill;
    [skView presentScene:loadingScene];

}

-(void)refreshView{
    // a fucking hack needed to keep the size of the view correct.
    UIView* hackView = [UIView new];
    [self.view addSubview:hackView];
    [hackView removeFromSuperview];
}

-(void)setUpObservers{
    __weak GameViewController *weakSelf = self;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserverForName:@"return to menu"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         [((SKView*)weakSelf.view) presentScene:nil];
         [weakSelf returnToMenu];
     }];
    
    [center addObserverForName:@"restart game"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         [weakSelf initGame];
     }];
    
    [center addObserverForName:@"update velocity"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         [weakSelf updateVelocity:CGVectorFromString((NSString*)[notification.userInfo valueForKey:@"velocity"])];
     }];

}

-(void)initializeLabels{
    
    velocityLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 10, self.view.frame.origin.y + ((15/100) * self.view.frame.size.height), self.view.frame.size.width / 2, 20)];
    velocityLabel.text = @"velocity: 0, 0";
    velocityLabel.font=[UIFont boldSystemFontOfSize:15.0];
    velocityLabel.textColor=[UIColor whiteColor];
    velocityLabel.backgroundColor=[UIColor clearColor];
    [self.view addSubview:velocityLabel];
   

}

-(void)updateVelocity:(CGVector)velocity{
    velocityLabel.text = [NSString stringWithFormat:@"velocity: %f, %f", velocity.dx, velocity.dy];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SKView *skView = (SKView*)self.view;
    [skView presentScene:nil];
    
    if ([[segue identifier] isEqualToString:@"game to level selection"])
    {
        LevelSelectionCollectionViewController *destination = [segue destinationViewController];
        destination.chapter = _currentChapter;
    }


}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"chapter to level"])
//    {
//        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
//        ChapterCell* relevantChapter = [chapters objectAtIndex:selectedIndexPath.row];
//        LevelSelectionCollectionViewController *destination = [segue destinationViewController];
//        destination.levels = [relevantChapter levelCells];
//    }
//}

-(void)returnToMenu{
    [_restartButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}



- (BOOL)shouldAutorotate
{
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
