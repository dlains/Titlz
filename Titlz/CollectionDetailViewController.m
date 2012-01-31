//
//  CollectionDetailViewController.m
//  Titlz
//
//  Created by David Lains on 1/30/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "CollectionDetailViewController.h"
#import "BookViewController.h"
#import "BookDetailViewController.h"
#import "EditableTextCell.h"
#import "Collection.h"
#import "Book.h"

@interface CollectionDetailViewController ()
-(UITableViewCell*) configureDataCellForRow:(NSInteger)row;
-(UITableViewCell*) configureBookCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection;
-(Book*) sortedBookFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath;
-(void) loadBookView;
-(void) loadBookDetailViewForBookAtIndexPath:(NSIndexPath*)indexPath;
@end

@implementation CollectionDetailViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;

#pragma mark - Initialization

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Collection", @"CollectionDetailViewController header bar title.");
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:self.detailItem.managedObjectContext.undoManager];
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

-(BOOL) textFieldShouldEndEditing:(UITextField*)textField
{
    BOOL valid = YES;
    NSError* error;
    NSString* value = textField.text;
    
    switch (textField.tag)
    {
        case CollectionNameRow:
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
        case CollectionNameRow:
            self.detailItem.name = textField.text;
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
    
    NSIndexPath* books = [NSIndexPath indexPathForRow:self.detailItem.books.count inSection:CollectionBookSection];
    
    NSArray* paths = [NSArray arrayWithObjects:books, nil];

    if (editing)
    {
        [self setUpUndoManager];
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationRight];
    }
    else
    {
		[self cleanUpUndoManager];
		// Save the changes.
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
        [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return CollectionDetailSectionCount;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger insertionRow = 0;
    
    // If the table is in editing mode add one row for inserting new records to most of the sections.
    if(self.editing)
        insertionRow = 1;
    
    switch (section)
    {
        case CollectionDataSection:
            return CollectionDataSectionRowCount;
        case CollectionBookSection:
            return self.detailItem.books.count + insertionRow;
        default:
            return 0;
    }
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section)
    {
        case CollectionDataSection:
            cell = [self configureDataCellForRow:indexPath.row];
            break;
        case CollectionBookSection:
            cell = [self configureBookCellAtIndexPath:indexPath];
            break;
        default:
            DLog(@"Invalid PersonDetailViewController section found: %i.", indexPath.section);
            break;
    }
    
    return cell;
}

// Editing styles per row.
-(UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case CollectionDataSection:
            return UITableViewCellEditingStyleNone;
        case CollectionBookSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.books];
        default:
            DLog(@"Invalid CollectionDetailViewController section found: %i.", indexPath.section);
            return UITableViewCellEditingStyleNone;
    }
}

-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection
{
    // The last row should be the insert style, all others should be delete.
    if(collection.count == 0 || row == collection.count)
        return UITableViewCellEditingStyleInsert;
    else
        return UITableViewCellEditingStyleDelete;
}

#pragma mark - Table view delegate

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case CollectionDataSection:
            break;
        case CollectionBookSection:
            if (indexPath.row == self.detailItem.books.count)
                [self loadBookView];
            else
                [self loadBookDetailViewForBookAtIndexPath:indexPath];
            break;
        default:
            DLog(@"Invalid CollectionDetailViewController section found: %i.", indexPath.section);
            break;
    }
}

-(void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        switch (indexPath.section)
        {
            case CollectionDataSection:
                // Never delete the data section rows.
                break;
            case CollectionBookSection:
                [self.detailItem removeBooksObject:[self sortedBookFromSet:self.detailItem.books atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            default:
                break;
        }
        
        // Save the context.
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
    }   
}

// Section headers.
-(NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* header = nil;
    
    switch (section)
    {
        case CollectionDataSection:
            break;
        case CollectionBookSection:
            if (self.detailItem.books.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Books", @"CollectionDetailViewController Books section header.");
            }
            break;
        default:
            DLog(@"Invalid CollectionDetailViewController section found: %i.", section);
            break;
    }
    
    return header;
}

-(BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case CollectionDataSection:
            return NO;
        default:
            return YES;
    }
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
        case CollectionNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Name", @"CollectionDetailViewController name data field label.");
            cell.textField.text = self.detailItem.name;
            cell.textField.tag = CollectionNameRow;
            break;
        default:
            break;
    }
    
    return cell;
}

-(UITableViewCell*) configureBookCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"BookCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.books.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Book...", @"CollectionDetailViewController add Book insertion row text.");
    }
    else
    {
        Book* book = [self sortedBookFromSet:self.detailItem.books atIndexPath:indexPath];
        cell.textLabel.text = book.title;
    }
    
    return cell;
}

#pragma mark - Book Selection Delegate Method

-(void) bookViewController:(BookViewController *)controller didSelectBook:(Book*)book forPersonType:(PersonType)type
{
    [self.detailItem addBooksObject:book];
    
    [ContextUtil saveContext:self.detailItem.managedObjectContext];
    
    [self.tableView reloadData];
}

-(void) bookViewController:(BookViewController *)controller didSelectBooks:(NSArray *)books
{
    for (Book* book in books)
    {
        [self.detailItem addBooksObject:book];
    }
    
    [ContextUtil saveContext:self.detailItem.managedObjectContext];
    [self.tableView reloadData];
}

#pragma mark - Local Helper Methods

-(Book*) sortedBookFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedBooks = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedBooks objectAtIndex:indexPath.row];
}

-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    NSArray* paths = [NSArray arrayWithObjects:path, nil];
    
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
}

-(void) loadBookView
{
    BookViewController* bookViewController = [[BookViewController alloc] initWithNibName:@"BookViewController" bundle:nil];
    bookViewController.managedObjectContext = self.detailItem.managedObjectContext;
    bookViewController.delegate = self;
    bookViewController.selectionMode = MultipleSelection;
    
    [self.navigationController pushViewController:bookViewController animated:YES];
}

-(void) loadBookDetailViewForBookAtIndexPath:(NSIndexPath*)indexPath
{
    BookDetailViewController* bookDetailViewController = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
    Book* selectedBook = [self sortedBookFromSet:self.detailItem.books atIndexPath:indexPath];
    
    if (selectedBook)
    {
        bookDetailViewController.detailItem = selectedBook;
        [self.navigationController pushViewController:bookDetailViewController animated:YES];
    }
}

@end
