//
//  LevelCellParser.h
//  tgrrn
//
//  Created by John Feldcamp on 1/6/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LevelCellParser : NSObject <NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableDictionary* levels;

+ (instancetype)sharedInstance;
@end
