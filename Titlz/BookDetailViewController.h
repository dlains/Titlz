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
    UITextField* lookupTextField;
    UILabel* workerLookupLabel;
    UIImageView* thumbnailView;
}

@property(nonatomic, strong) Book* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, assign) BOOL lookupJustFinished;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(void) updateRightBarButtonItemState;

@end
