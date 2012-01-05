//
//  TitleDetailViewController.m
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import "TitleDetailViewController.h"
#import "PersonViewController.h"
#import "EditableTextCell.h"
#import "Title.h"
#import "Person.h"

@interface TitleDetailViewController ()
-(UITableViewCell*) configureNameCell;
-(UITableViewCell*) configureEditionCell;
-(UITableViewCell*) configureAuthorCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureEditorCell;
-(UITableViewCell*) configureIllustratorCell;
-(UITableViewCell*) configureContributorCell;
-(UITableViewCell*) configureBookCell;
-(UITableViewCell*) configureCollectionCell;
-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection;
@end

@implementation TitleDetailViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;
@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - Initialization

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Title", @"Title");
    }
    return self;
}

#pragma mark - View lifecycle

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.detailItem = nil;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewDidUnload
{
    [super viewDidUnload];

    self.detailItem = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.title = @"Title";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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
    return self.detailItem.managedObjectContext.undoManager;
}

-(void) undoManagerDidUndo:(NSNotification*)notification
{
    [self.tableView reloadData];
	[self updateRightBarButtonItemState];
}

-(void) undoManagerDidRedo:(NSNotification*)notification
{
    [self.tableView reloadData];
	[self updateRightBarButtonItemState];
}

#pragma mark - Button Processing

-(void) doneButtonPressed
{
    // Save the changes.
    NSError* error = nil;
    BOOL success = [[self.detailItem managedObjectContext] save:&error];
    if(!success)
    {
        DLog(@"Error saving: %@.", error);
    }
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void) cancelButtonPressed
{
    [self becomeFirstResponder];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField*)textField
{
    self.detailItem.name = textField.text;
    
    [self becomeFirstResponder];
}

#pragma mark - Table View Methods.

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
	// Hide the back button when editing starts, and show it again when editing finishes.
    [self.navigationItem setHidesBackButton:editing animated:animated];

    NSIndexPath* edition     = [NSIndexPath indexPathForRow:self.detailItem.editions.count inSection:EditionSection];
    NSIndexPath* author      = [NSIndexPath indexPathForRow:self.detailItem.authors.count inSection:AuthorSection];
    NSIndexPath* editor      = [NSIndexPath indexPathForRow:self.detailItem.editors.count inSection:EditorSection];
    NSIndexPath* illustrator = [NSIndexPath indexPathForRow:self.detailItem.illustrators.count inSection:IllustratorSection];
    NSIndexPath* contributor = [NSIndexPath indexPathForRow:self.detailItem.contributors.count inSection:ContributorSection];
    NSIndexPath* book        = [NSIndexPath indexPathForRow:self.detailItem.books.count inSection:BookSection];
    NSIndexPath* collection  = [NSIndexPath indexPathForRow:self.detailItem.collections.count inSection:CollectionSection];

    NSArray* paths = [NSArray arrayWithObjects:edition, author, editor, illustrator, contributor, book, collection, nil];

    if (editing)
    {
        [self setUpUndoManager];
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationRight];
    }
    else
    {
		[self cleanUpUndoManager];
		// Save the changes.
		NSError* error;
		if (![self.detailItem.managedObjectContext save:&error])
        {
			// Update to handle the error appropriately.
			DLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
        [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return TitleDetailSectionCount;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger insertionRow = 0;
    NSInteger count = 0;
    
    // If the table is in editing mode add one row for inserting new records to most of the sections.
    if(self.editing)
        insertionRow = 1;
    
    switch (section)
    {
        case NameSection:
            return 1;
        case EditionSection:
            return self.detailItem.editions.count + insertionRow;
        case AuthorSection:
            count = self.detailItem.authors.count + insertionRow;
            break;
        case EditorSection:
            return self.detailItem.editors.count + insertionRow;
        case IllustratorSection:
            return self.detailItem.illustrators.count + insertionRow;
        case ContributorSection:
            return self.detailItem.contributors.count + insertionRow;
        case BookSection:
            return self.detailItem.books.count + insertionRow;
        case CollectionSection:
            return self.detailItem.collections.count + insertionRow;
        default:
            return 0;
    }
    
    DLog(@"Number of rows in Author section: %i.", count);
    return count;
}

// Customize the appearance of table view cells.
-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section)
    {
        case NameSection:
            cell = [self configureNameCell];
            break;
        case EditionSection:
            cell = [self configureEditionCell];
            break;
        case AuthorSection:
            cell = [self configureAuthorCellAtIndexPath:indexPath];
            break;
        case EditorSection:
            cell = [self configureEditorCell];
            break;
        case IllustratorSection:
            cell = [self configureIllustratorCell];
            break;
        case ContributorSection:
            cell = [self configureContributorCell];
            break;
        case BookSection:
            cell = [self configureBookCell];
            break;
        case CollectionSection:
            cell = [self configureCollectionCell];
            break;
        default:
            DLog(@"Invalid TitleDetailViewController section found: %i.", indexPath.section);
            break;
    }
    
    return cell;
}

