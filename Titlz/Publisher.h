//
//  Publisher.h
//  Titlz
//
//  Created by David Lains on 1/16/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Publisher : NSManagedObject

@property (nonatomic, retain) NSString* city;
@property (nonatomic, readonly) NSString* firstLetterOfName;
@property (nonatomic, retain) NSString* country;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* parent;
@property (nonatomic, retain) NSString* postalCode;
@property (nonatomic, retain) NSString* state;
@property (nonatomic, retain) NSString* street;
@property (nonatomic, retain) NSString* street1;
@property (nonatomic, retain) NSSet* books;

+(id) publisherInManagedObjectContext:(NSManagedObjectContext*)context;
+(Publisher*) findPublisherInContext:(NSManagedObjectContext*)context withName:(NSString*)name;

@end

@interface Publisher (CoreDataGeneratedAccessors)

- (void)addBooksObject:(Book*)value;
- (void)removeBooksObject:(Book*)value;
- (void)addBooks:(NSSet*)values;
- (void)removeBooks:(NSSet*)values;

@end
