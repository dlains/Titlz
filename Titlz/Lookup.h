//
//  Lookup.h
//  Titlz
//
//  Created by David Lains on 1/18/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Lookup : NSManagedObject

@property(nonatomic, retain) NSNumber* type;
@property(nonatomic, retain) NSString* value;

+(id) lookupInManagedObjectContext:(NSManagedObjectContext*)context;

@end
