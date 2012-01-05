//
//  NewTitleViewController.h
//  Titlz
//
//  Created by David Lains on 1/2/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleDetailViewController.h"

@class Title;

@protocol NewTitleDelegate;

@interface NewTitleViewController : UITableViewController

@property(nonatomic, strong) Title* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) id <NewTitleDelegate> delegate;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(IBAction) cancel:(id)sender;
-(IBAction) save:(id)sender;

@end

@protocol NewTitleDelegate <NSObject>

-(void) newTitleViewController:(NewTitleViewController*)controller didFinishWithSave:(BOOL)save;

@end