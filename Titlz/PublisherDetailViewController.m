//
//  PublisherDetailViewController.m
//  Titlz
//
//  Created by David Lains on 1/13/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "PublisherDetailViewController.h"
#import "BookDetailViewController.h"
#import "EditableTextCell.h"
#import "Publisher.h"
#import "Book.h"

@interface PublisherDetailViewController ()
-(UITableViewCell*) configureDataCellForRow:(NSInteger)row;
-(UITableViewCell*) configureBooksCellAtIndexPath:(NSIndexPath*)indexPath;
-(void) loadBookDetailViewForBookAtIndexPath:(NSIndexPath*)indexPath;
-(Book*) sortedBookFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(void) showLookupViewControllerForLookupType:(LookupType)type;
@end

@implementation PublisherDetailViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;
@synthesize allowDrilldown = _allowDrilldown;

#pragma mark - Initialization

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Publisher", @"PublisherDetailViewController header bar title.");
        self.allowDrilldown = YES;
    }
    return self;
}

-(void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    self.detailItem = nil;
}

#pragma mark - View lifecycle

-(void) viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewDidUnload
{
    [super viewDidUnload];

    self.detailItem = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.93333 green:0.93333 blue:0.93333 alpha:1.0];
    [self.tableView reloadData];
}

/*
 The view controller must be first responder in order to be able to receive shake events for undo. It should resign first responder status when it disappears.
 */
-(BOOL) canBecomeFirstResponder
{
    return YES;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
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

-(void) updateRightBarButtonItemState
{
	// Conditionally enable the right bar button item -- it should only be enabled if the title is in a valid state for saving.
    self.navigationItem.rightBarButtonItem.enabled = [self.detailItem validateForUpdate:NULL];
}

#pragma mark - Undo Support

-(void) setUpUndoManager
{
	/*
	 If the managed object context doesn't already have an undo manager, then create one and set it for the context and self.
	 The view controller needs to keep a reference to the undo manager it creates so that it can determine whether to remove the undo manager when editing finishes.
	 */
	if (self.detailItem.managedObjectContext.undoManager == nil)
    {
		NSUndoManager* undoManager = [[NSUndoManager alloc] init];
		[undoManager setLevelsOfUndo:3];
		self.undoManager = undoManager;
		
		self.detailItem.managedObjectContext.undoManager = self.undoManager;
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:self.detailItem.managedObjectContext.undoManager];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidRedo:) name:NSUndoManagerDidRedoChangeNotification object:self.detailItem.managedObjectContext.undoManager];
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

-(NSUndoManager*) undoManager
{
    return [[self.detailItem managedObjectContext] undoManager];
}

-(void) undoManagerDidUndo:(NSNotification*)notification
{
    [self.tableView reloadData];
	[self updateRightBarButtonItemState];
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
        case PublisherStateTag:
            [self showLookupViewControllerForLookupType:LookupTypeState];
            break;
        case PublisherCountryTag:
            [self showLookupViewControllerForLookupType:LookupTypeCountry];
            break;
        case PublisherBookTag:
            [textField resignFirstResponder];
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
    
    switch (textField.tag)
    {
        case PublisherNameTag:
            valid = [self.detailItem validateValue:&value forKey:@"name" error:&error];
            break;
        default:
            break;
    }
    
    if (valid)
        [textField resignFirstResponder];
    else
        [ContextUtil displayValidationError:error];
    
    return valid;
}

-(void) textFieldDidEndEditing:(UITextField*)textField
{
    switch (textField.tag)
    {
        case PublisherNameTag:
            self.detailItem.name = textField.text;
            break;
        case PublisherParentTag:
            self.detailItem.parent = textField.text;
            break;
        case PublisherStreetTag:
            self.detailItem.street = textField.text;
            break;
        case PublisherStreet1Tag:
            self.detailItem.street1 = textField.text;
            break;
        case PublisherCityTag:
            self.detailItem.city = textField.text;
            break;
        case PublisherStateTag:
            self.detailItem.state = textField.text;
            break;
        case PublisherPostalCodeTag:
            self.detailItem.postalCode = textField.text;
            break;
        case PublisherCountryTag:
            self.detailItem.country = textField.text;
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
                NSLog(@"Invalid LookupType found in PublisherDetailViewController::lookupViewController:didSelectValue:withLookupType: %i.", type);
                break;
        }
        
        lookupTextField.text = value;
    }

    [self becomeFirstResponder];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
	// Hide the back button when editing starts, and show it again when editing finishes.
    [self.navigationItem setHidesBackButton:editing animated:animated];
    
    if (editing)
    {
        [self setUpUndoManager];
    }
    else
    {
		[self cleanUpUndoManager];
		// Save the changes.
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
        [self.tableView reloadData];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return PublisherDetailSectionCount;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case PublisherDataSection:
            return PublisherDataSectionRowCount;
        case PublisherBooksSection:
            return self.detailItem.books.count;
        default:
            return 0;
    }
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section)
    {
        case PublisherDataSection:
            cell = [self configureDataCellForRow:indexPath.row];
            break;
        case PublisherBooksSection:
            cell = [self configureBooksCellAtIndexPath:indexPath];
            break;
        default:
            NSLog(@"Invalid PublisherDetailViewController section found: %i.", indexPath.section);
            break;
    }
    
    return cell;
}

