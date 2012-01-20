//
//  PointDetailViewController.h
//  Titlz
//
//  Created by David Lains on 1/19/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLPoint;

@interface PointDetailViewController : UITableViewController

@property(nonatomic, strong) DLPoint* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(void) updateRightBarButtonItemState;

@end
