//
//  PublisherViewController.h
//  Titlz
//
//  Created by David Lains on 1/13/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "NewPublisherViewController.h"

@protocol PublisherSelectedDelegate;

@class Publisher;

@class PublisherDetailViewController;

@interface PublisherViewController : UITableViewController <NSFetchedResultsControllerDelegate, NewPublisherDelegate>

@property(nonatomic, strong) PublisherDetailViewController* publisherDetailViewController;

@property(nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property(nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property(nonatomic, assign) id <PublisherSelectedDelegate> delegate;
@property(nonatomic, assign) BOOL selectionMode;

@end

@protocol PublisherSelectedDelegate <NSObject>

-(void) publisherViewController:(PublisherViewController*)controller didSelectPublisher:(Publisher*)publisher;

@end
