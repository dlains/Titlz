//
//  PersonDetailViewController.m
//  Titlz
//
//  Created by David Lains on 1/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "PersonDetailViewController.h"
#import "BookViewController.h"
#import "BookDetailViewController.h"
#import "EditableTextCell.h"
#import "Person.h"
#import "Book.h"

@interface PersonDetailViewController ()
-(UITableViewCell*) configureDataCellForRow:(NSInteger)row;
-(UITableViewCell*) configureAliasCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureAliasOfCell;
-(UITableViewCell*) configureAuthoredCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureEditedCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureIllustratedCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureContributedCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection;
-(Book*) sortedBookFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(Person*) sortedPersonFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath;
-(void) loadBookViewForPersonType:(PersonType)type;
-(void) loadBookDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath;
-(void) loadPersonViewForPersonType:(PersonType)type;
-(void) loadPersonDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath;
-(void) loadPersonDetailViewForPerson:(Person*)person;
@end

@implementation PersonDetailViewController

@synthesize detailItem = _detailItem;
@synthesize personTypeBeingAdded = _personTypeBeingAdded;
@synthesize undoManager = _undoManager;

#pragma mark - Initialization

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Person", @"PersonDetailViewController header bar title.");
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
        case PersonFirstNameRow:
            self.detailItem.firstName = textField.text;
            break;
        case PersonMiddleNameRow:
            self.detailItem.middleName = textField.text;
            break;
        case PersonLastNameRow:
            self.detailItem.lastName = textField.text;
            break;
        default:
            break;
    }
    
    [self becomeFirstResponder];
}

