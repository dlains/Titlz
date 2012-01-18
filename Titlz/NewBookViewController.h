//
//  NewBookViewController.h
//  Titlz
//
//  Created by David Lains on 1/2/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookDetailViewController.h"

@class Book;

@protocol NewBookDelegate;

@interface NewBookViewController : UITableViewController
{
    UITextField* releaseDateTextField;
    UITextField* purchaseDateTextField;
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