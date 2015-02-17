//
//  MainMenuControllerViewController.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/12/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "MainMenuControllerViewController.h"
#import "MainMenuScene.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "GameScene.h"

@interface MainMenuControllerViewController ()

@end

@implementation MainMenuControllerViewController{
    BOOL gameLoaded;
    BOOL observersLoaded;
}

- (void) setupLogo
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
    
    _logoAnimationLayer = [CALayer layer];
    _logoAnimationLayer.frame = _logoView.bounds;
    [_logoView.layer addSublayer:_logoAnimationLayer];

    _pathLayer = [CAShapeLayer layer];
    _pathLayer.frame = _logoAnimationLayer.bounds;
    _pathLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    //pathLayer.backgroundColor = [[UIColor yellowColor] CGColor];
    _pathLayer.geometryFlipped = YES;
    _pathLayer.path = path.CGPath;
    _pathLayer.strokeColor = [[UIColor whiteColor] CGColor];
    _pathLayer.fillColor = nil;
    _pathLayer.lineWidth = 5.0f;
   // _pathLayer.zPosition = 1;
    
    [_logoAnimationLayer addSublayer:_pathLayer];
    
    _pathSubLayer = [CAShapeLayer layer];
    _pathSubLayer.frame = _logoAnimationLayer.bounds;
    _pathSubLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    //pathLayer.backgroundColor = [[UIColor yellowColor] CGColor];
    _pathSubLayer.geometryFlipped = YES;
    _pathSubLayer.path = path.CGPath;
   // pathSubLayer.strokeColor = [[UIColor whiteColor] CGColor];
    //pathSubLayer.fillColor = [[UIColor redColor] CGColor];
    //pathSubLayer.fillColor = nil;
    //pathSubLayer.lineWidth = 5.0f;
    //_pathSubLayer.zPosition = 1;

    [_logoAnimationLayer addSublayer:_pathSubLayer];
    
    CALayer* subTextureLayer = [CAShapeLayer layer];
    subTextureLayer.frame = _logoAnimationLayer.frame;
   // subTextureLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    subTextureLayer.contents = (id)[UIImage imageNamed:@"african_textile_2_terrain"].CGImage;
    subTextureLayer.mask = _pathSubLayer;
    [_logoAnimationLayer addSublayer:subTextureLayer];
   // subTextureLayer.zPosition = 1;

    
    CALayer* textureLayer = [CAShapeLayer layer];
    textureLayer.frame = _logoAnimationLayer.frame;
    textureLayer.contents = (id)[UIImage imageNamed:@"african_textile_5_terrain"].CGImage;
    textureLayer.mask = self.pathLayer;
    [_logoAnimationLayer addSublayer:textureLayer];
    //textureLayer.zPosition = 1;

   
}

- (void) lightUp{
    _logoView.layer.backgroundColor = [[UIColor clearColor] CGColor];
    CABasicAnimation *lightUp = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    lightUp.fromValue = (id)[[UIColor blackColor] CGColor];
    lightUp.toValue = (id)[[UIColor clearColor] CGColor];
    lightUp.duration = 4.0f;
    [_logoView.layer addAnimation:lightUp forKey:@"backgroundColor"];

}

-(void)drawPath{
    [self.pathLayer removeAllAnimations];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 3.0f;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [self.pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    fillAnimation.duration = 3.0f;
    fillAnimation.fromValue = (id)[[UIColor clearColor] CGColor];
    fillAnimation.toValue = (id)[[UIColor blackColor] CGColor];
    [self.pathSubLayer addAnimation:fillAnimation forKey:@"fillColor"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _logoView.frame = self.view.bounds;
    _logoView.userInteractionEnabled = false;
//    _logoAnimationLayer = [CALayer layer];
//    _logoAnimationLayer.frame = _logoView.bounds;
//    [_logoView.layer addSublayer:_logoAnimationLayer];
    
    _gameSceneView.frame = self.view.bounds;
    [self.view sendSubviewToBack:_gameSceneView];
    //[self.view bringSubviewToFront:_gameSceneView];
    
    //[self setupLogo];
    [self lightUp];
    //[self drawPath];

    [self setUpObservers];

}

-(void)setUpObservers{
    //__weak MainMenuControllerViewController *weakSelf = self;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserverForName:@"dismiss logo"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         //dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(void){
             //_logoView.layer.opacity = 0;
            _logoAnimationLayer.opacity = 0;
//             CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//             opacityAnimation.duration = 1.0f;
//             opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
//             opacityAnimation.toValue = [NSNumber numberWithFloat:0.0f];
//             [_logoAnimationLayer addAnimation:opacityAnimation forKey:@"opacity"];
        // });
        
     }];
    
    [center addObserverForName:@"restart game"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         
         [CATransaction begin]; {
         [CATransaction setCompletionBlock:^{
             [_gameSceneView presentScene:nil];
             
             [self lightUp];
             //[self setupLogo];
             //[self drawPath];
             [self initGame];

         }];

             _logoView.layer.opacity = 1;
             _logoView.layer.backgroundColor = [[UIColor blackColor] CGColor];
             CABasicAnimation *darken = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
             darken.fromValue = (id)[[UIColor clearColor] CGColor];
             darken.toValue = (id)[[UIColor blackColor] CGColor];
             darken.duration = 3.0f;
             [_logoView.layer addAnimation:darken forKey:@"backgroundColor"];
             
             
         } [CATransaction commit];
     }];


    
}
//- (void)dealloc
//{
//    self.animationLayer = nil;
//    self.pathLayer = nil;
//    //self.penLayer = nil;
//    //[super dealloc];
//}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    if (!gameLoaded) {
        gameLoaded = true;
        [self initGame];
    }
    //[self.view sendSubviewToBack:_gameSceneView];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

-(void)initGame{
    //SKView * skView = (SKView *)self.view;
    _gameSceneView.ignoresSiblingOrder = YES;
    //_gameSceneView.showsDrawCount = YES;
    _gameSceneView.showsFPS = YES;


   // __weak GameViewController *weakSelf = self;
   // dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    GameScene *newScene = [[GameScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height) forLevel:@"newnewLevel" withinView:_gameSceneView];
    [_gameSceneView presentScene: newScene];
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
