//
//  ChunkLoader.m
//  tgrrn
//
//  Created by John Feldcamp on 12/26/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "ChunkLoader.h"
#import "Obstacle.h"
#import "Decoration.h"
#import "Terrain.h"

typedef enum ElementVarieties
{
    node,
    type,
    name,
    xPosition,
    yPosition,
    zPosition,
    motionType,
    speedType,
    uniqueID
} Element;

typedef enum NodeTypes
{
    obstacle,
    decoration,
} Node;

@implementation ChunkLoader{
    // as simple as possible for now. assume all nodes are obstacles
    NSMutableArray* obstacleArray;
    NSMutableArray* decorationArray;
    SKNode *currentNode;
    Element currentElement;
    Node currentNodeType;
    BOOL charactersFound;
    Constants* constants;
    Biome currentBiome;
    NSMutableDictionary* textureDict;
}

-(instancetype)initWithFile:(NSString*)fileName{
    constants = [Constants sharedInstance];
    if ([fileName containsString:@"jungle"]) {
        currentBiome = jungle;
    }
    if ([fileName containsString:@"savanna"]) {
        currentBiome = savanna;
    }
    if ([fileName containsString:@"sahara"]) {
        currentBiome = sahara;
    }
    textureDict = constants.TEXTURE_DICT;
    obstacleArray = [NSMutableArray array];
    decorationArray = [NSMutableArray array];
    NSXMLParser* chunkParser;
    BOOL success;
    NSURL *xmlURL = [[NSBundle mainBundle]
                    URLForResource: fileName withExtension:@"xml"];
    chunkParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    if (chunkParser){
        [chunkParser setDelegate:self];
        [chunkParser setShouldResolveExternalEntities:YES];
        success = [chunkParser parse];
    }
    return self;
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"error:%@",parseError.localizedDescription);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    charactersFound = false;
    if ([elementName isEqualToString:@"node"]) {
        currentElement = node;
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
    if ([elementName isEqualToString:@"motionType"]) {
        currentElement = motionType;
        return;
    }
    if ([elementName isEqualToString:@"speedType"]) {
        currentElement = speedType;
        return;
    }
    if ([elementName isEqualToString:@"uniqueID"]) {
        currentElement = uniqueID;
        return;
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"node"]) {
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

            if (currentNodeType == obstacle) {
                NSMutableArray* obstacleTypeArray = [constants.OBSTACLE_POOL valueForKey:string];
                Obstacle* firstObstacle = obstacleTypeArray.firstObject;
                if (firstObstacle) {
                    currentNode = firstObstacle;
                    [obstacleTypeArray removeObject:obstacleTypeArray.firstObject];
                }
                else{
                    currentNode = nil;
                }
                return;
            }
            else if (currentNodeType == decoration){
                SKTexture *spriteTexture = [textureDict objectForKey:string];
                if (spriteTexture) {
                    currentNode = [Decoration spriteNodeWithTexture:spriteTexture];
                    currentNode.physicsBody = nil;
                }
                return;
            }
            else{
                currentNode = nil;
            }
            return;
        }
        if (currentElement == xPosition) {
            currentNode.position = CGPointMake([string floatValue], currentNode.position.y);
            return;
        }
        if (currentElement == yPosition) {
            currentNode.position = CGPointMake(currentNode.position.x, [string floatValue]);
            return;
        }
        if (currentElement == zPosition) {
            float zFloat = [string floatValue];
            if (currentNodeType == decoration) {
                if (zFloat >= constants.OBSTACLE_Z_POSITION) {
                    //NSUInteger dice = arc4random_uniform(5) + 1;
                    //currentNode.zPosition = constants.OBSTACLE_Z_POSITION - dice;
                    currentNode.alpha = .50;
                    //return;
                }
            }
            currentNode.zPosition = zFloat;
            return;
        }
        if (currentElement == type) {
            if ([string isEqualToString:@"ObstacleSignifier"]) {
                currentNodeType = obstacle;
                return;
            }
            if ([string isEqualToString:@"DecorationSignifier"]) {
                currentNodeType = decoration;
                return;
            }
        }
        if (currentElement == motionType) {
            if (currentNodeType == obstacle) {
                Obstacle* obs = (Obstacle*)currentNode;
                obs.currentMotionType = [string intValue];
                return;
            }
        }
        if (currentElement == speedType) {
            if (currentNodeType == obstacle) {
                Obstacle* obs = (Obstacle*)currentNode;
                obs.currentSpeedType = [string intValue];
                return;
            }
        }
        if (currentElement == uniqueID) {
            if (currentNodeType == decoration) {
                Decoration* deco = (Decoration*)currentNode;
                deco.uniqueID = string;
            }
        }
    }
}

-(void)loadObstaclesInWorld:(SKNode *)world withObstacles:(SKNode *)obstacles withinView:(SKView *)view withXOffset:(float)xOffset{

    for (Obstacle *obstacle in obstacleArray) {
        obstacle.position = CGPointMake((obstacle.position.x * constants.SCALE_COEFFICIENT.dy), obstacle.position.y * constants.SCALE_COEFFICIENT.dy);
        obstacle.position = [obstacles convertPoint:obstacle.position fromNode:world];
        obstacle.position = CGPointMake(obstacle.position.x + xOffset, obstacle.position.y);
        if (!obstacle.parent) {
            [obstacles addChild:obstacle];
        }
    }

}

-(void)pourDecorationsIntoBucket:(NSMutableArray *)bucket{
    [bucket addObjectsFromArray:decorationArray];
}

@end
