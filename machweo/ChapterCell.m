//
//  ChapterCell.m
//  tgrrn
//
//  Created by John Feldcamp on 1/6/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "ChapterCell.h"

@implementation ChapterCell
-(instancetype)init{
    if (self = [super init]) {
        _levelCells = [NSMutableArray array];
    }
    return self;
}

@end
