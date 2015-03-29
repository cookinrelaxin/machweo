//
//  PopupMessage.m
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 3/28/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "PopupMessage.h"

@implementation PopupMessage
-(instancetype)initWithText:(NSString *)text andPosition:(CGPoint)position{
    if (self = [super init]) {
        _text = text;
        _position = position;
    }
    return self;
}


@end
