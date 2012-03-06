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

@dynamic createdDate;
@dynamic lastReadDate;
@dynamic firstLetterOfTitle;
@dynamic sortableTitle;
@dynamic title;
@dynamic format;
@dynamic edition;
@dynamic seriesName;
@dynamic genre;
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
@dynamic location;
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
    Book* newBook = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:context];
    newBook.createdDate = [NSDate date];
    return newBook;
}

-(NSString*) firstLetterOfTitle
{
    [self willAccessValueForKey:@"firstLetterOfTitle"];
    
    NSString* value = [[self valueForKey:@"title"] uppercaseString];
    NSString* result = nil;
    
    // Ignore 'the', 'a' and 'an' as first words in the title.
    if ([value hasPrefix:@"THE "])
    {
        result = [value substringWithRange:[value rangeOfComposedCharacterSequenceAtIndex:4]];
    }
    else if ([value hasPrefix:@"A "])
    {
        result = [value substringWithRange:[value rangeOfComposedCharacterSequenceAtIndex:2]];
    }
    else if ([value hasPrefix:@"AN "])
    {
        result = [value substringWithRange:[value rangeOfComposedCharacterSequenceAtIndex:3]];
    }
    else
    {
        result = [value substringWithRange:[value rangeOfComposedCharacterSequenceAtIndex:0]];
    }
    
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

-(void) setSortableTitle:(NSString*)sortableTitle
{
    [self willChangeValueForKey:@"sortableTitle"];
    
    NSString* value = [sortableTitle uppercaseString];
    NSString* result = nil;
    
    // Ignore 'the', 'a' and 'an' as first words in the title.
    if ([value hasPrefix:@"THE "])
    {
        NSRange range = NSMakeRange(4, sortableTitle.length - 5);
        result = [NSString stringWithFormat:@"%@, %@", [sortableTitle substringWithRange:range], @"The"];
    }
    else if ([value hasPrefix:@"A "])
    {
        NSRange range = NSMakeRange(2, sortableTitle.length - 3);
        result = [NSString stringWithFormat:@"%@, %@", [sortableTitle substringWithRange:range], @"A"];
    }
    else if ([value hasPrefix:@"AN "])
    {
        NSRange range = NSMakeRange(3, sortableTitle.length - 4);
        result = [NSString stringWithFormat:@"%@, %@", [sortableTitle substringWithRange:range], @"An"];
    }
    else
    {
        result = value;
    }
    
    [self setPrimitiveValue:result forKey:@"sortableTitle"];
    
    [self didChangeValueForKey:@"sortableTitle"];
}

-(void) setTitle:(NSString *)title
{
    [self willChangeValueForKey:@"title"];
    [self setPrimitiveValue:title forKey:@"title"];
    [self didChangeValueForKey:@"title"];
    
    self.sortableTitle = title;
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
