//
//  NewPublisherViewController.h
//  Titlz
//
//  Created by David Lains on 1/13/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LookupViewController.h"

@class Publisher;

@protocol NewPublisherDelegate;

@interface NewPublisherViewController : UITableViewController <LookupValueSelectedDelegate>
{
    UITextField* lookupTextField;
    UIView* dummyView;
}

@property(nonatomic, strong) Publisher* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) id <NewPublisherDelegate> delegate;
@property(nonatomic, assign) BOOL shouldValidate;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(IBAction) cancel:(id)sender;
-(IBAction) save:(id)sender;

@end

@protocol NewPublisherDelegate <NSObject>

-(void) newPublisherViewController:(NewPublisherViewController*)controller didFinishWithSave:(BOOL)save;

@end