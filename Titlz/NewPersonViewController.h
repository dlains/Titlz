//
//  NewPersonViewController.h
//  Titlz
//
//  Created by David Lains on 1/4/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Person;

@protocol NewPersonDelegate;

@interface NewPersonViewController : UITableViewController
{
    UITextField* bornTextField;
    UITextField* diedTextField;
    
    UIDatePicker* bornDatePicker;
    UIDatePicker* diedDatePicker;
    NSDateFormatter* dateFormatter;
    UIView* dummyView;
}

@property(nonatomic, strong) Person* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) id <NewPersonDelegate> delegate;
@property(nonatomic, assign) BOOL shouldValidate;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(IBAction) cancel:(id)sender;
-(IBAction) save:(id)sender;

@end

@protocol NewPersonDelegate <NSObject>

-(void) newPersonViewController:(NewPersonViewController*)controller didFinishWithSave:(BOOL)save;

@end