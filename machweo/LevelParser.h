//
//  CellParser.h
//  tgrrn
//
//  Created by John Feldcamp on 1/5/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LevelParser : NSObject <NSXMLParserDelegate>
//@property (nonatomic, strong) NSMutableArray* levels;
@property (nonatomic, strong) NSMutableDictionary* obstacleSets;
@property (nonatomic, strong) NSMutableDictionary* biomes;
-(instancetype)init;
@end