// Editing styles per row.
-(UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case PublisherDataSection:
            return UITableViewCellEditingStyleNone;
        case PublisherBooksSection:
            return UITableViewCellEditingStyleNone;
        default:
            NSLog(@"Invalid PublisherDetailViewController section found: %i.", indexPath.section);
            return UITableViewCellEditingStyleNone;
    }
}

#pragma mark - Table view delegate

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.allowDrilldown == NO)
        return;

    switch (indexPath.section)
    {
        case PublisherDataSection:
            break;
        case PublisherBooksSection:
            [self loadBookDetailViewForBookAtIndexPath:indexPath];
            break;
        default:
            NSLog(@"Invalid PublisherDetailViewController section found: %i.", indexPath.section);
            break;
    }
}

-(BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
    return NO;
}

-(UITableViewCell*) configureDataCellForRow:(NSInteger)row
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
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.textField.inputView = nil;
    cell.textField.keyboardType = UIKeyboardTypeDefault;
    cell.textField.text = @"";
    if (self.editing)
        cell.textField.enabled = YES;
    else
        cell.textField.enabled = NO;

    switch (row)
    {
        case PublisherNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Name", @"PublisherDetailViewController name data field label.");
            cell.textField.text = self.detailItem.name;
            cell.textField.tag = PublisherNameTag;
            break;
        case PublisherParentRow:
            cell.fieldLabel.text = NSLocalizedString(@"Parent", @"PublisherDetailViewController parent data field label.");
            cell.textField.text = self.detailItem.parent;
            cell.textField.tag = PublisherParentTag;
            break;
        case PublisherStreetRow:
            cell.fieldLabel.text = NSLocalizedString(@"Street", @"PublisherDetailViewController street data field label.");
            cell.textField.text = self.detailItem.street;
            cell.textField.tag = PublisherStreetTag;
            break;
        case PublisherStreet1Row:
            cell.fieldLabel.text = NSLocalizedString(@"Street", @"PublisherDetailViewController street data field label.");
            cell.textField.text = self.detailItem.street1;
            cell.textField.tag = PublisherStreet1Tag;
            break;
        case PublisherCityRow:
            cell.fieldLabel.text = NSLocalizedString(@"City", @"PublisherDetailViewController city data field label.");
            cell.textField.text = self.detailItem.city;
            cell.textField.tag = PublisherCityTag;
            break;
        case PublisherStateRow:
            cell.fieldLabel.text = NSLocalizedString(@"State", @"PublisherDetailViewController state data field label.");
            cell.textField.text = self.detailItem.state;
            cell.textField.inputView = dummyView;
            cell.textField.tag = PublisherStateTag;
            break;
        case PublisherPostalCodeRow:
            cell.fieldLabel.text = NSLocalizedString(@"Postal Code", @"PublisherDetailViewController postalCode data field label.");
            cell.textField.text = self.detailItem.postalCode;
            cell.textField.tag = PublisherPostalCodeTag;
            break;
        case PublisherCountryRow:
            cell.fieldLabel.text = NSLocalizedString(@"Country", @"PublisherDetailViewController country data field label.");
            cell.textField.text = self.detailItem.country;
            cell.textField.inputView = dummyView;
            cell.textField.tag = PublisherCountryTag;
            break;
        default:
            break;
    }
    
    return cell;
}

-(UITableViewCell*) configureBooksCellAtIndexPath:(NSIndexPath*)indexPath
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
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.fieldLabel.text = NSLocalizedString(@"Published", @"PublisherDetailViewController published cell field label text.");
    cell.textField.delegate = self;
    cell.textField.text = @"";
    cell.textField.inputView = dummyView;
    cell.textField.tag = PublisherBookTag;
    if (self.editing)
        cell.textField.enabled = YES;
    else
        cell.textField.enabled = NO;
    
    Book* book = [self sortedBookFromSet:self.detailItem.books atIndexPath:indexPath];
    
    if (book != nil)
    {
        cell.textField.text = book.title;
    }
    
    return cell;
}

#pragma mark - Local Helper Methods

-(Book*) sortedBookFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedBooks = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedBooks objectAtIndex:indexPath.row];
}

-(void) loadBookDetailViewForBookAtIndexPath:(NSIndexPath*)indexPath
{
    Book* selectedBook = [self sortedBookFromSet:self.detailItem.books atIndexPath:indexPath];
    
    if (selectedBook)
    {
        BookDetailViewController* bookDetailViewController = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
        bookDetailViewController.detailItem = selectedBook;
        [self.navigationController pushViewController:bookDetailViewController animated:YES];
    }
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
