//
//  CellParser.m
//  tgrrn
//
//  Created by John Feldcamp on 1/5/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "ChapterCellParser.h"
#import "LevelCellParser.h"
#import "ChapterCell.h"
#import "LevelCell.h"

typedef enum ElementVarieties
{
    chapter,
    name,
    imageName,
    levels,
    levelName
} Element;


@implementation ChapterCellParser{
    Element currentElement;
    ChapterCell* currentChapter;
    BOOL charactersFound;
    
}

-(instancetype)initSingleton{
    _chapters = [NSMutableArray array];
    
    BOOL success;
    NSURL *chapterXMLURL = [[NSBundle mainBundle]
                     URLForResource: @"chapterCells" withExtension:@"xml"];
     //NSLog(@"chapterXMLURL: %@", chapterXMLURL);
    NSXMLParser* chapterParser = [[NSXMLParser alloc] initWithContentsOfURL:chapterXMLURL];
    
    if (chapterParser){
         //NSLog(@"parse chapter");
        [chapterParser setDelegate:self];
        [chapterParser setShouldResolveExternalEntities:YES];
        success = [chapterParser parse];
    }
    
    return self;
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"error:%@",parseError.localizedDescription);
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
     NSLog(@"did start chapter cell document");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    charactersFound = false;
    if ([elementName isEqualToString:@"chapter"]) {
        currentElement = chapter;
        currentChapter = [[ChapterCell alloc] init];
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
    if ([elementName isEqualToString:@"levelName"]) {
        currentElement = levelName;
        return;
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"chapter"]) {
        if (currentChapter != nil) {
            [_chapters addObject:currentChapter];
        }
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (!charactersFound) {
        charactersFound = true;
        switch (currentElement) {
            case name:
                currentChapter.name = string;
                break;
            case imageName:{
                if(!currentChapter.imageName){
                    currentChapter.imageName = string;
                }
            }
                break;
            case chapter:
                break;
            case levels:
                break;
            case levelName:{
                LevelCellParser* levelParser = [LevelCellParser sharedInstance];
                LevelCell* correspondingLevelCell = [levelParser.levels objectForKey:string];
                if (correspondingLevelCell) {
                    [currentChapter.levelCells addObject:correspondingLevelCell];
                }
                else{
                    NSLog(@"level '%@' does not exist or cannot be found", string);
                }
                 break;
                }

        }

    }
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ChapterCellParser* sharedSingleton = nil;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[ChapterCellParser alloc] initSingleton];
    });
    return sharedSingleton;
}
@end

