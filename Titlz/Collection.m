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
