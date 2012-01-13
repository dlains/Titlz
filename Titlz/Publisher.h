//
//  Publisher.h
//  Titlz
//
//  Created by David Lains on 1/12/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Edition;

@interface Publisher : NSManagedObject

@property (nonatomic, retain) NSString* address;
@property (nonatomic, retain) NSString* address1;
@property (nonatomic, retain) NSString* city;
@property (nonatomic, retain) NSString* country;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* phone;
@property (nonatomic, retain) NSString* state;
@property (nonatomic, retain) NSString* zip;
@property (nonatomic, retain) NSSet* editions;

+(id) publisherInManagedObjectContext:(NSManagedObjectContext*)context;

@end

@interface Publisher (CoreDataGeneratedAccessors)

- (void)addEditionsObject:(Edition *)value;
- (void)removeEditionsObject:(Edition *)value;
- (void)addEditions:(NSSet *)values;
- (void)removeEditions:(NSSet *)values;

@end
