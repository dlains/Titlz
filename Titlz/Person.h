//
//  Person.h
//  Titlz
//
//  Created by David Lains on 1/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person, Title;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSDate* born;
@property (nonatomic, retain) NSDate* died;
@property (nonatomic, retain) NSString* firstName;
@property (nonatomic, retain) NSString* lastName;
@property (nonatomic, retain) NSString* middleName;
@property (nonatomic, retain) NSSet* aliases;
@property (nonatomic, retain) Person* aliasOf;
@property (nonatomic, retain) NSSet* authored;
@property (nonatomic, retain) NSSet* contributedTo;
@property (nonatomic, retain) NSSet* edited;
@property (nonatomic, retain) NSSet* illustrated;

+(id) personInManagedObjectContext:(NSManagedObjectContext*)context;

@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addAliasesObject:(Person *)value;
- (void)removeAliasesObject:(Person *)value;
- (void)addAliases:(NSSet *)values;
- (void)removeAliases:(NSSet *)values;

- (void)addAuthoredObject:(Title *)value;
- (void)removeAuthoredObject:(Title *)value;
- (void)addAuthored:(NSSet *)values;
- (void)removeAuthored:(NSSet *)values;

- (void)addContributedToObject:(Title *)value;
- (void)removeContributedToObject:(Title *)value;
- (void)addContributedTo:(NSSet *)values;
- (void)removeContributedTo:(NSSet *)values;

- (void)addEditedObject:(Title *)value;
- (void)removeEditedObject:(Title *)value;
- (void)addEdited:(NSSet *)values;
- (void)removeEdited:(NSSet *)values;

- (void)addIllustratedObject:(Title *)value;
- (void)removeIllustratedObject:(Title *)value;
- (void)addIllustrated:(NSSet *)values;
- (void)removeIllustrated:(NSSet *)values;

@end
