//
//  OpenLibraryLookupViewController.h
//  Titlz
//
//  Created by David Lains on 2/14/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenLibrarySearch.h"
#import "NewBookViewController.h"

@interface OpenLibraryLookupViewController : UIViewController <UITextFieldDelegate, OpenLibrarySearchDelegate, NewBookDelegate>

@property(nonatomic, strong) IBOutlet UITextField* searchTextField;
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;
@property(nonatomic, strong) IBOutlet UIButton* searchButton;
@property(nonatomic, strong) IBOutlet UIButton* cancelButton;
@property(nonatomic, strong) IBOutlet UILabel* resultLabel;

@property(nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@property(nonatomic, strong) OpenLibrarySearch* openLibrarySearch;

-(IBAction) searchButtonPressed:(id)sender;
-(IBAction) cancelButtonPressed:(id)sender;

@end