// Editing styles per row.
-(UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case NameSection:
            return UITableViewCellEditingStyleNone;
        case EditionSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.editions];
        case AuthorSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.authors];
        case EditorSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.editors];
        case IllustratorSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.illustrators];
        case ContributorSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.contributors];
        case BookSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.books];
        case CollectionSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.collections];
        default:
            DLog(@"Invalid TitleDetailViewController section found: %i.", indexPath.section);
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

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case NameSection:
            break;
        case EditionSection:
            break;
        case AuthorSection:
            if (indexPath.row == self.detailItem.authors.count)
            {
                PersonViewController* personViewController = [[PersonViewController alloc] initWithNibName:@"PersonViewController" bundle:nil];
                personViewController.delegate = self;
                personViewController.managedObjectContext = self.managedObjectContext;
                personViewController.selectionMode = TRUE;
                personViewController.personSelectionType = Author;
                
                [self.navigationController pushViewController:personViewController animated:YES];
            }
            else
            {
                // Existing Author being edited.
                
            }
        default:
            break;
    }
}

// Section headers.
-(NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* header = nil;
    
    switch (section)
    {
        case NameSection:
            break;
        case EditionSection:
            if (self.detailItem.editions.count > 0 || self.editing)
            {
                header = [NSString stringWithString:@"Editions"];
            }
            break;
        case AuthorSection:
            if (self.detailItem.authors.count > 0 || self.editing)
            {
                header = [NSString stringWithString:@"Authors"];
            }
            break;
        case EditorSection:
            if (self.detailItem.editors.count > 0 || self.editing)
            {
                header = [NSString stringWithString:@"Editors"];
            }
            break;
        case IllustratorSection:
            if (self.detailItem.illustrators.count > 0 || self.editing)
            {
                header = [NSString stringWithString:@"Illustrators"];
            }
            break;
        case ContributorSection:
            if (self.detailItem.contributors.count > 0 || self.editing)
            {
                header = [NSString stringWithString:@"Contributors"];
            }
            break;
        case BookSection:
            if (self.detailItem.books.count > 0 || self.editing)
            {
                header = [NSString stringWithString:@"Books"];
            }
            break;
        case CollectionSection:
            if (self.detailItem.collections.count > 0 || self.editing)
            {
                header = [NSString stringWithString:@"Collections"];
            }
            break;
        default:
            DLog(@"Invalid TitleDetailViewController section found: %i.", section);
            break;
    }
    
    return header;
}

-(UITableViewCell*) configureNameCell
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    
    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.enabled = NO;
    }

    if(self.editing && [self.detailItem.name length] <= 0)
    {
        cell.textField.placeholder = @"New Title";
    }
    else
    {
        cell.textField.text = self.detailItem.name;
    }
    return cell;
}

-(UITableViewCell*) configureEditionCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing)
        cell.textLabel.text = @"Add New Edition...";
    
    return cell;
}

-(UITableViewCell*) configureAuthorCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.authors.count)
        cell.textLabel.text = @"Add New Author...";
    else
    {
        NSArray* authors = [self.detailItem.authors allObjects];
        Person* person = [authors objectAtIndex:indexPath.row];
        cell.textLabel.text = person.fullName;
    }
    
    return cell;
}

-(UITableViewCell*) configureEditorCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing)
        cell.textLabel.text = @"Add New Editor...";
    
    return cell;
}

-(UITableViewCell*) configureIllustratorCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing)
        cell.textLabel.text = @"Add New Illustrator...";
    
    return cell;
}

-(UITableViewCell*) configureContributorCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing)
        cell.textLabel.text = @"Add New Contributor...";
    
    return cell;
}

-(UITableViewCell*) configureBookCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing)
        cell.textLabel.text = @"Add New Book...";
    
    return cell;
}

-(UITableViewCell*) configureCollectionCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing)
        cell.textLabel.text = @"Add New Collection...";
    
    return cell;
}

#pragma mark - Selection Delegate Methods

-(void) personViewController:(PersonViewController *)controller didSelectAuthor:(Person *)author
{
    // Just try a straight save for now.
    [self.detailItem addAuthorsObject:author];
    
    NSError* error;
    if (![self.detailItem.managedObjectContext save:&error])
    {
        // Update to handle the error appropriately.
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }

    [self.tableView reloadData];
}

@end
