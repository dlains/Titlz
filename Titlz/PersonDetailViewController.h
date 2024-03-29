//
//  PersonDetailViewController.h
//  Titlz
//
//  Created by David Lains on 1/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewController.h"
#import "LookupViewController.h"

@class Person;

@interface PersonDetailViewController : UITableViewController <UITextFieldDelegate, BookSelectedDelegate, PersonSelectedDelegate, LookupValueSelectedDelegate>
{
    UITextField* bornTextField;
    UITextField* diedTextField;
    UITextField* lookupTextField;
    UILabel* workerLookupLabel;
    
    UIDatePicker* bornDatePicker;
    UIDatePicker* diedDatePicker;
    NSDateFormatter* dateFormatter;
    UIView* dummyView;
}

@property(nonatomic, strong) Person* detailItem;
@property(nonatomic, assign) NSInteger personTypeBeingAdded;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) BOOL lookupJustFinished;
@property(nonatomic, assign) BOOL allowDrilldown;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(void) updateRightBarButtonItemState;

@end
