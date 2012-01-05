//
//  TitleViewController.h
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "NewTitleViewController.h"

@class TitleDetailViewController;

@interface TitleViewController : UITableViewController <NSFetchedResultsControllerDelegate, NewTitleDelegate>

@property(nonatomic, strong) TitleDetailViewController* titleDetailViewController;

@property(nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property(nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property(nonatomic, retain) NSManagedObjectContext *addingManagedObjectContext;

@end
