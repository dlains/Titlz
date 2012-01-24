//
//  NewAwardViewController.h
//  Titlz
//
//  Created by David Lains on 1/19/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Award;

@protocol NewAwardDelegate;

@interface NewAwardViewController : UITableViewController

@property(nonatomic, strong) Award* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) id <NewAwardDelegate> delegate;
@property(nonatomic, assign) BOOL shouldValidate;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(IBAction) cancel:(id)sender;
-(IBAction) save:(id)sender;

@end

@protocol NewAwardDelegate <NSObject>

-(void) newAwardViewController:(NewAwardViewController*)controller didFinishWithSave:(BOOL)save;

@end
