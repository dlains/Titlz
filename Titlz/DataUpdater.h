//
//  DataUpdater.h
//  Titlz
//
//  Created by David Lains on 7/12/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataUpdater : NSObject

-(void) fixSortableTitlesInContext:(NSManagedObjectContext*)context;

@end
