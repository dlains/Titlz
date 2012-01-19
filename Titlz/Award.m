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

@end
