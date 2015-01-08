//
//  ChapterCell.h
//  tgrrn
//
//  Created by John Feldcamp on 1/6/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>

@interface ChapterCell : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* imageName;
@property (nonatomic, strong) NSMutableArray* levelCells;

@end
