//
//  NewLookupViewController.h
//  Titlz
//
//  Created by David Lains on 1/18/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewLookupDelegate;

@class Lookup;

@interface NewLookupViewController : UITableViewController

@property(nonatomic, strong) Lookup* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) id <NewLookupDelegate> delegate;
@property(nonatomic, assign) LookupType selectedLookupType;
@property(nonatomic, assign) NSInteger order;
@property(nonatomic, assign) BOOL shouldValidate;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(IBAction) cancel:(id)sender;
-(IBAction) save:(id)sender;

@end

@protocol NewLookupDelegate <NSObject>

-(void) newLookupViewController:(NewLookupViewController*)controller didFinishWithSave:(BOOL)save;

@end