-(void) datePickerValueChanged:(id)sender
{
    UIDatePicker* datePicker = (UIDatePicker*)sender;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    switch (datePicker.tag)
    {
        case PersonBornRow:
            self.detailItem.born = datePicker.date;
            bornTextField.text = [formatter stringFromDate:datePicker.date];
            break;
        case PersonDiedRow:
            self.detailItem.died = datePicker.date;
            diedTextField.text = [formatter stringFromDate:datePicker.date];
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
	// Hide the back button when editing starts, and show it again when editing finishes.
    [self.navigationItem setHidesBackButton:editing animated:animated];

    NSIndexPath* alias         = [NSIndexPath indexPathForRow:self.detailItem.aliases.count inSection:PersonAliasSection];
    NSIndexPath* authored      = [NSIndexPath indexPathForRow:self.detailItem.authored.count inSection:PersonAuthoredSection];
    NSIndexPath* edited        = [NSIndexPath indexPathForRow:self.detailItem.edited.count inSection:PersonEditedSection];
    NSIndexPath* illustrated   = [NSIndexPath indexPathForRow:self.detailItem.illustrated.count inSection:PersonIllustratedSection];
    NSIndexPath* contributed   = [NSIndexPath indexPathForRow:self.detailItem.contributed.count inSection:PersonContributedSection];
        
    NSArray* paths = [NSArray arrayWithObjects:alias, authored, edited, illustrated, contributed, nil];
        
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
    return PersonDetailSectionCount;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger insertionRow = 0;
    
    // If the table is in editing mode add one row for inserting new records to most of the sections.
    if(self.editing)
        insertionRow = 1;
    
    switch (section)
    {
        case PersonDataSection:
            return 5;
        case PersonAliasSection:
            return self.detailItem.aliases.count + insertionRow;
        case PersonAliasOfSection:
            return (self.detailItem.aliasOf) ? 1 : 0;
        case PersonAuthoredSection:
            return self.detailItem.authored.count + insertionRow;
        case PersonEditedSection:
            return self.detailItem.edited.count + insertionRow;
        case PersonIllustratedSection:
            return self.detailItem.illustrated.count + insertionRow;
        case PersonContributedSection:
            return self.detailItem.contributed.count + insertionRow;
        default:
            return 0;
    }
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section)
    {
        case PersonDataSection:
            cell = [self configureDataCellForRow:indexPath.row];
            break;
        case PersonAliasSection:
            cell = [self configureAliasCellAtIndexPath:indexPath];
            break;
        case PersonAliasOfSection:
            cell = [self configureAliasOfCell];
            break;
        case PersonAuthoredSection:
            cell = [self configureAuthoredCellAtIndexPath:indexPath];
            break;
        case PersonEditedSection:
            cell = [self configureEditedCellAtIndexPath:indexPath];
            break;
        case PersonIllustratedSection:
            cell = [self configureIllustratedCellAtIndexPath:indexPath];
            break;
        case PersonContributedSection:
            cell = [self configureContributedCellAtIndexPath:indexPath];
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
        case PersonDataSection:
            return UITableViewCellEditingStyleNone;
        case PersonAliasSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.aliases];
        case PersonAliasOfSection:
            return UITableViewCellEditingStyleNone;
        case PersonAuthoredSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.authored];
        case PersonEditedSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.edited];
        case PersonIllustratedSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.illustrated];
        case PersonContributedSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.contributed];
        default:
            DLog(@"Invalid PersonDetailViewController section found: %i.", indexPath.section);
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
        case PersonDataSection:
            break;
        case PersonAliasSection:
            if (indexPath.row == self.detailItem.aliases.count)
                [self loadPersonViewForPersonType:Alias];
            else
                [self loadPersonDetailViewForPersonType:Alias atIndexPath:indexPath];
            break;
        case PersonAliasOfSection:
            [self loadPersonDetailViewForPerson:self.detailItem.aliasOf];
            break;
        case PersonAuthoredSection:
            if (indexPath.row == self.detailItem.authored.count)
                [self loadBookViewForPersonType:Author];
            else
                [self loadBookDetailViewForPersonType:Author atIndexPath:indexPath];
            break;
        case PersonEditedSection:
            if (indexPath.row == self.detailItem.edited.count)
                [self loadBookViewForPersonType:Editor];
            else
                [self loadBookDetailViewForPersonType:Editor atIndexPath:indexPath];
            break;
        case PersonIllustratedSection:
            if (indexPath.row == self.detailItem.illustrated.count)
                [self loadBookViewForPersonType:Illustrator];
            else
                [self loadBookDetailViewForPersonType:Illustrator atIndexPath:indexPath];
            break;
        case PersonContributedSection:
            if (indexPath.row == self.detailItem.contributed.count)
                [self loadBookViewForPersonType:Contributor];
            else
                [self loadBookDetailViewForPersonType:Contributor atIndexPath:indexPath];
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
            case PersonDataSection:
                // Never delete the data section rows.
                break;
            case PersonAliasSection:
                [self.detailItem removeAliasesObject:[self sortedPersonFromSet:self.detailItem.aliases atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case PersonAliasOfSection:
                break;
            case PersonAuthoredSection:
                [self.detailItem removeAuthoredObject:[self sortedBookFromSet:self.detailItem.authored atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case PersonEditedSection:
                [self.detailItem removeEditedObject:[self sortedBookFromSet:self.detailItem.edited atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case PersonIllustratedSection:
                [self.detailItem removeIllustratedObject:[self sortedBookFromSet:self.detailItem.illustrated atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case PersonContributedSection:
                [self.detailItem removeContributedObject:[self sortedBookFromSet:self.detailItem.contributed atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            default:
                break;
        }
        
        // Save the context.
        NSError *error = nil;
        if (![self.detailItem.managedObjectContext save:&error])
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
        case PersonDataSection:
            break;
        case PersonAliasSection:
            if (self.detailItem.aliases.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Aliases", @"PersonDetailViewController Alias section header.");
            }
            break;
        case PersonAliasOfSection:
            if (self.detailItem.aliasOf)
            {
                header = NSLocalizedString(@"Alias Of", @"PersonDetailViewController Alias Of section header.");
            }
            break;
        case PersonAuthoredSection:
            if (self.detailItem.authored.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Authored", @"PersonDetailViewController Authored section header.");
            }
            break;
        case PersonEditedSection:
            if (self.detailItem.edited.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Edited", @"PersonDetailViewController Edited Of section header.");
            }
            break;
        case PersonIllustratedSection:
            if (self.detailItem.illustrated.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Illustrated", @"PersonDetailViewController Illustrated section header.");
            }
            break;
        case PersonContributedSection:
            if (self.detailItem.contributed.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Contributed", @"PersonDetailViewController Contributed Of section header.");
            }
            break;
        default:
            DLog(@"Invalid PersonDetailViewController section found: %i.", section);
            break;
    }
    
    return header;
}

-(UITableViewCell*) configureDataCellForRow:(NSInteger)row
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    
    // Create the date picker to use for the Born and Died fields.
    UIDatePicker* datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];

    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.enabled = NO;
    }
    
    switch (row)
    {
        case PersonFirstNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"First", @"PersonDetailViewController firstName data field label.");
            cell.textField.text = self.detailItem.firstName;
            cell.textField.tag = PersonFirstNameRow;
            break;
        case PersonMiddleNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Middle", @"PersonDetailViewController middleName data field label.");
            cell.textField.text = self.detailItem.middleName;
            cell.textField.tag = PersonMiddleNameRow;
            break;
        case PersonLastNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Last", @"PersonDetailViewController lastName data field label.");
            cell.textField.text = self.detailItem.lastName;
            cell.textField.tag = PersonLastNameRow;
            break;
        case PersonBornRow:
            cell.fieldLabel.text = NSLocalizedString(@"Born", @"PersonDetailViewController born data field label.");
            bornTextField = cell.textField;
            cell.textField.tag = PersonBornRow;
            datePicker.tag = PersonBornRow;
            cell.textField.inputView = datePicker;
            cell.textField.text = [formatter stringFromDate:self.detailItem.born];
            break;
        case PersonDiedRow:
            cell.fieldLabel.text = NSLocalizedString(@"Died", @"PersonDetailViewController died data field label.");
            diedTextField = cell.textField;
            cell.textField.tag = PersonDiedRow;
            datePicker.tag = PersonDiedRow;
            cell.textField.inputView = datePicker;
            cell.textField.text = [formatter stringFromDate:self.detailItem.died];
            break;
        default:
            break;
    }

    return cell;
}

-(UITableViewCell*) configureAliasCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"AliasCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.aliases.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Alias...", @"PersonDetailViewController add Alias insertion row text.");
    }
    else
    {
        Person* person = [self sortedPersonFromSet:self.detailItem.aliases atIndexPath:indexPath];
        cell.textLabel.text = person.fullName;
    }
    
    return cell;
}

