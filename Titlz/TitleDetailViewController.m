//
//  TitleDetailViewController.m
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import "TitleDetailViewController.h"
#import "PersonViewController.h"
#import "PersonDetailViewController.h"
#import "EditableTextCell.h"
#import "Title.h"
#import "Person.h"

@interface TitleDetailViewController ()
-(UITableViewCell*) configureNameCell;
-(UITableViewCell*) configureEditionCell;
-(UITableViewCell*) configureAuthorCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureEditorCellAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell*) configureIllustratorCellAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell*) configureContributorCellAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell*) configureBookCell;
-(UITableViewCell*) configureCollectionCell;
-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection;
-(Person*) sortedPersonFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath;
-(void) loadPersonViewControllerForPersonType:(PersonType)type;
-(void) loadPersonDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath;
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
            DLog(@"Invalid TitleDetailViewController section found: %i.", section);
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
            cell = [self configureAuthorCellAtIndexPath:indexPath];
            break;
        case EditorSection:
            cell = [self configureEditorCellAtIndexPath:indexPath];
            break;
        case IllustratorSection:
            cell = [self configureIllustratorCellAtIndexPath:indexPath];
            break;
        case ContributorSection:
            cell = [self configureContributorCellAtIndexPath:indexPath];
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
                [self loadPersonViewControllerForPersonType:Author];
            else
                [self loadPersonDetailViewForPersonType:Author atIndexPath:indexPath];
            break;
        case EditorSection:
            if (indexPath.row == self.detailItem.editors.count)
                [self loadPersonViewControllerForPersonType:Editor];
            else
                [self loadPersonDetailViewForPersonType:Editor atIndexPath:indexPath];
            break;
        case IllustratorSection:
            if (indexPath.row == self.detailItem.illustrators.count)
                [self loadPersonViewControllerForPersonType:Illustrator];
            else
                [self loadPersonDetailViewForPersonType:Illustrator atIndexPath:indexPath];
            break;
        case ContributorSection:
            if (indexPath.row == self.detailItem.contributors.count)
                [self loadPersonViewControllerForPersonType:Contributor];
            else
                [self loadPersonDetailViewForPersonType:Contributor atIndexPath:indexPath];
            break;
        case BookSection:
            break;
        case CollectionSection:
            break;
        default:
            DLog(@"Invalid TitleDetailViewController section found: %i.", indexPath.section);
            break;
    }
}

-(void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        switch (indexPath.section)
        {
            case NameSection:
                // Never delete the name.
                break;
            case EditionSection:
                break;
            case AuthorSection:
                [self.detailItem removeAuthorsObject:[self sortedPersonFromSet:self.detailItem.authors atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case EditorSection:
                [self.detailItem removeEditorsObject:[self sortedPersonFromSet:self.detailItem.editors atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case IllustratorSection:
                [self.detailItem removeIllustratorsObject:[self sortedPersonFromSet:self.detailItem.illustrators atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case ContributorSection:
                [self.detailItem removeContributorsObject:[self sortedPersonFromSet:self.detailItem.contributors atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case BookSection:
                break;
            case CollectionSection:
                break;
            default:
                break;
        }
        
        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
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

-(NSIndexPath*) tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (!self.editing)
    {
        switch (indexPath.section)
        {
            case NameSection:
                return nil;
            case EditionSection:
            case AuthorSection:
            case EditorSection:
            case IllustratorSection:
            case ContributorSection:
            case BookSection:
            case CollectionSection:
                return indexPath;
            default:
                DLog(@"Invalid TitleDetailViewController section found: %i.", indexPath.section);
                return nil;
        }
    }
    else
    {
        return indexPath;
    }
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

    cell.fieldLabel.text = @"Title";
    cell.textField.text = self.detailItem.name;
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
    static NSString* CellIdentifier = @"AuthorCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.authors.count)
    {
        cell.textLabel.text = @"Add Author...";
    }
    else
    {
        Person* person = [self sortedPersonFromSet:self.detailItem.authors atIndexPath:indexPath];
        cell.textLabel.text = person.fullName;
    }
    
    return cell;
}

-(UITableViewCell*) configureEditorCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"EditorCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.editors.count)
    {
        cell.textLabel.text = @"Add Editor...";
    }
    else
    {
        Person* person = [self sortedPersonFromSet:self.detailItem.editors atIndexPath:indexPath];
        cell.textLabel.text = person.fullName;
    }
    
    return cell;
}

-(UITableViewCell*) configureIllustratorCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"IllustratorCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.illustrators.count)
    {
        cell.textLabel.text = @"Add Illustrator...";
    }
    else
    {
        Person* person = [self sortedPersonFromSet:self.detailItem.illustrators atIndexPath:indexPath];
        cell.textLabel.text = person.fullName;
    }
    
    return cell;
}

-(UITableViewCell*) configureContributorCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ContributorCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.contributors.count)
    {
        cell.textLabel.text = @"Add Contributor...";
    }
    else
    {
        Person* person = [self sortedPersonFromSet:self.detailItem.contributors atIndexPath:indexPath];
        cell.textLabel.text = person.fullName;
    }
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

#pragma mark - Person Selection Delegate Method

-(void) personViewController:(PersonViewController *)controller didSelectPerson:(Person *)person withPersonType:(PersonType)type
{
    switch (type)
    {
        case Author:
            [self.detailItem addAuthorsObject:person];
            break;
        case Editor:
            [self.detailItem addEditorsObject:person];
            break;
        case Illustrator:
            [self.detailItem addIllustratorsObject:person];
            break;
        case Contributor:
            [self.detailItem addContributorsObject:person];
            break;
        default:
            DLog(@"Invalid PersonType found in TitleDetailViewController: %i.", type);
            break;
    }
    
    NSError* error;
    if (![self.detailItem.managedObjectContext save:&error])
    {
        // Update to handle the error appropriately.
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }

    [self.tableView reloadData];
}

#pragma mark - Local Helper Methods

-(Person*) sortedPersonFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedPeople = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedPeople objectAtIndex:indexPath.row];
}

-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    NSArray* paths = [NSArray arrayWithObjects:path, nil];
    
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
}

-(void) loadPersonViewControllerForPersonType:(PersonType)type
{
    PersonViewController* personViewController = [[PersonViewController alloc] initWithNibName:@"PersonViewController" bundle:nil];
    personViewController.delegate = self;
    personViewController.managedObjectContext = self.managedObjectContext;
    personViewController.selectionMode = TRUE;
    personViewController.personSelectionType = type;
    
    [self.navigationController pushViewController:personViewController animated:YES];
}

-(void) loadPersonDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath
{
    PersonDetailViewController* personDetailViewController = [[PersonDetailViewController alloc] initWithNibName:@"PersonDetailViewController" bundle:nil];
    Person* selectedPerson = nil;
    
    switch (type)
    {
        case Author:
            selectedPerson = [self sortedPersonFromSet:self.detailItem.authors atIndexPath:indexPath];
            break;
        case Editor:
            selectedPerson = [self sortedPersonFromSet:self.detailItem.editors atIndexPath:indexPath];
            break;
        case Illustrator:
            selectedPerson = [self sortedPersonFromSet:self.detailItem.illustrators atIndexPath:indexPath];
            break;
        case Contributor:
            selectedPerson = [self sortedPersonFromSet:self.detailItem.contributors atIndexPath:indexPath];
            break;
        default:
            break;
    }
    
    if (selectedPerson)
    {
        personDetailViewController.detailItem = selectedPerson;
        [self.navigationController pushViewController:personDetailViewController animated:YES];
    }
}

@end
