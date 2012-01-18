//
//  DLPoint.h
//  Titlz
//
//  Created by David Lains on 1/12/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface DLPoint : NSManagedObject

@property (nonatomic, retain) NSString* issue;
@property (nonatomic, retain) NSString* location;
@property (nonatomic, retain) Book* book;

+(id) pointInManagedObjectContext:(NSManagedObjectContext*)context;

@end
