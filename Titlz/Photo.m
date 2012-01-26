//
//  Photo.m
//  Titlz
//
//  Created by David Lains on 1/24/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Photo.h"
#import "Book.h"


@implementation Photo

@dynamic image;
@dynamic book;

+(id) photoInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
}

@end
