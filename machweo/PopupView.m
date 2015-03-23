//
//  PopupView.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/21/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "PopupView.h"
#import "Constants.h"
float HEIGHTOFPOPUPTRIANGLE_DEFAULT = 10;
float WIDTHOFPOPUPTRIANGLE_DEFAULT = 20;
float borderRadius_DEFAULT = 8;
float strokeWidth_DEFAULT = 3;



@implementation PopupView{
    UIColor *fillColor;
    float height_of_popup_triangle;
    float width_of_popup_triangle;
}

-(instancetype)initWithFrame:(CGRect)frame andIsMenu:(BOOL)isMenu{
    if (self = [super initWithFrame:frame]){
        Constants* constants = [Constants sharedInstance];
        
        self.desiredFrameSize = frame.size;
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 10);
        
        //self.alpha = 0.75;
        self.backgroundColor = [UIColor clearColor];
        
        //UILabel *yourLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + borderRadius_DEFAULT + strokeWidth_DEFAULT, self.bounds.origin.y + borderRadius_DEFAULT + strokeWidth_DEFAULT, self.desiredFrameSize.width - borderRadius_DEFAULT - strokeWidth_DEFAULT - (borderRadius_DEFAULT * 2), self.desiredFrameSize.height - (borderRadius_DEFAULT * 2))];

        [_textLabel setTextColor:[UIColor blackColor]];
        [_textLabel setBackgroundColor:[UIColor clearColor]];
        UIFont* font = [UIFont fontWithName:constants.POPUP_FONT_NAME size: 30.0f];
        [_textLabel setFont:font];
        
        _textLabel.text = @"Hello!";
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.textAlignment = NSTextAlignmentCenter;

        _textLabel.hidden = true;
        [self addSubview:_textLabel];
        
        if (isMenu) {
            //fillColor = [UIColor blueColor];
            fillColor = constants.LOGO_LABEL_FONT_COLOR;
            
            height_of_popup_triangle = 0;
            width_of_popup_triangle = 0;
        }
        else{
            //fillColor = [UIColor colorWithRed:243.0f/255.0f green:126.0f/255.0f blue:61.0f/255.0f alpha:.80];
            fillColor = constants.LOGO_LABEL_FONT_COLOR;
            
            height_of_popup_triangle = HEIGHTOFPOPUPTRIANGLE_DEFAULT;
            width_of_popup_triangle = WIDTHOFPOPUPTRIANGLE_DEFAULT;
        }
        

        //NSLog(@"Frame: %@", NSStringFromCGRect(frame));
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //NSLog(@"draw rect");
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextTranslateCTM(context, 0.0f, self.bounds.size.height);
    //CGContextScaleCTM(context, 1.0f, -1.0f);
    
    CGRect currentFrame = self.bounds;
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, strokeWidth_DEFAULT);
    UIColor* strokeColor = [UIColor darkGrayColor];

    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    
    // Draw and fill the bubble
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, borderRadius_DEFAULT + strokeWidth_DEFAULT + 0.5f, strokeWidth_DEFAULT + height_of_popup_triangle + 0.5f);
    CGContextAddLineToPoint(context, round(currentFrame.size.width / 2.0f - width_of_popup_triangle / 2.0f) + 0.5f, height_of_popup_triangle + strokeWidth_DEFAULT + 0.5f);
    CGContextAddLineToPoint(context, round(currentFrame.size.width / 2.0f) + 0.5f, strokeWidth_DEFAULT + 0.5f);
    CGContextAddLineToPoint(context, round(currentFrame.size.width / 2.0f + width_of_popup_triangle / 2.0f) + 0.5f, height_of_popup_triangle + strokeWidth_DEFAULT + 0.5f);
    CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth_DEFAULT - 0.5f, strokeWidth_DEFAULT + height_of_popup_triangle + 0.5f, currentFrame.size.width - strokeWidth_DEFAULT - 0.5f, currentFrame.size.height - strokeWidth_DEFAULT - 0.5f, borderRadius_DEFAULT - strokeWidth_DEFAULT);
    CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth_DEFAULT - 0.5f, currentFrame.size.height - strokeWidth_DEFAULT - 0.5f, round(currentFrame.size.width / 2.0f + width_of_popup_triangle / 2.0f) - strokeWidth_DEFAULT + 0.5f, currentFrame.size.height - strokeWidth_DEFAULT - 0.5f, borderRadius_DEFAULT - strokeWidth_DEFAULT);
    CGContextAddArcToPoint(context, strokeWidth_DEFAULT + 0.5f, currentFrame.size.height - strokeWidth_DEFAULT - 0.5f, strokeWidth_DEFAULT + 0.5f, height_of_popup_triangle + strokeWidth_DEFAULT + 0.5f, borderRadius_DEFAULT - strokeWidth_DEFAULT);
    CGContextAddArcToPoint(context, strokeWidth_DEFAULT + 0.5f, strokeWidth_DEFAULT + height_of_popup_triangle + 0.5f, currentFrame.size.width - strokeWidth_DEFAULT - 0.5f, height_of_popup_triangle + strokeWidth_DEFAULT + 0.5f, borderRadius_DEFAULT - strokeWidth_DEFAULT);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    // Draw a clipping path for the fill
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, borderRadius_DEFAULT + strokeWidth_DEFAULT + 0.5f, round((currentFrame.size.height + height_of_popup_triangle) * 0.50f) + 0.5f);
    CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth_DEFAULT - 0.5f, round((currentFrame.size.height + height_of_popup_triangle) * 0.50f) + 0.5f, currentFrame.size.width - strokeWidth_DEFAULT - 0.5f, currentFrame.size.height - strokeWidth_DEFAULT - 0.5f, borderRadius_DEFAULT - strokeWidth_DEFAULT);
    CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth_DEFAULT - 0.5f, currentFrame.size.height - strokeWidth_DEFAULT - 0.5f, round(currentFrame.size.width / 2.0f + width_of_popup_triangle / 2.0f) - strokeWidth_DEFAULT + 0.5f, currentFrame.size.height - strokeWidth_DEFAULT - 0.5f, borderRadius_DEFAULT - strokeWidth_DEFAULT);
    CGContextAddArcToPoint(context, strokeWidth_DEFAULT + 0.5f, currentFrame.size.height - strokeWidth_DEFAULT - 0.5f, strokeWidth_DEFAULT + 0.5f, height_of_popup_triangle + strokeWidth_DEFAULT + 0.5f, borderRadius_DEFAULT - strokeWidth_DEFAULT);
    CGContextAddArcToPoint(context, strokeWidth_DEFAULT + 0.5f, round((currentFrame.size.height + height_of_popup_triangle) * 0.50f) + 0.5f, currentFrame.size.width - strokeWidth_DEFAULT - 0.5f, round((currentFrame.size.height + height_of_popup_triangle) * 0.50f) + 0.5f, borderRadius_DEFAULT - strokeWidth_DEFAULT);
    CGContextClosePath(context);
    CGContextClip(context);

}

@end
