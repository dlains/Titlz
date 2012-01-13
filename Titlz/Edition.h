//
//  Edition.h
//  Titlz
//
//  Created by David Lains on 1/11/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Title;

@interface Edition : NSManagedObject

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* format;
@property (nonatomic, retain) NSString* isbn10;
@property (nonatomic, retain) NSString* isbn13;
@property (nonatomic, retain) NSString* pages;
@property (nonatomic, retain) NSString* printRun;
@property (nonatomic, retain) NSDate* releaseDate;
@property (nonatomic, retain) NSSet* books;
@property (nonatomic, retain) NSSet* points;
@property (nonatomic, retain) NSManagedObject* publisher;
@property (nonatomic, retain) Title* title;

+(id) editionInManagedObjectContext:(NSManagedObjectContext*)context;

@end

@interface Edition (CoreDataGeneratedAccessors)

- (void)addBooksObject:(NSManagedObject *)value;
- (void)removeBooksObject:(NSManagedObject *)value;
- (void)addBooks:(NSSet *)values;
- (void)removeBooks:(NSSet *)values;

- (void)addPointsObject:(NSManagedObject *)value;
- (void)removePointsObject:(NSManagedObject *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;

@end
