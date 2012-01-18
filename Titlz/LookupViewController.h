//
//  LookupViewController.h
//  Titlz
//
//  Created by David Lains on 1/18/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "NewLookupViewController.h"

@protocol LookupValueSelectedDelegate;

@interface LookupViewController : UITableViewController <NSFetchedResultsControllerDelegate, NewLookupDelegate>

@property(nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property(nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property(nonatomic, assign) id <LookupValueSelectedDelegate> delegate;
@property(nonatomic, assign) LookupType selectedLookupType;

-(id) initWithLookupType:(LookupType)type;

@end

@protocol LookupValueSelectedDelegate <NSObject>

-(void) lookupViewController:(LookupViewController*)controller didSelectValue:(NSString*)value withLookupType:(LookupType)type;

@end
