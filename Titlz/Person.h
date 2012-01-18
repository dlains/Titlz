//
//  Person.h
//  Titlz
//
//  Created by David Lains on 1/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person, Book;

@interface Person : NSManagedObject

@property(nonatomic, retain) NSDate* born;
@property(nonatomic, retain) NSDate* died;
@property(nonatomic, readonly) NSString* firstLetterOfName;
@property(nonatomic, retain) NSString* firstName;
@property(nonatomic, retain) NSString* lastName;
@property(nonatomic, retain) NSString* middleName;
@property(nonatomic, retain) NSSet* aliases;
@property(nonatomic, retain) Person* aliasOf;
@property(nonatomic, retain) NSSet* authored;
@property(nonatomic, retain) NSSet* contributed;
@property(nonatomic, retain) NSSet* edited;
@property(nonatomic, retain) NSSet* illustrated;

// Transient properties.
@property (nonatomic, readonly) NSString* fullName;

+(id) personInManagedObjectContext:(NSManagedObjectContext*)context;

@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addAliasesObject:(Person *)value;
- (void)removeAliasesObject:(Person *)value;
- (void)addAliases:(NSSet *)values;
- (void)removeAliases:(NSSet *)values;

- (void)addAuthoredObject:(Book*)value;
- (void)removeAuthoredObject:(Book*)value;
- (void)addAuthored:(NSSet*)values;
- (void)removeAuthored:(NSSet*)values;

- (void)addContributedObject:(Book*)value;
- (void)removeContributedObject:(Book*)value;
- (void)addContributed:(NSSet*)values;
- (void)removeContributed:(NSSet*)values;

- (void)addEditedObject:(Book*)value;
- (void)removeEditedObject:(Book*)value;
- (void)addEdited:(NSSet*)values;
- (void)removeEdited:(NSSet*)values;

- (void)addIllustratedObject:(Book*)value;
- (void)removeIllustratedObject:(Book*)value;
- (void)addIllustrated:(NSSet*)values;
- (void)removeIllustrated:(NSSet*)values;

@end
