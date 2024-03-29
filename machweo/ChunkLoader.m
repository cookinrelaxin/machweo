//
//  ChunkLoader.m
//  tgrrn
//
//  Created by John Feldcamp on 12/26/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "ChunkLoader.h"
#import "Obstacle.h"

typedef enum ElementVarieties
{
    spriteNode,
    type,
    name,
    xPosition,
    yPosition,
    zPosition
} Element;

typedef enum NodeTypes
{
    obstacle,
    decoration
} Node;

@implementation ChunkLoader{
    // as simple as possible for now. assume all nodes are obstacles
    NSMutableArray* obstacleArray;
    NSMutableArray* decorationArray;

    SKSpriteNode *currentNode;
    Element currentElement;
    Node currentNodeType;
    
    BOOL charactersFound;
    
}

-(instancetype)initWithFile:(NSString*)fileName{
    obstacleArray = [NSMutableArray array];
    decorationArray = [NSMutableArray array];

    NSXMLParser* chunkParser;
    
    BOOL success;
    //NSURL *xmlURL = [NSURL fileURLWithPath:fileName];
    NSURL *xmlURL = [[NSBundle mainBundle]
                    URLForResource: fileName withExtension:@"xml"];
   // NSLog(@"xmlURL: %@", xmlURL);
    chunkParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];

    if (chunkParser){
       // NSLog(@"parse chunk");
        [chunkParser setDelegate:self];
        [chunkParser setShouldResolveExternalEntities:YES];
        success = [chunkParser parse];
    }
    
    return self;
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"error:%@",parseError.localizedDescription);
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    // These objects are created here so that if a document is not found they will not be created
   // NSLog(@"did start document");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    charactersFound = false;
    if ([elementName isEqualToString:@"spriteNode"]) {
        currentElement = spriteNode;
        return;
    }
    if ([elementName isEqualToString:@"name"]) {
        currentElement = name;
        return;
    }
    if ([elementName isEqualToString:@"type"]) {
        currentElement = type;
        return;
    }
    if ([elementName isEqualToString:@"xPosition"]) {
        currentElement = xPosition;
        return;
    }
    if ([elementName isEqualToString:@"yPosition"]) {
        currentElement = yPosition;
        return;
    }
    if ([elementName isEqualToString:@"zPosition"]) {
        currentElement = zPosition;
        return;
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"spriteNode"]) {
        if (currentNode != nil) {
            switch (currentNodeType) {
                case obstacle:
                    [obstacleArray addObject:currentNode];
                    break;
                case decoration:
                    [decorationArray addObject:currentNode];
                    break;
            }
            return;
        }
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (!charactersFound) {
        charactersFound = true;
        if (currentElement == name) {
            UIImage *spriteTexture = [UIImage imageNamed:string];
            if (spriteTexture) {
                if (currentNodeType == obstacle) {
                    currentNode = [Obstacle obstacleWithTextureAndPhysicsBody:[SKTexture textureWithImage:spriteTexture]];
                }
                else{
                    currentNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:spriteTexture]];
                }
            }
            else{
                currentNode = nil;
            }
            //NSLog(@"name: %@", string);
            currentNode.name = string;
            return;
        }
        if (currentElement == xPosition) {
            //NSLog(@"xPosition: %@", string);
            currentNode.position = CGPointMake([string floatValue], currentNode.position.y);
            return;
        }
        if (currentElement == yPosition) {
            //NSLog(@"yPosition: %@", string);
            currentNode.position = CGPointMake(currentNode.position.x, [string floatValue]);
            return;
        }
        if (currentElement == zPosition) {
            //NSLog(@"zPosition: %@", string);
            float zFloat = [string floatValue];
            currentNode.zPosition = zFloat;
            return;
        }
        if (currentElement == type) {
            //NSLog(@"yPosition: %@", string);
            if ([string isEqualToString:@"ObstacleSignifier"]) {
                currentNodeType = obstacle;
                return;
            }
            if ([string isEqualToString:@"DecorationSignifier"]) {
                currentNodeType = decoration;
                return;
            }
        }
    }
}

-(void)loadWorld:(SKNode*)world withBackgrounds:(SKNode*)backgrounds withObstacles:(SKNode*)obstacles andDecorations:(SKNode*)decorations withScaleCoefficient:(CGVector)scaleCoefficient{
    for (Obstacle *obstacle in obstacleArray) {
        obstacle.size = CGSizeMake(obstacle.size.width * scaleCoefficient.dy, obstacle.size.height * scaleCoefficient.dy);
        obstacle.position = CGPointMake(obstacle.position.x * scaleCoefficient.dy, obstacle.position.y * scaleCoefficient.dy);
        obstacle.position = [obstacles convertPoint:obstacle.position fromNode:world];
        //im sorry for the magic number, but it should be the same as constants._PLAYER_AND_OBSTACLE_Z_POSITION;
        obstacle.zPosition = 10;
        
        obstacle.physicsBody = [SKPhysicsBody bodyWithTexture:obstacle.texture size:obstacle.size];
        obstacle.physicsBody.categoryBitMask = [Constants sharedInstance].OBSTACLE_HIT_CATEGORY;
        obstacle.physicsBody.contactTestBitMask = [Constants sharedInstance].PLAYER_HIT_CATEGORY;
        //obstacle.physicsBody.collisionBitMask = 3;
        
        // NSLog(@"obstacle.physicsBody.categoryBitMask: %d", obstacle.physicsBody.categoryBitMask);
        // NSLog(@"obstacle.physicsBody.contactTestBitMask: %d", obstacle.physicsBody.contactTestBitMask);
        
        obstacle.physicsBody.dynamic = false;
        [obstacles addChild:obstacle];
    }
    
    for (SKSpriteNode *deco in decorationArray) {
        deco.size = CGSizeMake(deco.size.width * scaleCoefficient.dy, deco.size.height * scaleCoefficient.dy);
        deco.position = CGPointMake(deco.position.x * scaleCoefficient.dy, deco.position.y * scaleCoefficient.dy);
        deco.position = [obstacles convertPoint:deco.position fromNode:world];
        [decorations addChild:deco];
    }
    
}

@end
