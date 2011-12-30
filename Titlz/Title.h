//
//  Title.h
//  Titlz
//
//  Created by David Lains on 12/27/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Title : NSManagedObject

@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSSet* authors;
@property(nonatomic, retain) NSSet* books;
@property(nonatomic, retain) NSSet* collections;
@property(nonatomic, retain) NSSet* contributors;
@property(nonatomic, retain) NSSet* editions;
@property(nonatomic, retain) NSSet* editors;
@property(nonatomic, retain) NSSet* illustrators;

+(id) titleInManagedObjectContext:(NSManagedObjectContext*)context;

@end

@interface Title (CoreDataGeneratedAccessors)

-(void) addAuthorsObject:(NSManagedObject*)value;
-(void) removeAuthorsObject:(NSManagedObject*)value;
-(void) addAuthors:(NSSet*)values;
-(void) removeAuthors:(NSSet*)values;

-(void) addBooksObject:(NSManagedObject*)value;
-(void) removeBooksObject:(NSManagedObject*)value;
-(void) addBooks:(NSSet*)values;
-(void) removeBooks:(NSSet*)values;

-(void) addCollectionsObject:(NSManagedObject*)value;
-(void) removeCollectionsObject:(NSManagedObject*)value;
-(void) addCollections:(NSSet*)values;
-(void) removeCollections:(NSSet*)values;

-(void) addContributorsObject:(NSManagedObject*)value;
-(void) removeContributorsObject:(NSManagedObject*)value;
-(void) addContributors:(NSSet*)values;
-(void) removeContributors:(NSSet*)values;

-(void) addEditionsObject:(NSManagedObject*)value;
-(void) removeEditionsObject:(NSManagedObject*)value;
-(void) addEditions:(NSSet*)values;
-(void) removeEditions:(NSSet*)values;

-(void) addEditorsObject:(NSManagedObject*)value;
-(void) removeEditorsObject:(NSManagedObject*)value;
-(void) addEditors:(NSSet*)values;
-(void) removeEditors:(NSSet*)values;

-(void) addIllustratorsObject:(NSManagedObject*)value;
-(void) removeIllustratorsObject:(NSManagedObject*)value;
-(void) addIllustrators:(NSSet*)values;
-(void) removeIllustrators:(NSSet*)values;

@end
