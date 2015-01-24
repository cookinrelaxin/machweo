//
//  LevelCellParser.m
//  tgrrn
//
//  Created by John Feldcamp on 1/6/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "LevelCellParser.h"
#import "GameDataManager.h"
typedef enum ElementVarieties
{
    level,
    name,
    imageName,
    timeToBeatLevel
} Element;

@implementation LevelCellParser{
    Element currentElement;
    NSManagedObject* currentLevelObject;
    BOOL charactersFound;
    GameDataManager* dataManager;
}

-(instancetype)prepopulateLevelCells{
    dataManager = [GameDataManager sharedInstance];
    
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

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    NSError *error = nil;
    
    if (![[dataManager managedObjectContext] save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    else{
        NSManagedObjectContext* context = [GameDataManager sharedInstance].managedObjectContext;
        NSLog(@"managed object context saved for levels.");
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Level" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            NSLog(@"Unable to execute fetch request.");
            NSLog(@"%@, %@", error, error.localizedDescription);
            
        } else {
         //   NSLog(@"%@", result);
            for (NSManagedObject* obj in result) {
                NSLog(@"%@", [obj valueForKey:@"name"]);

            }
        }
        

    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    charactersFound = false;
    if ([elementName isEqualToString:@"level"]) {
        currentElement = level;
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Level" inManagedObjectContext:[dataManager managedObjectContext]];
        currentLevelObject = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:[dataManager managedObjectContext]];
        
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
    if ([elementName isEqualToString:@"timeToBeatLevel"]) {
        currentElement = timeToBeatLevel;
        return;
    }
}

//
//-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
//    
//    if ([elementName isEqualToString:@"level"]) {
//        if (currentLevel != nil) {
//            [_levels setObject:currentLevel forKey:currentLevel.name];
//        }
//    }
//}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (!charactersFound) {
        charactersFound = true;
        switch (currentElement) {
            case name:
                [currentLevelObject setValue:string forKey:@"name"];
                break;
            case imageName:
                [currentLevelObject setValue:string forKey:@"imageName"];
                break;
            case level:
                break;
            case timeToBeatLevel:
                [currentLevelObject setValue:[NSNumber numberWithInt:[string intValue]] forKey:@"timeToBeatLevel"];
                break;
                
        }
        
    }
}

@end
