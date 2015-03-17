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
#import "Line.h"

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
    terrainPool,
    terrainPoolMember,
    uniqueID

    
} Element;

typedef enum NodeTypes
{
    obstacle,
    decoration,
} Node;

@implementation ChunkLoader{

    AugmentedSprite *currentNode;
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
    
    _obstacleArray = [NSMutableArray array];
    _decorationArray = [NSMutableArray array];
    _terrainPoolArray = [NSMutableArray array];

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
    if ([elementName isEqualToString:@"terrainPool"]) {
        currentElement = terrainPool;
        return;
    }
    if ([elementName isEqualToString:@"terrainPoolMember"]) {
        currentElement = terrainPoolMember;
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
                    [_obstacleArray addObject:currentNode];
                    break;
                case decoration:
                    [_decorationArray addObject:currentNode];
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
                    //NSLog(@"remove %@ from obstacle pool", string);
                }
                //NSLog(@"obstacleTypeArray: %@", obstacleTypeArray);
                return;

            }
            else if (currentNodeType == decoration){
                SKTexture *spriteTexture = [textureDict objectForKey:string];
                if (spriteTexture) {
                    currentNode = [Decoration spriteNodeWithTexture:spriteTexture];
                }
                return;
            }
            else{
                currentNode = nil;
            }
            //NSLog(@"name: %@", string);
            //currentNode.name = string;
            return;
        }
        if (currentElement == xPosition) {
            //NSLog(@"xPosition: %@", string);
            currentNode.rawPosition = CGPointMake([string floatValue], currentNode.rawPosition.y);
            currentNode.rawPosition = CGPointMake(currentNode.rawPosition.x * constants.SCALE_COEFFICIENT.dy, currentNode.rawPosition.y);
            return;
        }
        if (currentElement == yPosition) {
            //NSLog(@"yPosition: %@", string);
            currentNode.rawPosition = CGPointMake(currentNode.rawPosition.x, [string floatValue]);
            currentNode.rawPosition = CGPointMake(currentNode.rawPosition.x, currentNode.rawPosition.y * constants.SCALE_COEFFICIENT.dy);

            return;
        }
        if (currentElement == zPosition) {
            //NSLog(@"zPosition: %@", string);
            float zFloat = [string floatValue];
            if (zFloat >= constants.OBSTACLE_Z_POSITION) {
                currentNode.alpha = .50;
            }
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
        if (currentElement == terrainPoolMember) {
            //NSLog(@"add terrainPoolMember");
            SKTexture *spriteTexture = [textureDict objectForKey:string];
            if (spriteTexture) {
                [_terrainPoolArray addObject:spriteTexture];
            }
            //NSLog(@"spriteTexture :%@", spriteTexture);
        }
        if (currentElement == uniqueID) {
            if ([currentNode isKindOfClass:[Decoration class]]) {
                Decoration* deco = (Decoration*)currentNode;
                deco.uniqueID = string;
                //NSLog(@"deco.uniqueID: %@", deco.uniqueID);
            }
            if ([currentNode isKindOfClass:[Obstacle class]]) {
                Obstacle* obs = (Obstacle*)currentNode;
                obs.uniqueID = string;
            }
        }
    }
}

@end
