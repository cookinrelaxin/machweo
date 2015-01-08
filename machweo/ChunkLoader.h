//
//  ChunkLoader.h
//  tgrrn
//
//  Created by John Feldcamp on 12/26/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface ChunkLoader : NSObject <NSXMLParserDelegate>

-(void)loadWorld:(SKNode*)world withBackgrounds:(SKNode*)backgrounds withObstacles:(SKNode*)obstacles andDecorations:(SKNode*)decorations withScaleCoefficient:(CGVector)scaleCoefficient;
-(instancetype)initWithFile:(NSString*)fileName;
@end
