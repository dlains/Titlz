//
//  Collection.m
//  Titlz
//
//  Created by David Lains on 1/30/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Collection.h"
#import "Book.h"


@implementation Collection

@dynamic name;
@dynamic books;

+(id) collectionInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Collection" inManagedObjectContext:context];
}

+(Collection*) findCollectionInContext:(NSManagedObjectContext*)context withName:(NSString*)name
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name =[cd] %@", name];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Collection" inManagedObjectContext:context];
    fetchRequest.predicate = predicate;
    
    NSArray* result = [context executeFetchRequest:fetchRequest error:nil];
    
    return [result lastObject];
}

// Name must not be empty.
-(BOOL) validateName:(id*)value error:(NSError**)error
{
    NSString* n = [*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([n length] < 1)
    {
        NSString* localizedDesc = NSLocalizedString(@"You must supply a collection name.", @"Collection:validateName error message.");
        NSDictionary* errorUserInfo = [NSDictionary dictionaryWithObject:localizedDesc forKey:NSLocalizedDescriptionKey];
        if (error)
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSValidationStringTooShortError userInfo:errorUserInfo];
        }
        return NO;
    }
    
    return YES;
}

@end
