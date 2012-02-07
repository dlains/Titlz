//
//  Worker.h
//  Titlz
//
//  Created by David Lains on 2/2/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book, Person;

@interface Worker : NSManagedObject

@property(nonatomic, retain) NSString* title;
@property(nonatomic, retain) Book* book;
@property(nonatomic, retain) Person* person;

+(id) workerInManagedObjectContext:(NSManagedObjectContext*)context;

@end
