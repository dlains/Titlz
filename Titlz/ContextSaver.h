//
//  ContextSaver.h
//  Titlz
//
//  Created by David Lains on 1/20/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContextSaver : NSObject <UIAlertViewDelegate>

+(void) saveContext:(NSManagedObjectContext*)context;

@end
