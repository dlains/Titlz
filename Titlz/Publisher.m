//
//  Publisher.m
//  Titlz
//
//  Created by David Lains on 1/12/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Publisher.h"
#import "Edition.h"


@implementation Publisher

@dynamic address;
@dynamic address1;
@dynamic city;
@dynamic country;
@dynamic name;
@dynamic phone;
@dynamic state;
@dynamic zip;
@dynamic editions;

+(id) publisherInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Publisher" inManagedObjectContext:context];
}

@end
