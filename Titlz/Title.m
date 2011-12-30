//
//  Title.m
//  Titlz
//
//  Created by David Lains on 12/27/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import "Title.h"


@implementation Title

@dynamic name;
@dynamic authors;
@dynamic books;
@dynamic collections;
@dynamic contributors;
@dynamic editions;
@dynamic editors;
@dynamic illustrators;

+(id) titleInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Title" inManagedObjectContext:context];
}

@end
