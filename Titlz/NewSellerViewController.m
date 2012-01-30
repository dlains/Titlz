//
//  NewSellerViewController.m
//  Titlz
//
//  Created by David Lains on 1/18/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "NewSellerViewController.h"
#import "EditableTextCell.h"
#import "Seller.h"

@interface NewSellerViewController()
-(void) showLookupViewControllerForLookupType:(LookupType)type;
@end

@implementation NewSellerViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;
@synthesize delegate = _delegate;
@synthesize shouldValidate = _shouldValidate;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.shouldValidate = YES;
    
    self.title = NSLocalizedString(@"New Seller", @"NewSellerViewController header bar title.");
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
	// Set up the undo manager and set editing state to YES.
	[self setUpUndoManager];
	self.editing = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[self cleanUpUndoManager];	
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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
	NSUndoManager* sellerUndoManager = self.detailItem.managedObjectContext.undoManager;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:sellerUndoManager];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidRedo:) name:NSUndoManagerDidRedoChangeNotification object:sellerUndoManager];
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
        case SellerStateRow:
            [self showLookupViewControllerForLookupType:LookupTypeState];
            break;
        case SellerCountryRow:
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
            case SellerNameRow:
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
        case SellerNameRow:
            self.detailItem.name = textField.text;
            break;
        case SellerStreetRow:
            self.detailItem.street = textField.text;
            break;
        case SellerStreet1Row:
            self.detailItem.street1 = textField.text;
            break;
        case SellerCityRow:
            self.detailItem.city = textField.text;
            break;
        case SellerStateRow:
            self.detailItem.state = textField.text;
            break;
        case SellerPostalCodeRow:
            self.detailItem.postalCode = textField.text;
            break;
        case SellerCountryRow:
            self.detailItem.country = textField.text;
            break;
        case SellerEmailRow:
            self.detailItem.email = textField.text;
            break;
        case SellerPhoneRow:
            self.detailItem.phone = textField.text;
            break;
        case SellerWebsiteRow:
            self.detailItem.website = textField.text;
            break;
        default:
            break;
    }
    
    [self becomeFirstResponder];
}

-(void) lookupViewController:(LookupViewController *)controller didSelectValue:(NSString *)value withLookupType:(LookupType)type
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
            DLog(@"Invalid LookupType found in NewSellerViewController::lookupViewController:didSelectValue:withLookupType: %i.", type);
            break;
    }
    
    lookupTextField.text = value;
}

-(IBAction) cancel:(id)sender
{
    self.shouldValidate = NO;
    [self.delegate newSellerViewController:self didFinishWithSave:NO];
}

-(IBAction) save:(id)sender
{
    [self.delegate newSellerViewController:self didFinishWithSave:YES];
}

#pragma mark - Table view data source

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return SellerDataSectionRowCount;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    
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
    cell.textField.enabled = NO;
    
    switch (indexPath.row)
    {
        case SellerNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Name", @"NewSellerViewController name data field label.");
            cell.textField.tag = SellerNameRow;
            break;
        case SellerStreetRow:
            cell.fieldLabel.text = NSLocalizedString(@"Street", @"NewSellerViewController street data field label.");
            cell.textField.tag = SellerStreetRow;
            break;
        case SellerStreet1Row:
            cell.fieldLabel.text = NSLocalizedString(@"Street", @"NewSellerViewController street data field label.");
            cell.textField.tag = SellerStreet1Row;
            break;
        case SellerCityRow:
            cell.fieldLabel.text = NSLocalizedString(@"City", @"NewSellerViewController city data field label.");
            cell.textField.tag = SellerCityRow;
            break;
        case SellerStateRow:
            cell.fieldLabel.text = NSLocalizedString(@"State", @"NewSellerViewController state data field label.");
            cell.textField.tag = SellerStateRow;
            break;
        case SellerPostalCodeRow:
            cell.fieldLabel.text = NSLocalizedString(@"Postal Code", @"NewSellerViewController postalCode data field label.");
            cell.textField.tag = SellerPostalCodeRow;
            break;
        case SellerCountryRow:
            cell.fieldLabel.text = NSLocalizedString(@"Country", @"NewSellerViewController country data field label.");
            cell.textField.tag = SellerCountryRow;
            break;
        case SellerEmailRow:
            cell.fieldLabel.text = NSLocalizedString(@"Email", @"NewSellerViewController email data field label.");
            cell.textField.tag = SellerEmailRow;
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        case SellerPhoneRow:
            cell.fieldLabel.text = NSLocalizedString(@"Phone", @"NewSellerViewController phone data field label.");
            cell.textField.tag = SellerPhoneRow;
            cell.textField.keyboardType = UIKeyboardTypePhonePad;
            break;
        case SellerWebsiteRow:
            cell.fieldLabel.text = NSLocalizedString(@"Website", @"NewSellerViewController website data field label.");
            cell.textField.tag = SellerWebsiteRow;
            cell.textField.keyboardType = UIKeyboardTypeURL;
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
    [self.navigationController presentModalViewController:navController animated:YES];
}

@end
