//
//  EditionDetailViewController.h
//  Titlz
//
//  Created by David Lains on 1/11/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Edition;

@interface EditionDetailViewController : UITableViewController
{
    UITextField* releaseDateTextField;
}

@property(nonatomic, strong) Edition* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(void) updateRightBarButtonItemState;

@end
