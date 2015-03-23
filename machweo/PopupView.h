//
//  PopupView.h
//  machweo
//
//  Created by Feldcamp, Zachary Satoshi on 2/21/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupView : UIView
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic) CGSize desiredFrameSize;

-(instancetype)initWithFrame:(CGRect)frame andIsMenu:(BOOL)isMenu;

@end
