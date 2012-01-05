//
//  Person.m
//  Titlz
//
//  Created by David Lains on 1/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "Person.h"
#import "Person.h"
#import "Title.h"


@implementation Person

@dynamic born;
@dynamic died;
@dynamic firstName;
@dynamic lastName;
@dynamic middleName;
@dynamic aliases;
@dynamic aliasOf;
@dynamic authored;
@dynamic contributed;
@dynamic edited;
@dynamic illustrated;

-(NSString*) fullName
{
    if (self.middleName.length > 0)
    {
        return [NSString stringWithFormat:@"%@ %@ %@", self.firstName, self.middleName, self.lastName];
    }
    else
    {
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    }
}

+(id) personInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
}

@end
