//
//  SellerDetailViewController.h
//  Titlz
//
//  Created by David Lains on 1/18/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LookupViewController.h"

@class Seller;

@interface SellerDetailViewController : UITableViewController <LookupValueSelectedDelegate>
{
    UITextField* lookupTextField;
}

@property(nonatomic, strong) Seller* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(void) updateRightBarButtonItemState;

@end
