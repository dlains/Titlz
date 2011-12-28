//
//  TitleViewController.h
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class TitleDetailViewController;

@interface TitleViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) TitleDetailViewController* titleDetailViewController;

@property(nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property(nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@end
