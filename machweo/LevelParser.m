//
//  CellParser.m
//  tgrrn
//
//  Created by John Feldcamp on 1/5/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "LevelParser.h"
//#import "GameDataManager.h"

typedef enum ElementVarieties
{
    level
} Element;


@implementation LevelParser{
    Element currentElement;
    //NSManagedObject* currentChapterObject;
    //GameDataManager* dataManager;

    BOOL charactersFound;
    
}

-(instancetype)prepopulateLevelCells{
    //dataManager = [GameDataManager sharedInstance];
    
    _levels = [NSMutableArray array];
    
    BOOL success;
    NSURL *levelXMLURL = [[NSBundle mainBundle]
                     URLForResource: @"levels" withExtension:@"xml"];
     //NSLog(@"levelXMLURL: %@", levelXMLURL);
    NSXMLParser* levelParser = [[NSXMLParser alloc] initWithContentsOfURL:levelXMLURL];
    
    if (levelParser){
         //NSLog(@"parse chapter");
        [levelParser setDelegate:self];
        [levelParser setShouldResolveExternalEntities:YES];
        success = [levelParser parse];
    }
    
    return self;
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"error:%@",parseError.localizedDescription);
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
     NSLog(@"did start levels document");
}

//-(void)parserDidEndDocument:(NSXMLParser *)parser{
//    NSError *error = nil;
//    
//    if (![[dataManager managedObjectContext] save:&error]) {
//        NSLog(@"Unable to save managed object context.");
//        NSLog(@"%@, %@", error, error.localizedDescription);
//    }
//    else{
//        NSManagedObjectContext* context = [GameDataManager sharedInstance].managedObjectContext;
//        NSLog(@"managed object context saved for levels.");
//        
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chapter" inManagedObjectContext:context];
//        [fetchRequest setEntity:entity];
//        
//        NSError *error = nil;
//        NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
//        
//        if (error) {
//            NSLog(@"Unable to execute fetch request.");
//            NSLog(@"%@, %@", error, error.localizedDescription);
//            
//        } else {
//            //   NSLog(@"%@", result);
//            for (NSManagedObject* obj in result) {
//                NSLog(@"%@", [obj valueForKey:@"name"]);
//                
//            }
//        }
//        
//        
//    }
//}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    charactersFound = false;
    if ([elementName isEqualToString:@"level"]) {
        currentElement = level;
//        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Chapter" inManagedObjectContext:[dataManager managedObjectContext]];
//        currentChapterObject = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:[dataManager managedObjectContext]];
        return;
    }
//    if ([elementName isEqualToString:@"name"]) {
//        currentElement = name;
//        return;
//    }
//    if ([elementName isEqualToString:@"imageName"]) {
//        currentElement = imageName;
//        return;
//    }
//    if ([elementName isEqualToString:@"levelName"]) {
//        currentElement = levelName;
//        return;
//    }
}
//
//-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
//    
//    if ([elementName isEqualToString:@"chapter"]) {
//        if (currentChapter != nil) {
//            [_chapters addObject:currentChapter];
//        }
//    }
//}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (!charactersFound) {
        charactersFound = true;
        switch (currentElement) {
            case level:{
                NSString *fixedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                //NSLog(@"fixedString: %@", fixedString);
                //NSLog(@"fixedString.length: %lu", (unsigned long)fixedString.length);

                if([fixedString length] == 0){
                   // NSLog(@"break");
                     break;
                }
                [_levels addObject:fixedString];
            }
//            case name:
//                [currentChapterObject setValue:string forKey:@"name"];
//                break;
//            case imageName:{
//                if(![currentChapterObject valueForKey:@"imageName"]){
//                    [currentChapterObject setValue:string forKey:@"imageName"];
//                }
//            }
//                break;
//            case chapter:
//                break;
//            case levels:
//                break;
//            case levelName:{
//                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Level"];
//                
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"name", string];
//                [fetchRequest setPredicate:predicate];
//
//                NSError *fetchError = nil;
//                NSArray *result = [[GameDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
//                
//                if (!fetchError) {
//                    NSMutableSet *levels = [currentChapterObject mutableSetValueForKey:@"levels"];
//                    [levels addObject:result.firstObject];
//                    
//
//                } else {
//                    NSLog(@"Error fetching data.");
//                    NSLog(@"%@, %@", fetchError, fetchError.localizedDescription);
//                }
//                
//                 break;
//                }

        }

    }
}

@end
