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
#import "EditionDetailViewController.h"
#import "EditableTextCell.h"
#import "Title.h"
#import "Person.h"
#import "Edition.h"

@interface TitleDetailViewController ()
-(UITableViewCell*) configureNameCell;
-(UITableViewCell*) configureEditionCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureAuthorCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureEditorCellAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell*) configureIllustratorCellAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell*) configureContributorCellAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell*) configureBookCell;
-(UITableViewCell*) configureCollectionCell;
-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection;
-(Person*) sortedPersonFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(Edition*) sortedEditionFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath;
-(void) loadPersonViewControllerForPersonType:(PersonType)type;
-(void) loadPersonDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath;
-(void) loadNewEditionView;
-(void) loadEditionDetailViewForEditionAtIndexPath:(NSIndexPath*)indexPath;
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
        self.title = NSLocalizedString(@"Title", @"TitleDetailViewController header bar title.");
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

    NSIndexPath* edition     = [NSIndexPath indexPathForRow:self.detailItem.editions.count inSection:TitleEditionSection];
    NSIndexPath* author      = [NSIndexPath indexPathForRow:self.detailItem.authors.count inSection:TitleAuthorSection];
    NSIndexPath* editor      = [NSIndexPath indexPathForRow:self.detailItem.editors.count inSection:TitleEditorSection];
    NSIndexPath* illustrator = [NSIndexPath indexPathForRow:self.detailItem.illustrators.count inSection:TitleIllustratorSection];
    NSIndexPath* contributor = [NSIndexPath indexPathForRow:self.detailItem.contributors.count inSection:TitleContributorSection];
    NSIndexPath* book        = [NSIndexPath indexPathForRow:self.detailItem.books.count inSection:TitleBookSection];
    NSIndexPath* collection  = [NSIndexPath indexPathForRow:self.detailItem.collections.count inSection:TitleCollectionSection];

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
        case TitleNameSection:
            return 1;
        case TitleEditionSection:
            return self.detailItem.editions.count + insertionRow;
        case TitleAuthorSection:
            return self.detailItem.authors.count + insertionRow;
        case TitleEditorSection:
            return self.detailItem.editors.count + insertionRow;
        case TitleIllustratorSection:
            return self.detailItem.illustrators.count + insertionRow;
        case TitleContributorSection:
            return self.detailItem.contributors.count + insertionRow;
        case TitleBookSection:
            return self.detailItem.books.count + insertionRow;
        case TitleCollectionSection:
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
        case TitleNameSection:
            cell = [self configureNameCell];
            break;
        case TitleEditionSection:
            cell = [self configureEditionCellAtIndexPath:indexPath];
            break;
        case TitleAuthorSection:
            cell = [self configureAuthorCellAtIndexPath:indexPath];
            break;
        case TitleEditorSection:
            cell = [self configureEditorCellAtIndexPath:indexPath];
            break;
        case TitleIllustratorSection:
            cell = [self configureIllustratorCellAtIndexPath:indexPath];
            break;
        case TitleContributorSection:
            cell = [self configureContributorCellAtIndexPath:indexPath];
            break;
        case TitleBookSection:
            cell = [self configureBookCell];
            break;
        case TitleCollectionSection:
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
        case TitleNameSection:
            return UITableViewCellEditingStyleNone;
        case TitleEditionSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.editions];
        case TitleAuthorSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.authors];
        case TitleEditorSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.editors];
        case TitleIllustratorSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.illustrators];
        case TitleContributorSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.contributors];
        case TitleBookSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.books];
        case TitleCollectionSection:
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
        case TitleNameSection:
            break;
        case TitleEditionSection:
            if (indexPath.row == self.detailItem.editions.count)
                [self loadNewEditionView];
            else
                [self loadEditionDetailViewForEditionAtIndexPath:indexPath];
            break;
        case TitleAuthorSection:
            if (indexPath.row == self.detailItem.authors.count)
                [self loadPersonViewControllerForPersonType:Author];
            else
                [self loadPersonDetailViewForPersonType:Author atIndexPath:indexPath];
            break;
        case TitleEditorSection:
            if (indexPath.row == self.detailItem.editors.count)
                [self loadPersonViewControllerForPersonType:Editor];
            else
                [self loadPersonDetailViewForPersonType:Editor atIndexPath:indexPath];
            break;
        case TitleIllustratorSection:
            if (indexPath.row == self.detailItem.illustrators.count)
                [self loadPersonViewControllerForPersonType:Illustrator];
            else
                [self loadPersonDetailViewForPersonType:Illustrator atIndexPath:indexPath];
            break;
        case TitleContributorSection:
            if (indexPath.row == self.detailItem.contributors.count)
                [self loadPersonViewControllerForPersonType:Contributor];
            else
                [self loadPersonDetailViewForPersonType:Contributor atIndexPath:indexPath];
            break;
        case TitleBookSection:
            break;
        case TitleCollectionSection:
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
            case TitleNameSection:
                // Never delete the name.
                break;
            case TitleEditionSection:
                break;
            case TitleAuthorSection:
                [self.detailItem removeAuthorsObject:[self sortedPersonFromSet:self.detailItem.authors atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case TitleEditorSection:
                [self.detailItem removeEditorsObject:[self sortedPersonFromSet:self.detailItem.editors atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case TitleIllustratorSection:
                [self.detailItem removeIllustratorsObject:[self sortedPersonFromSet:self.detailItem.illustrators atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case TitleContributorSection:
                [self.detailItem removeContributorsObject:[self sortedPersonFromSet:self.detailItem.contributors atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case TitleBookSection:
                break;
            case TitleCollectionSection:
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
        case TitleNameSection:
            break;
        case TitleEditionSection:
            if (self.detailItem.editions.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Editions", @"TitleDetailViewController Editions section header.");
            }
            break;
        case TitleAuthorSection:
            if (self.detailItem.authors.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Authors", @"TitleDetailViewController Authors section header.");
            }
            break;
        case TitleEditorSection:
            if (self.detailItem.editors.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Editors", @"TitleDetailViewController Editors section header.");
            }
            break;
        case TitleIllustratorSection:
            if (self.detailItem.illustrators.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Illustrators", @"TitleDetailViewController Illustrators section header.");
            }
            break;
        case TitleContributorSection:
            if (self.detailItem.contributors.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Contributors", @"TitleDetailViewController Contributors section header.");
            }
            break;
        case TitleBookSection:
            if (self.detailItem.books.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Books", @"TitleDetailViewController Books section header.");
            }
            break;
        case TitleCollectionSection:
            if (self.detailItem.collections.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Collections", @"TitleDetailViewController Collections section header.");
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
            case TitleNameSection:
                return nil;
            case TitleEditionSection:
            case TitleAuthorSection:
            case TitleEditorSection:
            case TitleIllustratorSection:
            case TitleContributorSection:
            case TitleBookSection:
            case TitleCollectionSection:
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

    cell.fieldLabel.text = NSLocalizedString(@"Title", @"TitleDetailViewController name data field label.");
    cell.textField.text = self.detailItem.name;
    return cell;
}

-(UITableViewCell*) configureEditionCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"EditionCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.editions.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Edition...", @"TitleDetailViewController add Edition insertion row text.");
    }
    else
    {
        Edition* edition = [self sortedEditionFromSet:self.detailItem.editions atIndexPath:indexPath];
        cell.textLabel.text = edition.name;
    }
    
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
        cell.textLabel.text = NSLocalizedString(@"Add Author...", @"TitleDetailViewController add Author insertion row text.");
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
        cell.textLabel.text = NSLocalizedString(@"Add Editor...", @"TitleDetailViewController add Editor insertion row text.");
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
        cell.textLabel.text = NSLocalizedString(@"Add Illustrator...", @"TitleDetailViewController add Illustrator insertion row text.");
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
        cell.textLabel.text = NSLocalizedString(@"Add Contributor...", @"TitleDetailViewController add Contributor insertion row text.");
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
        cell.textLabel.text = NSLocalizedString(@"Add Book...", @"TitleDetailViewController add Book insertion row text.");
    
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
        cell.textLabel.text = NSLocalizedString(@"Add Collection...", @"TitleDetailViewController add Collection insertion row text.");
    
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

#pragma mark - New Edition Delegate Method

-(void) newEditionViewController:(NewEditionViewController *)controller didFinishWithSave:(BOOL)save
{
    if (save)
    {
        [self.detailItem addEditionsObject:controller.detailItem];
        
        NSError* error;
        if (![self.detailItem.managedObjectContext save:&error])
        {
            // Update to handle the error appropriately.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        [self dismissModalViewControllerAnimated:YES];
        [self.tableView reloadData];
    }
}

#pragma mark - Local Helper Methods

-(Person*) sortedPersonFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedPeople = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedPeople objectAtIndex:indexPath.row];
}

-(Edition*) sortedEditionFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedEditions = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedEditions objectAtIndex:indexPath.row];
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

-(void) loadNewEditionView
{
    NewEditionViewController* newEditionViewController = [[NewEditionViewController alloc] initWithNibName:@"EditionDetailViewController" bundle:nil];
    newEditionViewController.delegate = self;
	newEditionViewController.detailItem = [Edition editionInManagedObjectContext:self.detailItem.managedObjectContext];
	
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newEditionViewController];
	
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadEditionDetailViewForEditionAtIndexPath:(NSIndexPath*)indexPath
{
    EditionDetailViewController* editionDetailViewController = [[EditionDetailViewController alloc] initWithNibName:@"EditionDetailViewController" bundle:nil];
    Edition* selectedEdition = [self sortedEditionFromSet:self.detailItem.editions atIndexPath:indexPath];
    
    if (selectedEdition)
    {
        editionDetailViewController.detailItem = selectedEdition;
        [self.navigationController pushViewController:editionDetailViewController animated:YES];
    }
}

@end
