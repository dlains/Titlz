//
//  Person.m
//  Titlz
//
//  Created by David Lains on 1/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Person.h"
#import "Person.h"
#import "Book.h"


@interface Person()
-(BOOL) validateForInsertAndUpdate:(NSError*__autoreleasing *)error; 
@end
@implementation Person

@dynamic born;
@dynamic died;
@dynamic firstName;
@dynamic lastName;
@dynamic middleName;
@dynamic aliases;
@dynamic aliasOf;
@dynamic authored;
@dynamic contributed;
@dynamic edited;
@dynamic illustrated;
@dynamic booksSigned;

-(NSString*) fullName
{
    NSMutableString* fn = [NSMutableString stringWithCapacity:50];
    
    if (self.firstName.length > 0)
    {
        [fn appendString:self.firstName];
        [fn appendString:@" "];
    }
    
    if (self.middleName.length > 0)
    {
        [fn appendString:self.middleName];
        [fn appendString:@" "];
    }

    if (self.lastName.length > 0)
    {
        [fn appendString:self.lastName];
    }

    return fn;
}

-(NSString*) firstLetterOfName
{
    [self willAccessValueForKey:@"firstLetterOfName"];
    
    NSString* value = [[self valueForKey:@"lastName"] uppercaseString];

    NSString* result = nil;
    if ([value length] > 0)
    {
        result = [value substringWithRange:[value rangeOfComposedCharacterSequenceAtIndex:0]];
    }
    else
    {
        result = @"";
    }
    
    [self didAccessValueForKey:@"firstLetterOfName"];
    return result;
}

+(id) personInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
}

#pragma mark - Validation

// Last name must not be empty.
-(BOOL) validateLastName:(id*)value error:(NSError**)error
{
    NSString* ln = [*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([ln length] < 1)
    {
        NSString* localizedDesc = NSLocalizedString(@"You must supply a last name.", @"Person:validateLastName error message.");
        NSDictionary* errorUserInfo = [NSDictionary dictionaryWithObject:localizedDesc forKey:NSLocalizedDescriptionKey];
        if (error)
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSValidationStringTooShortError userInfo:errorUserInfo];
        }
        return NO;
    }

    return YES;
}

// Can't be born later than today.
-(BOOL) validateBorn:(id*)value error:(NSError**)error
{
    NSDate* inputDate = *value;
    NSDate* currentDate = [NSDate date];
    
    if ([inputDate compare:currentDate] == NSOrderedDescending)
    {
        NSString* localizedDesc = NSLocalizedString(@"Birth date can not be later than today.", @"Person:validateBorn error message.");
        NSDictionary* errorUserInfo = [NSDictionary dictionaryWithObject:localizedDesc forKey:NSLocalizedDescriptionKey];
        if (error)
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSValidationDateTooLateError userInfo:errorUserInfo];
        }
        return NO;
    }
    
    return YES;
}

// Can't have died later than today.
-(BOOL) validateDied:(id*)value error:(NSError**)error
{
    NSDate* inputDate = *value;
    NSDate* currentDate = [NSDate date];
    
    if ([inputDate compare:currentDate] == NSOrderedDescending)
    {
        NSString* localizedDesc = NSLocalizedString(@"Died date can not be later than today.", @"Person:validateDied error message.");
        NSDictionary* errorUserInfo = [NSDictionary dictionaryWithObject:localizedDesc forKey:NSLocalizedDescriptionKey];
        if (error)
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSValidationDateTooLateError userInfo:errorUserInfo];
        }
        return NO;
    }
    
    return YES;
}

// Validate entire entity.
-(BOOL) validateForInsert:(NSError*__autoreleasing *)error
{
    return [self validateForInsertAndUpdate:error];
}

-(BOOL) validateForUpdate:(NSError*__autoreleasing *)error
{
    return [self validateForInsertAndUpdate:error];
}

-(BOOL) validateForInsertAndUpdate:(NSError*__autoreleasing *)error
{
    BOOL valid = [super validateForInsert:error];
    
    NSMutableArray* errorsArray = [NSMutableArray array];
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    
    // Check to see if there are existing errors.
    if (*error && [*error code] == NSValidationMultipleErrorsError)
    {
        [userInfo addEntriesFromDictionary:[*error userInfo]];
        [errorsArray addObjectsFromArray:[userInfo objectForKey:NSDetailedErrorsKey]];
    }
    else if (*error)
    {
        [errorsArray addObject:*error];
    }
    
    // Born date can't be later than Died date.
    if ([self.born compare:self.died] == NSOrderedDescending)
    {
        valid = NO;
        
        NSString* desc = NSLocalizedString(@"Birth date must be before the date of death.", @"Person:validateForInsertAndUpdate birth date error message");
        NSDictionary* errorUserInfo = [NSDictionary dictionaryWithObject:desc forKey:NSLocalizedDescriptionKey];
        NSError* dateOfBirthError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSValidationDateTooLateError userInfo:errorUserInfo];
        
        [errorsArray addObject:dateOfBirthError];
    }
    
    if (error && [errorsArray count] > 1)
    {
        [userInfo setObject:errorsArray forKey:NSDetailedErrorsKey];
        NSError* multipleError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSValidationMultipleErrorsError userInfo:userInfo];
        *error = multipleError;
    }
    else if (error && [errorsArray count] == 1)
    {
        *error = [errorsArray objectAtIndex:0];
    }
    
    return valid;
}

@end
