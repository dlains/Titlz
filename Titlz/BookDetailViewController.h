//
//  BookDetailViewController.h
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonViewController.h"
#import "PublisherViewController.h"
#import "LookupViewController.h"
#import "SellerViewController.h"
#import "CollectionViewController.h"
#import "NewAwardViewController.h"
#import "NewPointViewController.h"

@class Book;

@interface BookDetailViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PersonSelectedDelegate, PublisherSelectedDelegate, LookupValueSelectedDelegate, SellerSelectedDelegate, CollectionSelectedDelegate, NewAwardDelegate, NewPointDelegate>
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
@property(nonatomic, strong) IBOutlet UITableViewCell* textViewCell;
@property(nonatomic, strong) IBOutlet UILabel* cellLabel;
@property(nonatomic, strong) IBOutlet UITextView* cellTextView;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(void) updateRightBarButtonItemState;

@end
