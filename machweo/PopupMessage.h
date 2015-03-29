//
//  PopupMessage.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 3/28/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PopupMessage : NSObject
@property(nonatomic, strong) NSString* text;
@property(nonatomic) CGPoint position;

-(instancetype)initWithText:(NSString*)text andPosition:(CGPoint)position;

@end