-(UITableViewCell*) configureAliasOfCell
{
    static NSString* CellIdentifier = @"AliasOfCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = self.detailItem.aliasOf.fullName;
    
    return cell;
}

-(UITableViewCell*) configureAuthoredCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"AuthorCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(self.editing && indexPath.row == self.detailItem.authored.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Authored Title...", @"PersonDetailViewController add Authored insertion row text.");
    }
    else
    {
        Book* book = [self sortedBookFromSet:self.detailItem.authored atIndexPath:indexPath];
        cell.textLabel.text = book.title;
    }
    
    return cell;
}

-(UITableViewCell*) configureEditedCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"EditorCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.edited.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Edited Title...", @"PersonDetailViewController add Edited insertion row text.");
    }
    else
    {
        Book* book = [self sortedBookFromSet:self.detailItem.edited atIndexPath:indexPath];
        cell.textLabel.text = book.title;
    }
    
    return cell;
}

-(UITableViewCell*) configureIllustratedCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"IllustratorCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.illustrated.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Illustrated Title...", @"PersonDetailViewController add Illustrated insertion row text.");
    }
    else
    {
        Book* book = [self sortedBookFromSet:self.detailItem.illustrated atIndexPath:indexPath];
        cell.textLabel.text = book.title;
    }
    
    return cell;
}

-(UITableViewCell*) configureContributedCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"ContributorCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.contributed.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Contributed Title...", @"PersonDetailViewController add Contributed insertion row text.");
    }
    else
    {
        Book* book = [self sortedBookFromSet:self.detailItem.contributed atIndexPath:indexPath];
        cell.textLabel.text = book.title;
    }
    
    return cell;
}

