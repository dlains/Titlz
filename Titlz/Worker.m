//
//  Worker.m
//  Titlz
//
//  Created by David Lains on 2/2/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Worker.h"
#import "Book.h"
#import "Person.h"


@implementation Worker

@dynamic title;
@dynamic book;
@dynamic person;

+(id) workerInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Worker" inManagedObjectContext:context];
}

@end
