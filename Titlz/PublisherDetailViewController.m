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
@end

@implementation PublisherDetailViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;

#pragma mark - Initialization

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Publisher", @"PublisherDetailViewController header bar title.");
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
	NSUndoManager* titleUndoManager = self.detailItem.managedObjectContext.undoManager;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:titleUndoManager];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidRedo:) name:NSUndoManagerDidRedoChangeNotification object:titleUndoManager];
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
            self.detailItem.state = textField.text;
            break;
        case PublisherPostalCodeRow:
            self.detailItem.postalCode = textField.text;
            break;
        case PublisherCountryRow:
            self.detailItem.country = textField.text;
            break;
        default:
            break;
    }
    
    [self becomeFirstResponder];
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
        [ContextSaver saveContext:self.detailItem.managedObjectContext];
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
            DLog(@"Invalid PublisherDetailViewController section found: %i.", indexPath.section);
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
            DLog(@"Invalid PublisherDetailViewController section found: %i.", indexPath.section);
            return UITableViewCellEditingStyleNone;
    }
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case PublisherDataSection:
            break;
        case PublisherBooksSection:
            [self loadBookDetailViewForBookAtIndexPath:indexPath];
            break;
        default:
            DLog(@"Invalid PublisherDetailViewController section found: %i.", indexPath.section);
            break;
    }
}

// Section headers.
-(NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* header = nil;
    
    switch (section)
    {
        case PublisherDataSection:
            break;
        case PublisherBooksSection:
            if (self.detailItem.books.count > 0)
            {
                header = NSLocalizedString(@"Published Books", @"PublisherDetailViewController Books section header.");
            }
            break;
        default:
            DLog(@"Invalid SellerDetailViewController section found: %i.", section);
            break;
    }
    
    return header;
}

-(UITableViewCell*) configureDataCellForRow:(NSInteger)row
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    
    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.enabled = NO;
    }
    
    switch (row)
    {
        case PublisherNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Name", @"PublisherDetailViewController name data field label.");
            cell.textField.text = self.detailItem.name;
            cell.textField.tag = PublisherNameRow;
            break;
        case PublisherParentRow:
            cell.fieldLabel.text = NSLocalizedString(@"Parent", @"PublisherDetailViewController parent data field label.");
            cell.textField.text = self.detailItem.parent;
            cell.textField.tag = PublisherParentRow;
            break;
        case PublisherStreetRow:
            cell.fieldLabel.text = NSLocalizedString(@"Street", @"PublisherDetailViewController street data field label.");
            cell.textField.text = self.detailItem.street;
            cell.textField.tag = PublisherStreetRow;
            break;
        case PublisherStreet1Row:
            cell.fieldLabel.text = NSLocalizedString(@"Street", @"PublisherDetailViewController street data field label.");
            cell.textField.text = self.detailItem.street1;
            cell.textField.tag = PublisherStreet1Row;
            break;
        case PublisherCityRow:
            cell.fieldLabel.text = NSLocalizedString(@"City", @"PublisherDetailViewController city data field label.");
            cell.textField.text = self.detailItem.city;
            cell.textField.tag = PublisherCityRow;
            break;
        case PublisherStateRow:
            cell.fieldLabel.text = NSLocalizedString(@"State", @"PublisherDetailViewController state data field label.");
            cell.textField.text = self.detailItem.state;
            cell.textField.tag = PublisherStateRow;
            break;
        case PublisherPostalCodeRow:
            cell.fieldLabel.text = NSLocalizedString(@"Postal Code", @"PublisherDetailViewController postalCode data field label.");
            cell.textField.text = self.detailItem.postalCode;
            cell.textField.tag = PublisherPostalCodeRow;
            break;
        case PublisherCountryRow:
            cell.fieldLabel.text = NSLocalizedString(@"Country", @"PublisherDetailViewController country data field label.");
            cell.textField.text = self.detailItem.country;
            cell.textField.tag = PublisherCountryRow;
            break;
        default:
            break;
    }
    
    return cell;
}

-(UITableViewCell*) configureBooksCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"BooksCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Book* book = [self sortedBookFromSet:self.detailItem.books atIndexPath:indexPath];
    cell.textLabel.text = book.title;
    
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

@end
