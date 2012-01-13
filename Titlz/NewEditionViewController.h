//
//  NewEditionViewController.h
//  Titlz
//
//  Created by David Lains on 1/11/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Edition;

@protocol NewEditionDelegate;

@interface NewEditionViewController : UITableViewController
{
    UITextField* releaseDateTextField;
}

@property(nonatomic, strong) Edition* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) id <NewEditionDelegate> delegate;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(IBAction) cancel:(id)sender;
-(IBAction) save:(id)sender;

@end

@protocol NewEditionDelegate <NSObject>

-(void) newEditionViewController:(NewEditionViewController*)controller didFinishWithSave:(BOOL)save;

@end