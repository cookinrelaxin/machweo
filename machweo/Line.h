//
//  Line.h
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 12/1/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Line : NSObject
@property (nonatomic) BOOL complete;
@property (nonatomic) BOOL belowPlayer;
@property (nonatomic) BOOL shouldDeallocNodeArray;
@property (nonatomic) NSMutableArray *nodeArray;


@end
