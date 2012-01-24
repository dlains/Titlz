//
//  NewPointViewController.h
//  Titlz
//
//  Created by David Lains on 1/19/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLPoint;

@protocol NewPointDelegate;

@interface NewPointViewController : UITableViewController

@property(nonatomic, strong) DLPoint* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) id <NewPointDelegate> delegate;
@property(nonatomic, assign) BOOL shouldValidate;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(IBAction) cancel:(id)sender;
-(IBAction) save:(id)sender;

@end

@protocol NewPointDelegate <NSObject>

-(void) newPointViewController:(NewPointViewController*)controller didFinishWithSave:(BOOL)save;

@end
