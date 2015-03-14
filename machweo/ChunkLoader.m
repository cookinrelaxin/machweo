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
    // as simple as possible for now. assume all nodes are obstacles
    NSMutableArray* obstacleArray;
    NSMutableArray* decorationArray;
    NSMutableArray* terrainPoolArray;


    SKNode *currentNode;
    Element currentElement;
    Node currentNodeType;
    BOOL charactersFound;
    
    Constants* constants;
    
    NSMutableDictionary* textureDict;
    
}

-(instancetype)initWithFile:(NSString*)fileName{
    constants = [Constants sharedInstance];
    
    textureDict = constants.TEXTURE_DICT;
    
    obstacleArray = [NSMutableArray array];
    decorationArray = [NSMutableArray array];
    terrainPoolArray = [NSMutableArray array];

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
            SKTexture *spriteTexture = [textureDict objectForKey:string];
            if (spriteTexture == nil) {
                spriteTexture = [SKTexture textureWithImageNamed:string];
                [textureDict setValue:spriteTexture forKey:string];
            }
            
            if (spriteTexture) {
                if (currentNodeType == obstacle) {
                    currentNode = [Obstacle obstacleWithTextureAndPhysicsBody:spriteTexture];
                    Obstacle* obstacle = (Obstacle*)currentNode;
                    obstacle.size = CGSizeMake(obstacle.size.width * constants.SCALE_COEFFICIENT.dy, obstacle.size.height * constants.SCALE_COEFFICIENT.dy);
//                    obstacle.physicsBody = [SKPhysicsBody bodyWithTexture:spriteTexture size:obstacle.size];
//                    currentNode.physicsBody.categoryBitMask = [Constants sharedInstance].OBSTACLE_HIT_CATEGORY;
//                    currentNode.physicsBody.contactTestBitMask = [Constants sharedInstance].PLAYER_HIT_CATEGORY;
//                    currentNode.physicsBody.dynamic = false;

                }
                else if (currentNodeType == decoration){
                    currentNode = [Decoration spriteNodeWithTexture:spriteTexture];
                }
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
            if (spriteTexture == nil) {
                //NSLog(@"(spriteTexture == nil)");
                spriteTexture = [SKTexture textureWithImageNamed:string];
                [textureDict setValue:spriteTexture forKey:string];
            }
            //NSLog(@"spriteTexture :%@", spriteTexture);
            [terrainPoolArray addObject:spriteTexture];
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

-(void)loadObstaclesInWorld:(SKNode *)world withObstacles:(SKNode *)obstacles andBucket:(NSMutableArray *)bucket withinView:(SKView *)view andTerrainPool:(NSMutableArray *)terrainPool withXOffset:(float)xOffset{

    for (Obstacle *obstacle in obstacleArray) {
        obstacle.position = CGPointMake((obstacle.position.x * constants.SCALE_COEFFICIENT.dy), obstacle.position.y * constants.SCALE_COEFFICIENT.dy);
        obstacle.position = [obstacles convertPoint:obstacle.position fromNode:world];
        obstacle.position = CGPointMake(obstacle.position.x + xOffset, obstacle.position.y);
        
        obstacle.physicsBody = [SKPhysicsBody bodyWithTexture:obstacle.texture size:obstacle.size];
        //obstacle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:obstacle.size];
        currentNode.physicsBody.categoryBitMask = [Constants sharedInstance].OBSTACLE_HIT_CATEGORY;
        currentNode.physicsBody.contactTestBitMask = [Constants sharedInstance].PLAYER_HIT_CATEGORY;
        currentNode.physicsBody.dynamic = false;

        obstacle.zPosition = constants.OBSTACLE_Z_POSITION;
        [obstacles addChild:obstacle];
        [bucket addObject:obstacle];
    }



}

//-(void)pourObstaclesIntoBucket:(NSMutableArray *)bucket{
//    [bucket addObjectsFromArray:obstacleArray];
//}


-(void)pourDecorationsIntoBucket:(NSMutableArray *)bucket andTerrainPool:(NSMutableArray *)terrainPool{
    [bucket addObjectsFromArray:decorationArray];
    //terrainPool = terrainPoolArray;
    //NSLog(@"2. _terrainPool: %@", terrainPool);
    for (SKTexture* tex in terrainPoolArray) {
        if (![terrainPool containsObject:tex]) {
            [terrainPool addObject:tex];
        }
    }
   // [terrainPool addObjectsFromArray:terrainPoolArray];

}

@end
