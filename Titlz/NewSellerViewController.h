//
//  NewSellerViewController.h
//  Titlz
//
//  Created by David Lains on 1/18/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Seller;

@protocol NewSellerDelegate;

@interface NewSellerViewController : UITableViewController

@property(nonatomic, strong) Seller* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) id <NewSellerDelegate> delegate;
@property(nonatomic, assign) BOOL shouldValidate;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(IBAction) cancel:(id)sender;
-(IBAction) save:(id)sender;

@end

@protocol NewSellerDelegate <NSObject>

-(void) newSellerViewController:(NewSellerViewController*)controller didFinishWithSave:(BOOL)save;

@end
