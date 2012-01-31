//
//  Collection.h
//  Titlz
//
//  Created by David Lains on 1/30/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Collection : NSManagedObject

@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSSet* books;
@end

@interface Collection (CoreDataGeneratedAccessors)

-(void) addBooksObject:(Book*)value;
-(void) removeBooksObject:(Book*)value;
-(void) addBooks:(NSSet*)values;
-(void) removeBooks:(NSSet*)values;

+(id) collectionInManagedObjectContext:(NSManagedObjectContext*)context;

@end
