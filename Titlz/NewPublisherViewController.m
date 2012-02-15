//
//  NewPublisherViewController.m
//  Titlz
//
//  Created by David Lains on 1/13/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "NewPublisherViewController.h"
#import "EditableTextCell.h"
#import "Publisher.h"

@interface NewPublisherViewController ()
-(void) showLookupViewControllerForLookupType:(LookupType)type;
@end

@implementation NewPublisherViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;
@synthesize delegate = _delegate;
@synthesize shouldValidate = _shouldValidate;

-(void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void) viewDidLoad
{
    [super viewDidLoad];

    self.shouldValidate = YES;
    
    self.title = NSLocalizedString(@"New Publisher", @"NewPublisherViewController header bar title.");
    self.tableView.backgroundColor = [UIColor colorWithRed:0.93333 green:0.93333 blue:0.93333 alpha:1.0];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
	// Set up the undo manager and set editing state to YES.
	[self setUpUndoManager];
	self.editing = YES;
}

-(void) viewDidUnload
{
    [super viewDidUnload];
	[self cleanUpUndoManager];	
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) setUpUndoManager
{
	/*
	 If the title's managed object context doesn't already have an undo manager, then create one and set it for the context and self.
	 The view controller needs to keep a reference to the undo manager it creates so that it can determine whether to remove the undo manager when editing finishes.
	 */
	if (self.detailItem.managedObjectContext.undoManager == nil)
    {
		NSUndoManager* undoManager = [[NSUndoManager alloc] init];
		[undoManager setLevelsOfUndo:3];
		self.undoManager = undoManager;
		
		self.detailItem.managedObjectContext.undoManager = self.undoManager;
	}
	
	// Register as an observer of the title's context's undo manager.
	NSUndoManager* editionUndoManager = self.detailItem.managedObjectContext.undoManager;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:editionUndoManager];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidRedo:) name:NSUndoManagerDidRedoChangeNotification object:editionUndoManager];
}

-(void) cleanUpUndoManager
{
	// Remove self as an observer.
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    if (self.detailItem.managedObjectContext.undoManager == self.undoManager)
    {
        self.detailItem.managedObjectContext.undoManager = nil;
        self.undoManager = nil;
    }
}

-(BOOL) textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidBeginEditing:(UITextField*)textField
{
    // Save the textField for updating when the selection is made.
    lookupTextField = textField;
    
    switch (textField.tag)
    {
        case PublisherStateRow:
            [textField resignFirstResponder];
            [self showLookupViewControllerForLookupType:LookupTypeState];
            break;
        case PublisherCountryRow:
            [textField resignFirstResponder];
            [self showLookupViewControllerForLookupType:LookupTypeCountry];
            break;
        default:
            break;
    }
}

-(BOOL) textFieldShouldEndEditing:(UITextField*)textField
{
    BOOL valid = YES;
    NSError* error;
    NSString* value = textField.text;
    
    if (self.shouldValidate)
    {
        switch (textField.tag)
        {
            case PublisherNameRow:
                valid = [self.detailItem validateValue:&value forKey:@"name" error:&error];
                break;
            default:
                break;
        }
        
        if (valid)
            [textField resignFirstResponder];
        else
            [ContextUtil displayValidationError:error];
    }
    
    return valid;
}

-(void) textFieldDidEndEditing:(UITextField*)textField
{
    switch (textField.tag)
    {
        case PublisherNameRow:
            self.detailItem.name = textField.text;
            break;
        case PublisherParentRow:
            self.detailItem.parent = textField.text;
            break;
        case PublisherStreetRow:
            self.detailItem.street = textField.text;
            break;
        case PublisherStreet1Row:
            self.detailItem.street1 = textField.text;
            break;
        case PublisherCityRow:
            self.detailItem.city = textField.text;
            break;
        case PublisherStateRow:
            break;
        case PublisherPostalCodeRow:
            self.detailItem.postalCode = textField.text;
            break;
        case PublisherCountryRow:
            break;
        default:
            break;
    }
    
    [self becomeFirstResponder];
}

