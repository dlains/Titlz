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

@dynamic name;
@dynamic parent;
@dynamic street;
@dynamic street1;
@dynamic city;
@dynamic country;
@dynamic state;
@dynamic postalCode;
@dynamic editions;

+(id) publisherInManagedObjectContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Publisher" inManagedObjectContext:context];
}

-(NSString*) firstLetterOfName
{
    [self willAccessValueForKey:@"firstLetterOfName"];
    
    NSString* value = [[self valueForKey:@"name"] uppercaseString];
    
    NSString* result = [value substringWithRange:[value rangeOfComposedCharacterSequenceAtIndex:0]];
    
    [self didAccessValueForKey:@"firstLetterOfName"];
    return result;
}

@end
