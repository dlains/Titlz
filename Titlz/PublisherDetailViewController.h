//
//  PublisherDetailViewController.h
//  Titlz
//
//  Created by David Lains on 1/13/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LookupViewController.h"

@class Publisher;

@interface PublisherDetailViewController : UITableViewController <UITextFieldDelegate, LookupValueSelectedDelegate>
{
    UITextField* lookupTextField;
    UIView* dummyView;
}

@property(nonatomic, strong) Publisher* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(void) updateRightBarButtonItemState;

@end
