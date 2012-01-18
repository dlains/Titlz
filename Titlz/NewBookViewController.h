//
//  NewBookViewController.h
//  Titlz
//
//  Created by David Lains on 1/2/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookDetailViewController.h"
#import "LookupViewController.h"

@class Book;

@protocol NewBookDelegate;

@interface NewBookViewController : UITableViewController <LookupValueSelectedDelegate>
{
    UITextField* releaseDateTextField;
    UITextField* purchaseDateTextField;
    UITextField* lookupTextField;
}

@property(nonatomic, strong) Book* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) id <NewBookDelegate> delegate;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(IBAction) cancel:(id)sender;
-(IBAction) save:(id)sender;

@end

@protocol NewBookDelegate <NSObject>

-(void) newBookViewController:(NewBookViewController*)controller didFinishWithSave:(BOOL)save;

@end