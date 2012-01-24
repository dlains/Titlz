//
//  ContextUtil.h
//  Titlz
//
//  Created by David Lains on 1/20/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContextUtil : NSObject

+(BOOL) saveContext:(NSManagedObjectContext*)context;
+(void) displayValidationError:(NSError*)error;

@end
