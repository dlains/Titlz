//
//  NewBookViewController.h
//  Titlz
//
//  Created by David Lains on 1/2/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookDetailViewController.h"
#import "PersonViewController.h"
#import "PublisherViewController.h"
#import "LookupViewController.h"
#import "SellerViewController.h"
#import "CollectionViewController.h"
#import "NewAwardViewController.h"
#import "NewPointViewController.h"

@class Book;

@protocol NewBookDelegate;

@interface NewBookViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PersonSelectedDelegate, PublisherSelectedDelegate, LookupValueSelectedDelegate, SellerSelectedDelegate, CollectionSelectedDelegate, NewAwardDelegate, NewPointDelegate>
{
    UITextField* releaseDateTextField;
    UITextField* purchaseDateTextField;
    UITextField* lastReadDateTextField;
    UITextField* lookupTextField;
    UILabel* workerLookupLabel;
    UIImageView* thumbnailView;
    
    UIDatePicker* releaseDatePicker;
    UIDatePicker* purchaseDatePicker;
    UIDatePicker* lastReadDatePicker;
    NSDateFormatter* dateFormatter;
    UIView* dummyView;
}

@property(nonatomic, strong) Book* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) id <NewBookDelegate> delegate;
@property(nonatomic, assign) BOOL shouldValidate;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(IBAction) cancel:(id)sender;
-(IBAction) save:(id)sender;

@end

@protocol NewBookDelegate <NSObject>

-(void) newBookViewController:(NewBookViewController*)controller didFinishWithSave:(BOOL)save;

@end