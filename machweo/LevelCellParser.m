//
//  LevelCellParser.m
//  tgrrn
//
//  Created by John Feldcamp on 1/6/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "LevelCellParser.h"
#import "LevelCell.h"

typedef enum ElementVarieties
{
    level,
    name,
    imageName,
} Element;

@implementation LevelCellParser{
    Element currentElement;
    LevelCell* currentLevel;
    BOOL charactersFound;
}

-(instancetype)initSingleton{
    _levels = [NSMutableDictionary dictionary];
    
    BOOL success;
    NSURL *levelsXMLURL = [[NSBundle mainBundle]
                            URLForResource: @"levelCells" withExtension:@"xml"];
    //NSLog(@"levelsXMLURL: %@", levelsXMLURL);
    NSXMLParser* levelsParser = [[NSXMLParser alloc] initWithContentsOfURL:levelsXMLURL];
    
    if (levelsParser){
        //NSLog(@"parse levels");
        [levelsParser setDelegate:self];
        [levelsParser setShouldResolveExternalEntities:YES];
        success = [levelsParser parse];
    }
    
    return self;
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"error:%@",parseError.localizedDescription);
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    NSLog(@"did start level cell document");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    charactersFound = false;
    if ([elementName isEqualToString:@"level"]) {
        currentElement = level;
        currentLevel = [[LevelCell alloc] init];
        return;
    }
    if ([elementName isEqualToString:@"name"]) {
        currentElement = name;
        return;
    }
    if ([elementName isEqualToString:@"imageName"]) {
        currentElement = imageName;
        return;
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"level"]) {
        if (currentLevel != nil) {
            [_levels setObject:currentLevel forKey:currentLevel.name];
        }
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (!charactersFound) {
        charactersFound = true;
        switch (currentElement) {
            case name:
                currentLevel.name = string;
                break;
            case imageName:
                currentLevel.imageName = string;
                break;
            case level:
                break;
                
        }
        
    }
}


+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static LevelCellParser* sharedSingleton = nil;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[LevelCellParser alloc] initSingleton];
    });
    return sharedSingleton;
}
@end
