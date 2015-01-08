//
//  CellParser.h
//  tgrrn
//
//  Created by John Feldcamp on 1/5/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChapterCellParser : NSObject <NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableArray* chapters;
+ (instancetype)sharedInstance;
@end