#pragma mark - Title Selection Delegate Method

-(void) bookViewController:(BookViewController *)controller didSelectBook:(Book*)book forPersonType:(PersonType)type
{
    switch (type)
    {
        case Author:
            [self.detailItem addAuthoredObject:book];
            break;
        case Editor:
            [self.detailItem addEditedObject:book];
            break;
        case Illustrator:
            [self.detailItem addIllustratedObject:book];
            break;
        case Contributor:
            [self.detailItem addContributedObject:book];
            break;
        default:
            DLog(@"Invalid PersonType found in PersonDetailViewController: %i.", type);
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

-(void) personViewController:(PersonViewController *)controller didSelectPerson:(Person *)person withPersonType:(PersonType)type
{
    if (type == Alias)
    {
        [self.detailItem addAliasesObject:person];

        NSError* error;
        if (![self.detailItem.managedObjectContext save:&error])
        {
            // Update to handle the error appropriately.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        [self.tableView reloadData];
    }
}

#pragma mark - Local Helper Methods

-(Book*) sortedBookFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedBooks = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedBooks objectAtIndex:indexPath.row];
}

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

-(void) loadBookViewForPersonType:(PersonType)type
{
    BookViewController* bookViewController = [[BookViewController alloc] initWithNibName:@"BookViewController" bundle:nil];
    bookViewController.managedObjectContext = self.detailItem.managedObjectContext;
    bookViewController.delegate = self;
    bookViewController.selectionMode = TRUE;
    bookViewController.personSelectionType = type;
    
    [self.navigationController pushViewController:bookViewController animated:YES];
}

-(void) loadBookDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath
{
    BookDetailViewController* bookDetailViewController = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
    Book* selectedBook = nil;
    
    switch (type)
    {
        case Author:
            selectedBook = [self sortedBookFromSet:self.detailItem.authored atIndexPath:indexPath];
            break;
        case Editor:
            selectedBook = [self sortedBookFromSet:self.detailItem.edited atIndexPath:indexPath];
            break;
        case Illustrator:
            selectedBook = [self sortedBookFromSet:self.detailItem.illustrated atIndexPath:indexPath];
            break;
        case Contributor:
            selectedBook = [self sortedBookFromSet:self.detailItem.contributed atIndexPath:indexPath];
            break;
        default:
            break;
    }
    
    if (selectedBook)
    {
        bookDetailViewController.detailItem = selectedBook;
        [self.navigationController pushViewController:bookDetailViewController animated:YES];
    }
}

-(void) loadPersonViewForPersonType:(PersonType)type
{
    PersonViewController* personViewController = [[PersonViewController alloc] initWithNibName:@"PersonViewController" bundle:nil];
    personViewController.delegate = self;
    personViewController.managedObjectContext = self.detailItem.managedObjectContext;
    personViewController.selectionMode = TRUE;
    personViewController.personSelectionType = type;
    
    [self.navigationController pushViewController:personViewController animated:YES];
}

-(void) loadPersonDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath
{
    if (type == Alias)
    {
        Person* selectedPerson = [self sortedPersonFromSet:self.detailItem.aliases atIndexPath:indexPath];

        if (selectedPerson)
        {
            PersonDetailViewController* personDetailViewController = [[PersonDetailViewController alloc] initWithNibName:@"PersonDetailViewController" bundle:nil];
            personDetailViewController.detailItem = selectedPerson;
            [self.navigationController pushViewController:personDetailViewController animated:YES];
        }
    }
}

-(void) loadPersonDetailViewForPerson:(Person*)person
{
    if (person)
    {
        PersonDetailViewController* personDetailViewController = [[PersonDetailViewController alloc] initWithNibName:@"PersonDetailViewController" bundle:nil];
        personDetailViewController.detailItem = person;
        [self.navigationController pushViewController:personDetailViewController animated:YES];
    }
}

@end
