//
//  Edition.m
//  Titlz
//
//  Created by David Lains on 1/11/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Edition.h"
#import "Title.h"


@implementation Edition

@dynamic name;
@dynamic format;
@dynamic isbn;
@dynamic pages;
@dynamic printRun;
@dynamic releaseDate;
@dynamic books;
@dynamic points;
@dynamic publisher;
@dynamic title;

+(id) editionInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Edition" inManagedObjectContext:context];
}

@end
