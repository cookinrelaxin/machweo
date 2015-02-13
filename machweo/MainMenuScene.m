//
//  MainMenuScene.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/12/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "MainMenuScene.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@implementation MainMenuScene

////-(instancetype)initWithSize:(CGSize)size{
////    if (self = [super initWithSize:size]) {
////        UIBezierPath *circle = [UIBezierPath
////                                bezierPathWithOvalInRect:CGRectMake(0, 0, 200, 200)];
////        
////        UIGraphicsBeginImageContext(CGSizeMake(200, 200));
////        
////        //this gets the graphic context
////        CGContextRef context = UIGraphicsGetCurrentContext();
////        
////        //you can stroke and/or fill
////        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
////        CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
////        [circle fill];
////        [circle stroke];
////        
////        //now get the image from the context
////        UIImage *bezierImage = UIGraphicsGetImageFromCurrentImageContext();
////        SKSpriteNode* text = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:bezierImage]];
////        [self addChild:text];
////        text.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
////    }
////    return self;
////}
//
////-(instancetype)initWithSize:(CGSize)size{
////    if (self = [super initWithSize:size]) {
////        //UIBezierPath *glyphPath = [UIBezierPath bezierPath];
////        
////        UIGraphicsBeginImageContext(self.frame.size);
////        NSString *floralHeart = @"\u2766";
////        
////        NSRange stringRange = NSMakeRange(0, [floralHeart length]);
//////        NSFont *arialUnicode =
//////        [[UIFontManager sharedFontManager]
//////         fontWithFamily:@"Arial Unicode MS"
//////         traits:0
//////         weight:5
//////         size:345];
////        UIFont *arialUnicode = [UIFont fontWithName:@"Arial Unicode MS" size:345];
////        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
////        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:floralHeart];
////        [textStorage addAttribute:NSFontAttributeName value:arialUnicode range:stringRange];
////        [textStorage fixAttributesInRange:stringRange];
////        [textStorage addLayoutManager:layoutManager];
////        NSInteger numGlyphs = [layoutManager numberOfGlyphs];
////        CGGlyph *glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * (numGlyphs + 1)); // includes space for NULL terminator
////        //[layoutManager getGlyphs:glyphs range:NSMakeRange(0, numGlyphs)];
////        [layoutManager getGlyphsInRange:NSMakeRange(0, numGlyphs) glyphs:glyphs properties:NULL characterIndexes:NULL bidiLevels:NULL];
////        [textStorage removeLayoutManager:layoutManager];
////        
////        //UIBezierPath *floralHeartPath = [[UIBezierPath alloc] init];
////        //[floralHeartPath moveToPoint:CGPointMake(130, 140)];
////        CGAffineTransform transform = CGAffineTransformIdentity;
////        CGPathRef path = CTFontCreatePathForGlyph(arialUnicode, glyphs, &transform);
////
////        //[floralHeartPath appendBezierPathWithGlyphs:glyphs count:numGlyphs inFont:arialUnicode];
////        free(glyphs);
////        
////        UIImage *bezierImage = UIGraphicsGetImageFromCurrentImageContext();
////        SKSpriteNode* text = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:bezierImage]];
////        [self addChild:text];
////        text.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
////    }
////    return self;
////}
//
//-(instancetype)initWithSize:(CGSize)size{
//    if (self = [super initWithSize:size]) {
//        UIGraphicsBeginImageContext(self.frame.size);
//        
//        CGMutablePathRef letters = CGPathCreateMutable();
//        
//        CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 72.0f, NULL);
//        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
//                               (__bridge id)(font), kCTFontAttributeName,
//                               nil];
//        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"Hello World!"
//                                                                         attributes:attrs];
//        CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
//        CFArrayRef runArray = CTLineGetGlyphRuns(line);
//        
//        // for each RUN
//        for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
//        {
//            // Get FONT for this run
//            CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
//            CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
//            
//            // for each GLYPH in run
//            for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
//            {
//                // get Glyph & Glyph-data
//                CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
//                CGGlyph glyph;
//                CGPoint position;
//                CTRunGetGlyphs(run, thisGlyphRange, &glyph);
//                CTRunGetPositions(run, thisGlyphRange, &position);
//                
//                // Get PATH of outline
//                {
//                    CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
//                    CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
//                    CGPathAddPath(letters, &t, letter);
//                    CGPathRelease(letter);
//                }
//            }
//        }
//        CFRelease(line);
//        
//       // UIBezierPath *path = [UIBezierPath bezierPath];
//       // [path moveToPoint:CGPointZero];
//        //[path appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
//        
//        
//        
//        SKShapeNode* testTextShape = [SKShapeNode shapeNodeWithPath:letters];
//        testTextShape.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
//        [self addChild:testTextShape];
//        SKAction *followPath = [SKAction followPath:testTextShape.path asOffset:YES orientToPath:NO duration:1.0];
//        SKSpriteNode* test = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(5, 5)];
//        test.position = testTextShape.position;
//        [self addChild:test];
//        [test runAction:followPath];
//        
//       // UIImage *bezierImage = UIGraphicsGetImageFromCurrentImageContext();
//        //SKSpriteNode* text = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:bezierImage]];
//        //[self addChild:text];
//        //text.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
//        
//        CGPathRelease(letters);
//        CFRelease(font);
//    }
//    return self;
//}
//
//-(void)update:(NSTimeInterval)currentTime{
//    
//}

//@synthesize animationLayer = _animationLayer;
//@synthesize pathLayer = _pathLayer;
//@synthesize penLayer = _penLayer;









@end
