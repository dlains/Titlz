//
//  NewCollectionViewController.h
//  Titlz
//
//  Created by David Lains on 1/30/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Collection;

@protocol NewCollectionDelegate;

@interface NewCollectionViewController : UITableViewController

@property(nonatomic, strong) Collection* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) id <NewCollectionDelegate> delegate;
@property(nonatomic, assign) BOOL shouldValidate;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(IBAction) cancel:(id)sender;
-(IBAction) save:(id)sender;

@end

@protocol NewCollectionDelegate <NSObject>

-(void) newCollectionViewController:(NewCollectionViewController*)controller didFinishWithSave:(BOOL)save;

@end