//
//  Person.h
//  Titlz
//
//  Created by David Lains on 1/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person, Book, Worker;

@interface Person : NSManagedObject

@property(nonatomic, retain) NSDate* born;
@property(nonatomic, retain) NSDate* died;
@property(nonatomic, readonly) NSString* firstLetterOfName;
@property(nonatomic, retain) NSString* firstName;
@property(nonatomic, retain) NSString* lastName;
@property(nonatomic, retain) NSString* middleName;
@property(nonatomic, retain) NSSet* aliases;
@property(nonatomic, retain) Person* aliasOf;
@property(nonatomic, retain) NSSet* worked;
@property(nonatomic, retain) NSSet* booksSigned;

// Transient properties.
@property (nonatomic, readonly) NSString* fullName;

+(id) personInManagedObjectContext:(NSManagedObjectContext*)context;
+(Person*) findPersonInContext:(NSManagedObjectContext*)context withFirstName:(NSString*)firstName middleName:(NSString*)middleName andLastName:(NSString*)lastName;
+(Person*) findPersonInContext:(NSManagedObjectContext*)context withFirstName:(NSString*)firstName andLastName:(NSString*)lastName;
+(Person*) findPersonInContext:(NSManagedObjectContext*)context withLastName:(NSString*)lastName;

@end

@interface Person (CoreDataGeneratedAccessors)

-(void) addAliasesObject:(Person *)value;
-(void) removeAliasesObject:(Person *)value;
-(void) addAliases:(NSSet *)values;
-(void) removeAliases:(NSSet *)values;

-(void) addWorkedObject:(Worker*)value;
-(void) removeWorkedObject:(Worker*)value;
-(void) addWorked:(NSSet*)values;
-(void) removeWorked:(NSSet*)values;

-(void) addBooksSignedObject:(Book*)value;
-(void) removeBooksSignedObject:(Book*)value;
-(void) addBooksSigned:(NSSet*)values;
-(void) removeBooksSigned:(NSSet*)values;

@end
