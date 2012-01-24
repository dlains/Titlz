//
//  Seller.m
//  Titlz
//
//  Created by David Lains on 1/18/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Seller.h"
#import "Book.h"


@implementation Seller

@dynamic city;
@dynamic country;
@dynamic email;
@dynamic name;
@dynamic phone;
@dynamic postalCode;
@dynamic state;
@dynamic street;
@dynamic street1;
@dynamic books;
@dynamic website;

+(id) sellerInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Seller" inManagedObjectContext:context];
}

// Name must not be empty.
-(BOOL) validateName:(id*)value error:(NSError**)error
{
    NSString* n = [*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([n length] < 1)
    {
        NSString* localizedDesc = NSLocalizedString(@"You must supply a seller name.", @"Seller:validateName error message.");
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
