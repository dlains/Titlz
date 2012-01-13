//
//  Book.h
//  Titlz
//
//  Created by David Lains on 1/12/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Edition, Title;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSString* comments;
@property (nonatomic, retain) NSString* condition;
@property (nonatomic, retain) NSDecimalNumber* currentValue;
@property (nonatomic, retain) NSString* jacketCondition;
@property (nonatomic, retain) NSString* number;
@property (nonatomic, retain) NSDecimalNumber* originalPrice;
@property (nonatomic, retain) NSDecimalNumber* pricePaid;
@property (nonatomic, retain) NSString* printing;
@property (nonatomic, retain) NSNumber* signiture;
@property (nonatomic, retain) NSDate* read;
@property (nonatomic, retain) NSManagedObject* boughtFrom;
@property (nonatomic, retain) Edition* edition;
@property (nonatomic, retain) Title* title;

+(id) bookInManagedObjectContext:(NSManagedObjectContext*)context;

@end
