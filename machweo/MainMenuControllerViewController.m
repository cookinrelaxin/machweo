//
//  MainMenuControllerViewController.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/12/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "MainMenuControllerViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "MainMenuScene.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface MainMenuControllerViewController ()
@property (weak, nonatomic) IBOutlet UIButton *chaptersButton;
@property (weak, nonatomic) IBOutlet UIButton *highScoresButton;
@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *unlockablesButton;

@end

@implementation MainMenuControllerViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//}
//
//-(void)viewWillLayoutSubviews{
//    
//    MainMenuScene *newScene = [[MainMenuScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
//   // newScene.backgroundColor = [UIColor redColor];
//    [_textView presentScene:newScene];
//    
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

- (void) setupTextLayer
{
    if (self.pathLayer != nil) {
        [self.pathLayer removeFromSuperlayer];
        self.pathLayer = nil;
    }
    
    // Create path from text
    // See: http://www.codeproject.com/KB/iPhone/Glyph.aspx
    // License: The Code Project Open License (CPOL) 1.02 http://www.codeproject.com/info/cpol10.aspx
    CGMutablePathRef letters = CGPathCreateMutable();
    
    CTFontRef font = CTFontCreateWithName(CFSTR("TimesNewRoman"), 120.0f, NULL);
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)font, kCTFontAttributeName,
                           nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"MACHWEO"
                                                                     attributes:attrs];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    // for each RUN
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
    {
        // Get FONT for this run
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // for each GLYPH in run
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
        {
            // get Glyph & Glyph-data
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            // Get PATH of outline
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    CFRelease(line);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
    
    CGPathRelease(letters);
    CFRelease(font);
    
    _pathLayer = [CAShapeLayer layer];
    _pathLayer.frame = self.animationLayer.bounds;
    _pathLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    //pathLayer.backgroundColor = [[UIColor yellowColor] CGColor];
    _pathLayer.geometryFlipped = YES;
    _pathLayer.path = path.CGPath;
    _pathLayer.strokeColor = [[UIColor whiteColor] CGColor];
    _pathLayer.fillColor = nil;
    _pathLayer.lineWidth = 5.0f;
    //pathLayer.lineJoin = kCALineJoinBevel;
    //.lineCap = kCALineCapSquare;
    
    [self.animationLayer addSublayer:_pathLayer];
    
    _pathSubLayer = [CAShapeLayer layer];
    _pathSubLayer.frame = self.animationLayer.bounds;
    _pathSubLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    //pathLayer.backgroundColor = [[UIColor yellowColor] CGColor];
    _pathSubLayer.geometryFlipped = YES;
    _pathSubLayer.path = path.CGPath;
   // pathSubLayer.strokeColor = [[UIColor whiteColor] CGColor];
    //pathSubLayer.fillColor = [[UIColor redColor] CGColor];
    //pathSubLayer.fillColor = nil;
    //pathSubLayer.lineWidth = 5.0f;
    [self.animationLayer addSublayer:_pathSubLayer];
    
    CALayer* subTextureLayer = [CAShapeLayer layer];
    subTextureLayer.frame = self.animationLayer.frame;
   // subTextureLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    subTextureLayer.contents = (id)[UIImage imageNamed:@"african_textile_2_terrain"].CGImage;
    subTextureLayer.mask = _pathSubLayer;
    [self.animationLayer addSublayer:subTextureLayer];
    
    CALayer* textureLayer = [CAShapeLayer layer];
    textureLayer.frame = self.animationLayer.frame;
    textureLayer.contents = (id)[UIImage imageNamed:@"african_textile_5_terrain"].CGImage;
    textureLayer.mask = self.pathLayer;
    [self.animationLayer addSublayer:textureLayer];
    
    
    
    
    
    
    
}



- (void) startAnimation
{
    [self.pathLayer removeAllAnimations];
    
    //CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];

    pathAnimation.duration = 4.0f;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [self.pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];

    fillAnimation.duration = 4.0f;
    fillAnimation.fromValue = (id)[[UIColor clearColor] CGColor];
    fillAnimation.toValue = (id)[[UIColor blackColor] CGColor];
    [self.pathSubLayer addAnimation:fillAnimation forKey:@"fillColor"];
    
    
}

//
//- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
//    self.pathLayer.fillColor = [UIColor blackColor].CGColor;
//}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.animationLayer = [CALayer layer];
//    self.animationLayer.frame = CGRectMake(20.0f, 64.0f,
//                                           CGRectGetWidth(self.view.layer.bounds) - 40.0f,
//                                           CGRectGetHeight(self.view.layer.bounds) - 84.0f);
    self.animationLayer.frame = self.view.frame;
    //self.animationLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.view.layer addSublayer:self.animationLayer];
    [self setupButtons];
    
//    [self setupTextLayer];
//    [CATransaction begin]; {
//        [CATransaction setCompletionBlock:^{
//           // self.pathLayer.fillColor = [UIColor blackColor].CGColor;
//        }];
//        [self startAnimation];
//    } [CATransaction commit];
}

-(void)setupButtons{
    [_chaptersButton setImage:[UIImage imageNamed:@"chapters_button_clicked"] forState:UIControlStateHighlighted];
    [_highScoresButton setImage:[UIImage imageNamed:@"highscores_button_clicked"] forState:UIControlStateHighlighted];
    [_leaderboardButton setImage:[UIImage imageNamed:@"leaderboard_button_clicked"] forState:UIControlStateHighlighted];
    [_settingsButton setImage:[UIImage imageNamed:@"settings_button_clicked"] forState:UIControlStateHighlighted];
    [_unlockablesButton setImage:[UIImage imageNamed:@"unlockables_button_clicked"] forState:UIControlStateHighlighted];

}


- (void)dealloc
{
    self.animationLayer = nil;
    self.pathLayer = nil;
    //self.penLayer = nil;
    //[super dealloc];
}


//// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
//}
//
//
//- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    self.animationLayer.frame = CGRectMake(20.0f, 64.0f,
//                                           CGRectGetWidth(self.view.layer.bounds) - 40.0f,
//                                           CGRectGetHeight(self.view.layer.bounds) - 84.0f);
//    self.pathLayer.frame = self.animationLayer.bounds;
//    self.penLayer.frame = self.penLayer.bounds;
//}
//
//
//- (void)viewDidUnload
//{
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//}
//
//
//- (IBAction) replayButtonTapped:(id)sender
//{
//    [self startAnimation];
//}
//
//
//- (IBAction) drawingTypeSelectorTapped:(id)sender
//{
//    UISegmentedControl *drawingTypeSelector = (UISegmentedControl *)sender;
//    switch (drawingTypeSelector.selectedSegmentIndex) {
//        case 0:
//            [self setupDrawingLayer];
//            [self startAnimation];
//            break;
//        case 1:
//            [self setupTextLayer];
//            [self startAnimation];
//            break;
//    }
//}

@end