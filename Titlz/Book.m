//
//  Book.m
//  Titlz
//
//  Created by David Lains on 2/2/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Book.h"
#import "Award.h"
#import "Collection.h"
#import "DLPoint.h"
#import "Person.h"
#import "Photo.h"
#import "Publisher.h"
#import "Seller.h"


@implementation Book

@dynamic firstLetterOfTitle;
@dynamic title;
@dynamic format;
@dynamic edition;
@dynamic printing;
@dynamic isbn;
@dynamic pages;
@dynamic releaseDate;
@dynamic purchaseDate;
@dynamic originalPrice;
@dynamic pricePaid;
@dynamic currentValue;
@dynamic bookCondition;
@dynamic jacketCondition;
@dynamic number;
@dynamic printRun;
@dynamic comments;
@dynamic thumbnail;
@dynamic awards;
@dynamic boughtFrom;
@dynamic collections;
@dynamic photo;
@dynamic points;
@dynamic publisher;
@dynamic signatures;
@dynamic workers;

+(id) bookInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:context];
}

-(NSString*) firstLetterOfTitle
{
    [self willAccessValueForKey:@"firstLetterOfTitle"];
    
    NSString* value = [[self valueForKey:@"title"] uppercaseString];
    
    NSString* result = [value substringWithRange:[value rangeOfComposedCharacterSequenceAtIndex:0]];
    
    if (result == nil)
    {
        [self didAccessValueForKey:@"firstLetterOfTitle"];
        return result;
    }
    
    // Any non-alpha character should be grouped in the # group.
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Z]" options:NSRegularExpressionSearch error:nil];
    NSArray* matches = [regex matchesInString:result options:0 range:NSMakeRange(0, [result length])];
    
    if ([matches count] == 0)
    {
        result = @"#";
    }
    
    [self didAccessValueForKey:@"firstLetterOfTitle"];
    return result;
}

// Title must not be empty.
-(BOOL) validateTitle:(id*)value error:(NSError**)error
{
    NSString* title = [*value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([title length] < 1)
    {
        NSString* localizedDesc = NSLocalizedString(@"You must supply an book title.", @"Book:validateTitle error message.");
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
