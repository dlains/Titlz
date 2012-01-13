//
//  Book.m
//  Titlz
//
//  Created by David Lains on 1/12/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Book.h"
#import "Edition.h"
#import "Title.h"


@implementation Book

@dynamic comments;
@dynamic condition;
@dynamic currentValue;
@dynamic jacketCondition;
@dynamic number;
@dynamic originalPrice;
@dynamic pricePaid;
@dynamic printing;
@dynamic signiture;
@dynamic read;
@dynamic boughtFrom;
@dynamic edition;
@dynamic title;

+(id) bookInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:context];
}

@end
