//
//  DLPoint.m
//  Titlz
//
//  Created by David Lains on 1/12/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "DLPoint.h"
#import "Book.h"


@implementation DLPoint

@dynamic issue;
@dynamic location;
@dynamic book;

+(id) pointInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Point" inManagedObjectContext:context];
}

#pragma mark - Validation

// Issue must not be empty.
-(BOOL) validateIssue:(id*)value error:(NSError**)error
{
    NSString* issue = [*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([issue length] < 1)
    {
        NSString* localizedDesc = NSLocalizedString(@"You must supply an issue.", @"Point:validateIssue error message.");
        NSDictionary* errorUserInfo = [NSDictionary dictionaryWithObject:localizedDesc forKey:NSLocalizedDescriptionKey];
        if (error)
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSValidationStringTooShortError userInfo:errorUserInfo];
        }
        return NO;
    }
    
    return YES;
}

// Location must not be empty.
-(BOOL) validateLocation:(id*)value error:(NSError**)error
{
    NSString* location = [*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([location length] < 1)
    {
        NSString* localizedDesc = NSLocalizedString(@"You must supply a location.", @"Point:validateLocation error message.");
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
