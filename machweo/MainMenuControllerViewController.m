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
#import "GameScene.h"

@interface MainMenuControllerViewController ()

@end

@implementation MainMenuControllerViewController{
    UILabel *scoreLabel;
    UILabel *velocityLabel;
    BOOL gameLoaded;
    BOOL observersLoaded;
}

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
    
    _sunLayer = [CALayer layer];
    UIImage* sun = [UIImage imageNamed:@"sun_decoration"];
    //_sunLayer.frame = self.animationLayer.bounds;
    _sunLayer.frame = CGRectMake(CGRectGetMidX(self.animationLayer.bounds) - 200, CGRectGetMinY(self.animationLayer.bounds), 200, 200);
    _sunLayer.contents = (__bridge id)(sun.CGImage);
    //textureLayer.position = self.animationLayer.frame.size.width / 2;
    //_sunLayer.position = CGPointMake(self.animationLayer.frame.size.width / 2, -sun.size.height / 2);
    _sunLayer.zPosition = 3;
    [self.animationLayer addSublayer:_sunLayer];
    [self sendSublayerToBack:_sunLayer];
    
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

- (void) bringSublayerToFront:(CALayer *)layer
{
    [layer removeFromSuperlayer];
    [self.animationLayer insertSublayer:layer atIndex:(unsigned int)[self.animationLayer.sublayers count]];
}

- (void) sendSublayerToBack:(CALayer *)layer
{
    [layer removeFromSuperlayer];
    [self.animationLayer insertSublayer:layer atIndex:0];
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
    
    CABasicAnimation *sunriseAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    sunriseAnimation.fromValue = @(CGRectGetMaxY(self.animationLayer.bounds) + (_sunLayer.frame.size.height / 2));
   // sunAnimation.toValue  = @(CGRectGetMinY(self.animationLayer.bounds));
    sunriseAnimation.toValue  = @(_sunLayer.frame.origin.y + (_sunLayer.frame.size.height / 2));
    sunriseAnimation.duration   = 7.0f;
    sunriseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [_sunLayer addAnimation:sunriseAnimation forKey:@"position.y"];
    
    CABasicAnimation *lightUp = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    lightUp.fromValue = (id)[[UIColor blackColor] CGColor];
    lightUp.toValue = (id)[[UIColor clearColor] CGColor];
    lightUp.duration = 7.0f;
    [self.animationLayer addAnimation:lightUp forKey:@"backgroundColor"];

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
    [self setupTextLayer];
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            //_pathLayer.hidden = true;
//            _pathLayer.opacity = 0;
//            _pathSubLayer.opacity = 0;
//            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//            pathAnimation.duration = 1.0f;
//            pathAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
//            pathAnimation.toValue = [NSNumber numberWithFloat:0.0f];
//            [_pathLayer addAnimation:pathAnimation forKey:@"opacity"];
//            [_pathSubLayer addAnimation:pathAnimation forKey:@"opacity"];

            
        }];
        [self startAnimation];
    } [CATransaction commit];
}

- (void)dealloc
{
    self.animationLayer = nil;
    self.pathLayer = nil;
    //self.penLayer = nil;
    //[super dealloc];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    if (!gameLoaded) {
        gameLoaded = true;
        [self initGame];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

-(void)initGame{
    SKView * skView = (SKView *)self.view;
    skView.ignoresSiblingOrder = YES;


   // __weak GameViewController *weakSelf = self;
   // dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        GameScene *newScene = [[GameScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height) forLevel:@"newnewLevel" withinView:skView];
    [skView presentScene: newScene];
       // newScene.backgroundColor = [UIColor lightGrayColor];
       // newScene.scaleMode = SKSceneScaleModeResizeFill;
       // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
         //   //[weakSelf initializeLabels];
         //   if (!observersLoaded) {
            //    [weakSelf setUpObservers];
            //    observersLoaded = true;
           // }
            //[weakSelf refreshView];
            //[((SKView*)weakSelf.view) presentScene:newScene];
       // });
        
  //  });
    
    //  skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    
    //[self refreshView];
    
    //LoadingScene* loadingScene = [[LoadingScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
   // loadingScene.backgroundColor = [UIColor redColor];
    //loadingScene.scaleMode = SKSceneScaleModeResizeFill;
    //[skView presentScene:loadingScene];
    
}


@end
