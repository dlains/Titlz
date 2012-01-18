//
//  Book.m
//  Titlz
//
//  Created by David Lains on 1/16/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Book.h"
#import "DLPoint.h"
#import "Person.h"
#import "Publisher.h"


@implementation Book

@dynamic firstLetterOfTitle;
@dynamic title;
@dynamic subtitle;
@dynamic bookCondition;
@dynamic jacketCondition;
@dynamic comments;
@dynamic printing;
@dynamic number;
@dynamic printRun;
@dynamic originalPrice;
@dynamic pricePaid;
@dynamic edition;
@dynamic format;
@dynamic isbn;
@dynamic pages;
@dynamic releaseDate;
@dynamic purchaseDate;
@dynamic read;
@dynamic signiature;
@dynamic currentValue;
@dynamic authors;
@dynamic awards;
@dynamic collections;
@dynamic contributors;
@dynamic editors;
@dynamic illustrators;
@dynamic boughtFrom;
@dynamic publisher;
@dynamic points;

-(NSString*) firstLetterOfTitle
{
    [self willAccessValueForKey:@"firstLetterOfTitle"];
    
    NSString* value = [[self valueForKey:@"title"] uppercaseString];
    
    NSString* result = [value substringWithRange:[value rangeOfComposedCharacterSequenceAtIndex:0]];
    
    [self didAccessValueForKey:@"firstLetterOfTitle"];
    return result;
}

+(id) bookInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:context];
}

@end
