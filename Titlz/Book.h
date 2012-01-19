//
//  Book.h
//  Titlz
//
//  Created by David Lains on 1/16/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DLPoint, Person, Publisher, Seller;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSString* firstLetterOfTitle;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* subtitle;
@property (nonatomic, retain) NSString* bookCondition;
@property (nonatomic, retain) NSString* jacketCondition;
@property (nonatomic, retain) NSString* comments;
@property (nonatomic, retain) NSNumber* printing;
@property (nonatomic, retain) NSNumber* number;
@property (nonatomic, retain) NSNumber* printRun;
@property (nonatomic, retain) NSDecimalNumber* originalPrice;
@property (nonatomic, retain) NSDecimalNumber* pricePaid;
@property (nonatomic, retain) NSString* edition;
@property (nonatomic, retain) NSString* format;
@property (nonatomic, retain) NSString* isbn;
@property (nonatomic, retain) NSNumber* pages;
@property (nonatomic, retain) NSDate* releaseDate;
@property (nonatomic, retain) NSDate* purchaseDate;
@property (nonatomic, retain) NSNumber* read;
@property (nonatomic, retain) NSNumber* signiature;
@property (nonatomic, retain) NSDecimalNumber* currentValue;
@property (nonatomic, retain) NSSet* authors;
@property (nonatomic, retain) NSSet* awards;
@property (nonatomic, retain) NSSet* collections;
@property (nonatomic, retain) NSSet* contributors;
@property (nonatomic, retain) NSSet* editors;
@property (nonatomic, retain) NSSet* illustrators;
@property (nonatomic, retain) Seller* boughtFrom;
@property (nonatomic, retain) Publisher* publisher;
@property (nonatomic, retain) NSSet* points;

+(id) bookInManagedObjectContext:(NSManagedObjectContext*)context;

@end

@interface Book (CoreDataGeneratedAccessors)

- (void)addAuthorsObject:(Person *)value;
- (void)removeAuthorsObject:(Person *)value;
- (void)addAuthors:(NSSet *)values;
- (void)removeAuthors:(NSSet *)values;

- (void)addAwardsObject:(NSManagedObject *)value;
- (void)removeAwardsObject:(NSManagedObject *)value;
- (void)addAwards:(NSSet *)values;
- (void)removeAwards:(NSSet *)values;

- (void)addCollectionsObject:(NSManagedObject *)value;
- (void)removeCollectionsObject:(NSManagedObject *)value;
- (void)addCollections:(NSSet *)values;
- (void)removeCollections:(NSSet *)values;

- (void)addContributorsObject:(Person *)value;
- (void)removeContributorsObject:(Person *)value;
- (void)addContributors:(NSSet *)values;
- (void)removeContributors:(NSSet *)values;

- (void)addEditorsObject:(Person *)value;
- (void)removeEditorsObject:(Person *)value;
- (void)addEditors:(NSSet *)values;
- (void)removeEditors:(NSSet *)values;

- (void)addIllustratorsObject:(Person *)value;
- (void)removeIllustratorsObject:(Person *)value;
- (void)addIllustrators:(NSSet *)values;
- (void)removeIllustrators:(NSSet *)values;

- (void)addPointsObject:(DLPoint *)value;
- (void)removePointsObject:(DLPoint *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;

@end
