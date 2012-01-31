//
//  CollectionViewController.h
//  Titlz
//
//  Created by David Lains on 1/30/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NewCollectionViewController.h"

@protocol CollectionSelectedDelegate;

@interface CollectionViewController : UITableViewController <NSFetchedResultsControllerDelegate, NewCollectionDelegate>

@property(nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property(nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property(nonatomic, assign) id <CollectionSelectedDelegate> delegate;
@property(nonatomic, assign) BOOL selectionMode;

@end

@protocol CollectionSelectedDelegate <NSObject>

-(void) collectionViewController:(CollectionViewController*)controller didSelectCollection:(Collection*)collection;

@end
