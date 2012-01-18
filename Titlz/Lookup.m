//
//  Lookup.m
//  Titlz
//
//  Created by David Lains on 1/18/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Lookup.h"


@implementation Lookup

@dynamic type;
@dynamic value;

+(id) lookupInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Lookup" inManagedObjectContext:context];
}

@end
