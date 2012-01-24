//
//  Award.m
//  Titlz
//
//  Created by David Lains on 1/19/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Award.h"
#import "Book.h"


@implementation Award

@dynamic category;
@dynamic name;
@dynamic year;
@dynamic book;

+(id) awardInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Award" inManagedObjectContext:context];
}

#pragma mark - Validation

// Name must not be empty.
-(BOOL) validateName:(id*)value error:(NSError**)error
{
    NSString* n = [*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([n length] < 1)
    {
        NSString* localizedDesc = NSLocalizedString(@"You must supply an award name.", @"Award:validateName error message.");
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
