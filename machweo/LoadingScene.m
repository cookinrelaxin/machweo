//
//  LoadingScene.m
//  tgrrn
//
//  Created by John Feldcamp on 1/4/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "LoadingScene.h"
#import "Player.h"
#import "AnimationComponent.h"
#import <CoreText/CoreText.h>

@implementation LoadingScene{
    CAShapeLayer *_pathLayer;
    CAShapeLayer *_pathSubLayer;
    CALayer *_logoAnimationLayer;
    Constants* constants;
    Player* player;
    
    SKSpriteNode* logo;
}

-(instancetype)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]){
        constants = [Constants sharedInstance];
//        player = [Player player];
//        [self addChild:player];
//        player.position = CGPointMake(0, (player.size.height / 2) - (player.size.height / 6));
//        [player runAction:[SKAction repeatActionForever:
//                           [SKAction animateWithTextures:[AnimationComponent sharedInstance].runningFrames
//                                            timePerFrame:0.04f
//                                                  resize:NO
//                                                 restore:YES]] withKey:@"runningMaasai"];
        self.backgroundColor = constants.LOADING_SCREEN_BACKGROUND_COLOR;
        logo = [SKSpriteNode spriteNodeWithImageNamed:@"logo"];
        logo.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        logo.size = CGSizeMake(logo.size.width * constants.SCALE_COEFFICIENT.dx, logo.size.height * constants.SCALE_COEFFICIENT.dx);
        [self addChild:logo];
    }
    return self;
}
-(void)update:(NSTimeInterval)currentTime{
//    player.position = CGPointMake(player.position.x + 3, player.position.y);
//    if ((player.position.x + (player.size.width / 2)) > self.size.width) {
//        player.position = CGPointMake(-player.size.width / 2, player.position.y);
//    }
}

-(void)didMoveToView:(SKView *)view{
    //self.view.layer.zPosition = 10;
    //player.zPosition = 100;

    //[self setupLogo];
    //[self drawPath];
   // NSLog(@"self.view.layer.zPosition: %f", self.view.layer.zPosition);
   // NSLog(@"_logoAnimationLayer.zPosition: %f", _logoAnimationLayer.zPosition);

    
    

}

- (void) setupLogo
{
    if (_pathLayer != nil) {
        [_pathLayer removeFromSuperlayer];
        _pathLayer = nil;
    }
    
    // Create path from text
    // See: http://www.codeproject.com/KB/iPhone/Glyph.aspx
    // License: The Code Project Open License (CPOL) 1.02 http://www.codeproject.com/info/cpol10.aspx
    CGMutablePathRef letters = CGPathCreateMutable();
    CFStringRef logoName = (__bridge CFStringRef)constants.LOGO_LABEL_FONT_NAME;
    CTFontRef font = CTFontCreateWithName(logoName, 120.0 * constants.SCALE_COEFFICIENT.dx, NULL);
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)font, kCTFontAttributeName,
                           nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"GET PSYCHED GAMES"
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
    _logoAnimationLayer.frame = self.frame;
    //_logoAnimationLayer.backgroundColor = [constants.LOGO_LABEL_FONT_COLOR CGColor];
    //_logoAnimationLayer.zPosition = 0;
    //NSLog(@"_logoAnimationLayer:%@", _logoAnimationLayer);

    [self.view.layer addSublayer:_logoAnimationLayer];
    
    _pathLayer = [CAShapeLayer layer];
    _pathLayer.frame = _logoAnimationLayer.bounds;
    _pathLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    //_pathLayer.backgroundColor = [[UIColor yellowColor] CGColor];
    _pathLayer.geometryFlipped = YES;
    _pathLayer.path = path.CGPath;
    _pathLayer.strokeColor = [[UIColor whiteColor] CGColor];
    _pathLayer.fillColor = nil;
    _pathLayer.lineWidth = 5.0f;
    //NSLog(@"_pathLayer:%@", _pathLayer);
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
    subTextureLayer.frame = _logoAnimationLayer.bounds;
    // subTextureLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    subTextureLayer.contents = (id)[UIImage imageNamed:@"tenggriPS_01"].CGImage;
    subTextureLayer.mask = _pathSubLayer;
    [_logoAnimationLayer addSublayer:subTextureLayer];
    // subTextureLayer.zPosition = 1;
    
    
    CALayer* textureLayer = [CAShapeLayer layer];
    textureLayer.frame = _logoAnimationLayer.bounds;
    textureLayer.contents = (id)[UIImage imageNamed:@"tenggriPS_07"].CGImage;
    textureLayer.mask = _pathLayer;
    [_logoAnimationLayer addSublayer:textureLayer];
    //textureLayer.zPosition = 1;
}

-(void)drawPath{
    [_pathLayer removeAllAnimations];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 5.0f;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [_pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    fillAnimation.duration = 5.0f;
    fillAnimation.fromValue = (id)[[UIColor clearColor] CGColor];
    fillAnimation.toValue = (id)[[UIColor blackColor] CGColor];
    [_pathSubLayer addAnimation:fillAnimation forKey:@"fillColor"];
}

-(void)fadeOut{
    [_logoAnimationLayer removeFromSuperlayer];
//    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0];
//    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0];
//    fadeAnimation.additive = NO;
//    fadeAnimation.removedOnCompletion = true;
//    fadeAnimation.duration = .5;
//    fadeAnimation.fillMode = kCAFillModeBoth;
//    [_logoAnimationLayer addAnimation:fadeAnimation forKey:@"fade"];
}

@end
