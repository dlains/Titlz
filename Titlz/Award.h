//
//  Award.h
//  Titlz
//
//  Created by David Lains on 1/19/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Award : NSManagedObject

@property(nonatomic, retain) NSString* category;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* year;
@property(nonatomic, retain) Book* book;

+(id) awardInManagedObjectContext:(NSManagedObjectContext*)context;

@end
