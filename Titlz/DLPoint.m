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

@end
