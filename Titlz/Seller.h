//
//  Seller.h
//  Titlz
//
//  Created by David Lains on 1/18/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Seller : NSManagedObject

@property(nonatomic, readonly) NSString* firstLetterOfName;
@property(nonatomic, retain) NSString* city;
@property(nonatomic, retain) NSString* country;
@property(nonatomic, retain) NSString* email;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* phone;
@property(nonatomic, retain) NSString* postalCode;
@property(nonatomic, retain) NSString* state;
@property(nonatomic, retain) NSString* street;
@property(nonatomic, retain) NSString* street1;
@property(nonatomic, retain) NSString* website;
@property(nonatomic, retain) NSSet* books;

+(id) sellerInManagedObjectContext:(NSManagedObjectContext*)context;

@end

@interface Seller (CoreDataGeneratedAccessors)

- (void)addBooksObject:(Book *)value;
- (void)removeBooksObject:(Book *)value;
- (void)addBooks:(NSSet *)values;
- (void)removeBooks:(NSSet *)values;

@end
