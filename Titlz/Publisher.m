//
//  Publisher.m
//  Titlz
//
//  Created by David Lains on 1/16/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Publisher.h"
#import "Book.h"


@implementation Publisher

@dynamic city;
@dynamic country;
@dynamic name;
@dynamic parent;
@dynamic postalCode;
@dynamic state;
@dynamic street;
@dynamic street1;
@dynamic books;

-(NSString*) firstLetterOfName
{
    [self willAccessValueForKey:@"firstLetterOfName"];
    
    NSString* value = [[self valueForKey:@"name"] uppercaseString];
    
    NSString* result = [value substringWithRange:[value rangeOfComposedCharacterSequenceAtIndex:0]];
    
    [self didAccessValueForKey:@"firstLetterOfName"];
    return result;
}

+(id) publisherInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Publisher" inManagedObjectContext:context];
}

+(Publisher*) findPublisherInContext:(NSManagedObjectContext*)context withName:(NSString*)name
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name ==[cd] %@", name];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Publisher" inManagedObjectContext:context];
    fetchRequest.predicate = predicate;
    
    NSArray* result = [context executeFetchRequest:fetchRequest error:nil];
    Publisher* publisher = [result lastObject];
    
    if (publisher == nil)
    {
        publisher = [Publisher publisherInManagedObjectContext:context];
        publisher.name = name;
    }
    
    return publisher;
}

// Name must not be empty.
-(BOOL) validateName:(id*)value error:(NSError**)error
{
    NSString* n = [*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([n length] < 1)
    {
        NSString* localizedDesc = NSLocalizedString(@"You must supply a publisher name.", @"Publisher:validateName error message.");
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
