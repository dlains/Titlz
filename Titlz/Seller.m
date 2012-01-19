//
//  Seller.m
//  Titlz
//
//  Created by David Lains on 1/18/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Seller.h"
#import "Book.h"


@implementation Seller

@dynamic city;
@dynamic country;
@dynamic email;
@dynamic name;
@dynamic phone;
@dynamic postalCode;
@dynamic state;
@dynamic street;
@dynamic street1;
@dynamic books;
@dynamic website;

+(id) sellerInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Seller" inManagedObjectContext:context];
}

@end
