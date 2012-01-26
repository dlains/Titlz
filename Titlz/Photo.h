//
//  Photo.h
//  Titlz
//
//  Created by David Lains on 1/24/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Photo : NSManagedObject

@property(nonatomic, retain) UIImage* image;
@property(nonatomic, retain) Book* book;

+(id) photoInManagedObjectContext:(NSManagedObjectContext*)context;

@end
