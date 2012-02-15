//
//  CollectionDetailViewController.h
//  Titlz
//
//  Created by David Lains on 1/30/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewController.h"

@class Collection;

@interface CollectionDetailViewController : UITableViewController <UITextFieldDelegate, BookSelectedDelegate>
{
    UITextField* lookupTextField;
    UIView* dummyView;
}

@property(nonatomic, strong) Collection* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) BOOL lookupJustFinished;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(void) updateRightBarButtonItemState;

@end
