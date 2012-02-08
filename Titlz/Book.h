//
//  Book.h
//  Titlz
//
//  Created by David Lains on 2/2/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Award, Collection, DLPoint, Person, Photo, Publisher, Seller;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSString* firstLetterOfTitle;
@property (nonatomic, retain) NSString* sortableTitle;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* format;
@property (nonatomic, retain) NSString* edition;
@property (nonatomic, retain) NSNumber* printing;
@property (nonatomic, retain) NSString* isbn;
@property (nonatomic, retain) NSNumber* pages;
@property (nonatomic, retain) NSDate* releaseDate;
@property (nonatomic, retain) NSDate* purchaseDate;
@property (nonatomic, retain) NSDecimalNumber* originalPrice;
@property (nonatomic, retain) NSDecimalNumber* pricePaid;
@property (nonatomic, retain) NSDecimalNumber* currentValue;
@property (nonatomic, retain) NSString* bookCondition;
@property (nonatomic, retain) NSString* jacketCondition;
@property (nonatomic, retain) NSNumber* number;
@property (nonatomic, retain) NSNumber* printRun;
@property (nonatomic, retain) NSString* comments;
@property (nonatomic, retain) UIImage* thumbnail;
@property (nonatomic, retain) NSSet* awards;
@property (nonatomic, retain) Seller* boughtFrom;
@property (nonatomic, retain) NSSet* collections;
@property (nonatomic, retain) Photo* photo;
@property (nonatomic, retain) NSSet* points;
@property (nonatomic, retain) Publisher* publisher;
@property (nonatomic, retain) NSSet* signatures;
@property (nonatomic, retain) NSSet* workers;

+(id) bookInManagedObjectContext:(NSManagedObjectContext*)context;

@end

@interface Book (CoreDataGeneratedAccessors)

-(void) addAwardsObject:(Award *)value;
-(void) removeAwardsObject:(Award *)value;
-(void) addAwards:(NSSet *)values;
-(void) removeAwards:(NSSet *)values;

-(void) addCollectionsObject:(Collection *)value;
-(void) removeCollectionsObject:(Collection *)value;
-(void) addCollections:(NSSet *)values;
-(void) removeCollections:(NSSet *)values;

-(void) addPointsObject:(DLPoint *)value;
-(void) removePointsObject:(DLPoint *)value;
-(void) addPoints:(NSSet *)values;
-(void) removePoints:(NSSet *)values;

-(void) addSignaturesObject:(Person *)value;
-(void) removeSignaturesObject:(Person *)value;
-(void) addSignatures:(NSSet *)values;
-(void) removeSignatures:(NSSet *)values;

-(void) addWorkersObject:(NSManagedObject *)value;
-(void) removeWorkersObject:(NSManagedObject *)value;
-(void) addWorkers:(NSSet *)values;
-(void) removeWorkers:(NSSet *)values;

@end
