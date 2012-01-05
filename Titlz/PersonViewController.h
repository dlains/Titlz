//
//  PersonViewController.h
//  Titlz
//
//  Created by David Lains on 1/4/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "NewPersonViewController.h"

typedef enum PersonTypeEnum
{
    Author = 0,
    Editor,
    Illustrator,
    Contributor,
} PersonType;

@protocol AuthorSelectedDelegate;

@class PersonDetailViewController;

@interface PersonViewController : UITableViewController <NSFetchedResultsControllerDelegate, NewPersonDelegate>

@property(nonatomic, strong) PersonDetailViewController* personDetailViewController;

@property(nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property(nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property(nonatomic, retain) NSManagedObjectContext *addingManagedObjectContext;
@property(nonatomic, assign) id <AuthorSelectedDelegate> delegate;
@property(nonatomic, assign) BOOL selectionMode;
@property(nonatomic, assign) PersonType personSelectionType;

@end

@protocol AuthorSelectedDelegate <NSObject>

-(void) personViewController:(PersonViewController*)controller didSelectAuthor:(Person*)author;

@end