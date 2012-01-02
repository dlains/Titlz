//
//  TitleDetailViewController.m
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import "TitleDetailViewController.h"
#import "PersonDetailViewController.h"
#import "EditableTextCell.h"
#import "Title.h"

@interface TitleDetailViewController ()
-(void) doneButtonPressed;
-(void) cancelButtonPressed;
-(UITableViewCell*) configureNameCell;
-(UITableViewCell*) configureEditionCell;
-(UITableViewCell*) configureAuthorCell;
-(UITableViewCell*) configureEditorCell;
-(UITableViewCell*) configureIllustratorCell;
-(UITableViewCell*) configureContributorCell;
-(UITableViewCell*) configureBookCell;
-(UITableViewCell*) configureCollectionCell;
-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection;
@end

@implementation TitleDetailViewController

@synthesize detailItem = _detailItem;
@synthesize editingContext = _editingContext;
@synthesize editMode = _editMode;
@synthesize newRecord = _newRecord;

#pragma mark - Initialization

-(id) initWithPrimaryManagedObjectContext:(NSManagedObjectContext*)primaryManagedObjectContext
{
    if (self = [super initWithNibName:@"TitleDetailViewController" bundle:nil])
    {
        self.editingContext = [[NSManagedObjectContext alloc] init];
        [self.editingContext setPersistentStoreCoordinator:[primaryManagedObjectContext persistentStoreCoordinator]];
        NSUndoManager* undoManager = [[NSUndoManager alloc] init];
        [self.editingContext setUndoManager:undoManager];
    }
    return self;
}

#pragma mark - View lifecycle

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.editingContext = nil;
    self.detailItem = nil;
}

-(void) viewDidLoad
{
    [super viewDidLoad];

    // Register for undo and redo change notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoOrRedoAction:) name:NSUndoManagerDidUndoChangeNotification object:[self.editingContext undoManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoOrRedoAction:) name:NSUndoManagerDidRedoChangeNotification object:[self.editingContext undoManager]];
}

-(void) viewDidUnload
{
    [super viewDidUnload];

    self.editingContext = nil;
    self.detailItem = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	// Check to see if the detailItem is set, if not this is a new record, switch to editing mode.
    if (self.detailItem == nil)
    {
        // Create a new empty Title entity.
        self.detailItem = [Title titleInManagedObjectContext:self.editingContext];
        
        self.title = @"New Title";
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
        self.navigationItem.rightBarButtonItem = doneButton;
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        [self setEditing:YES animated:NO];
    }
    else
    {
        self.title = @"Title";
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        [self.tableView reloadData];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [[self.editingContext undoManager] removeAllActions];
    [self.editingContext reset];
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

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Title", @"Title");
    }
    return self;
}

#pragma mark - Undo Support

-(BOOL) canBecomeFirstResponder
{
    return YES;
}

-(NSUndoManager*) undoManager
{
    return [[self.detailItem managedObjectContext] undoManager];
}

-(void) undoOrRedoAction:(NSNotification*)notification
{
    [self.tableView reloadData];
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
    [self.editingContext reset];
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
    self.editMode = editing;
    [super setEditing:editing animated:animated];
    
    if(!self.newRecord)
    {
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
            [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationRight];
        }
        else
        {
            [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        }
    }
}

// Customize the number of sections in the table view.
-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return TitleDetailSectionCount;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger insertionRow = 0;
    
    // If the table is in editing mode add one row for inserting new records to most of the sections.
    if(self.editMode)
        insertionRow = 1;
    
    switch (section)
    {
        case NameSection:
            return 1;
        case EditionSection:
            return self.detailItem.editions.count + insertionRow;
        case AuthorSection:
            return self.detailItem.authors.count + insertionRow;
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
            cell = [self configureAuthorCell];
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
    NSInteger insertionRow = 0;

    if(self.editMode)
        insertionRow = 1;
    
    // The last row should be the insert style, all others should be delete.
    if(collection.count == 0 || row == collection.count + insertionRow)
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
                PersonDetailViewController* personDetailViewController = [[PersonDetailViewController alloc] initWithPrimaryManagedObjectContext:self.editingContext];
                personDetailViewController.detailItem = nil;
                personDetailViewController.newRecord = YES;
                
                UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:personDetailViewController];
                [self.navigationController presentModalViewController:navigationController animated:YES];
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
            if (self.detailItem.editions.count > 0 || self.editMode)
            {
                header = [NSString stringWithString:@"Editions"];
            }
            break;
        case AuthorSection:
            if (self.detailItem.authors.count > 0 || self.editMode)
            {
                header = [NSString stringWithString:@"Authors"];
            }
            break;
        case EditorSection:
            if (self.detailItem.editors.count > 0 || self.editMode)
            {
                header = [NSString stringWithString:@"Editors"];
            }
            break;
        case IllustratorSection:
            if (self.detailItem.illustrators.count > 0 || self.editMode)
            {
                header = [NSString stringWithString:@"Illustrators"];
            }
            break;
        case ContributorSection:
            if (self.detailItem.contributors.count > 0 || self.editMode)
            {
                header = [NSString stringWithString:@"Contributors"];
            }
            break;
        case BookSection:
            if (self.detailItem.books.count > 0 || self.editMode)
            {
                header = [NSString stringWithString:@"Books"];
            }
            break;
        case CollectionSection:
            if (self.detailItem.collections.count > 0 || self.editMode)
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

    if(self.editMode && [self.detailItem.name length] <= 0)
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
    
    if(self.editMode)
        cell.textLabel.text = @"Add New Edition...";
    
    return cell;
}

-(UITableViewCell*) configureAuthorCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editMode)
        cell.textLabel.text = @"Add New Author...";
    
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
    
    if(self.editMode)
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
    
    if(self.editMode)
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
    
    if(self.editMode)
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
    
    if(self.editMode)
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
    
    if(self.editMode)
        cell.textLabel.text = @"Add New Collection...";
    
    return cell;
}

@end