-(void) lookupViewController:(LookupViewController *)controller didSelectValue:(NSString *)value withLookupType:(LookupType)type
{
    if (value.length > 0)
    {
        switch (type)
        {
            case LookupTypeState:
                self.detailItem.state = value;
                break;
            case LookupTypeCountry:
                self.detailItem.country = value;
                break;
            default:
                DLog(@"Invalid LookupType found in NewPublisherViewController::lookupViewController:didSelectValue:withLookupType: %i.", type);
                break;
        }
        
        lookupTextField.text = value;
    }
    
    [self becomeFirstResponder];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(IBAction) cancel:(id)sender
{
    self.shouldValidate = NO;
    [self.delegate newPublisherViewController:self didFinishWithSave:NO];
}

-(IBAction) save:(id)sender
{
    [self.delegate newPublisherViewController:self didFinishWithSave:YES];
}

#pragma mark - Table view data source

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return PublisherDataSectionRowCount;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    
    if (dummyView == nil)
    {
        dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }

    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.enabled = NO;
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.textField.inputView = nil;
    cell.textField.keyboardType = UIKeyboardTypeDefault;
    cell.textField.text = @"";
    if (self.editing)
        cell.textField.enabled = YES;
    else
        cell.textField.enabled = NO;
    
    switch (indexPath.row)
    {
        case PublisherNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Name", @"NewPublisherViewController name data field label.");
            cell.textField.text = self.detailItem.name;
            cell.textField.tag = PublisherNameRow;
            break;
        case PublisherParentRow:
            cell.fieldLabel.text = NSLocalizedString(@"Parent", @"NewPublisherViewController parent data field label.");
            cell.textField.text = self.detailItem.parent;
            cell.textField.tag = PublisherParentRow;
            break;
        case PublisherStreetRow:
            cell.fieldLabel.text = NSLocalizedString(@"Street", @"NewPublisherViewController street data field label.");
            cell.textField.text = self.detailItem.street;
            cell.textField.tag = PublisherStreetRow;
            break;
        case PublisherStreet1Row:
            cell.fieldLabel.text = NSLocalizedString(@"Street", @"NewPublisherViewController street data field label.");
            cell.textField.text = self.detailItem.street1;
            cell.textField.tag = PublisherStreet1Row;
            break;
        case PublisherCityRow:
            cell.fieldLabel.text = NSLocalizedString(@"City", @"NewPublisherViewController city data field label.");
            cell.textField.text = self.detailItem.city;
            cell.textField.tag = PublisherCityRow;
            break;
        case PublisherStateRow:
            cell.fieldLabel.text = NSLocalizedString(@"State", @"NewPublisherViewController state data field label.");
            cell.textField.text = self.detailItem.state;
            cell.textField.inputView = dummyView;
            cell.textField.tag = PublisherStateRow;
            break;
        case PublisherPostalCodeRow:
            cell.fieldLabel.text = NSLocalizedString(@"Postal Code", @"NewPublisherViewController postalCode data field label.");
            cell.textField.text = self.detailItem.postalCode;
            cell.textField.tag = PublisherPostalCodeRow;
            break;
        case PublisherCountryRow:
            cell.fieldLabel.text = NSLocalizedString(@"Country", @"NewPublisherViewController country data field label.");
            cell.textField.text = self.detailItem.country;
            cell.textField.inputView = dummyView;
            cell.textField.tag = PublisherCountryRow;
            break;
        default:
            break;
    }
    return cell;
}

-(UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewCellEditingStyleNone;
}

-(BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
	return NO;
}

-(void) showLookupViewControllerForLookupType:(LookupType)type
{
    LookupViewController* controller = [[LookupViewController alloc] initWithLookupType:type];
    controller.delegate = self;
    controller.managedObjectContext = self.detailItem.managedObjectContext;
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.navigationBar.barStyle = UIBarStyleBlack;

    [self.navigationController presentModalViewController:navController animated:YES];
}

@end
