//
//  BookDetailViewController.h
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonViewController.h"
#import "PublisherViewController.h"
#import "LookupViewController.h"

@class Book;

@interface BookDetailViewController : UITableViewController <PersonSelectedDelegate, PublisherSelectedDelegate, LookupValueSelectedDelegate>
{
    UITextField* releaseDateTextField;
    UITextField* purchaseDateTextField;
    UITextField* lookupTextField;
}

@property(nonatomic, strong) Book* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, strong) NSManagedObjectContext* managedObjectContext;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(void) updateRightBarButtonItemState;

@end
