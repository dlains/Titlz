//
//  BookViewController.h
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "NewBookViewController.h"

@protocol BookSelectedDelegate;

@class BookDetailViewController;

@interface BookViewController : UITableViewController <NSFetchedResultsControllerDelegate, NewBookDelegate>

@property(nonatomic, strong) BookDetailViewController* bookDetailViewController;

@property(nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property(nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property(nonatomic, retain) NSManagedObjectContext *addingManagedObjectContext;
@property(nonatomic, assign) id <BookSelectedDelegate> delegate;
@property(nonatomic, assign) BOOL selectionMode;
@property(nonatomic, assign) PersonType personSelectionType;

@end

@protocol BookSelectedDelegate <NSObject>

-(void) bookViewController:(BookViewController*)controller didSelectBook:(Book*)book forPersonType:(PersonType)type;

@end