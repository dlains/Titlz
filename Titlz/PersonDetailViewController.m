//
//  PersonDetailViewController.m
//  Titlz
//
//  Created by David Lains on 1/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "PersonDetailViewController.h"
#import "TitleViewController.h"
#import "TitleDetailViewController.h"
#import "EditableTextCell.h"
#import "Person.h"
#import "Title.h"

@interface PersonDetailViewController ()
-(UITableViewCell*) configureDataCellForRow:(NSInteger)row;
-(UITableViewCell*) configureAliasCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureAliasOfCell;
-(UITableViewCell*) configureAuthoredCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureEditedCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureIllustratedCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureContributedCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection;
-(Title*) sortedTitleFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(Person*) sortedPersonFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath;
-(void) loadTitleViewForPersonType:(PersonType)type;
-(void) loadTitleDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath;
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
        case FirstNameRow:
            self.detailItem.firstName = textField.text;
            break;
        case MiddleNameRow:
            self.detailItem.middleName = textField.text;
            break;
        case LastNameRow:
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
        case BornRow:
            self.detailItem.born = datePicker.date;
            bornTextField.text = [formatter stringFromDate:datePicker.date];
            break;
        case DiedRow:
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

    NSIndexPath* alias         = [NSIndexPath indexPathForRow:self.detailItem.aliases.count inSection:AliasSection];
    NSIndexPath* authored      = [NSIndexPath indexPathForRow:self.detailItem.authored.count inSection:AuthoredSection];
    NSIndexPath* edited        = [NSIndexPath indexPathForRow:self.detailItem.edited.count inSection:EditedSection];
    NSIndexPath* illustrated   = [NSIndexPath indexPathForRow:self.detailItem.illustrated.count inSection:IllustratedSection];
    NSIndexPath* contributed   = [NSIndexPath indexPathForRow:self.detailItem.contributed.count inSection:ContributedSection];
        
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return PersonDetailSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger insertionRow = 0;
    
    // If the table is in editing mode add one row for inserting new records to most of the sections.
    if(self.editing)
        insertionRow = 1;
    
    switch (section)
    {
        case DataSection:
            return 5;
        case AliasSection:
            return self.detailItem.aliases.count + insertionRow;
        case AliasOfSection:
            return (self.detailItem.aliasOf) ? 1 : 0;
        case AuthoredSection:
            return self.detailItem.authored.count + insertionRow;
        case EditedSection:
            return self.detailItem.edited.count + insertionRow;
        case IllustratedSection:
            return self.detailItem.illustrated.count + insertionRow;
        case ContributedSection:
            return self.detailItem.contributed.count + insertionRow;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section)
    {
        case DataSection:
            cell = [self configureDataCellForRow:indexPath.row];
            break;
        case AliasSection:
            cell = [self configureAliasCellAtIndexPath:indexPath];
            break;
        case AliasOfSection:
            cell = [self configureAliasOfCell];
            break;
        case AuthoredSection:
            cell = [self configureAuthoredCellAtIndexPath:indexPath];
            break;
        case EditedSection:
            cell = [self configureEditedCellAtIndexPath:indexPath];
            break;
        case IllustratedSection:
            cell = [self configureIllustratedCellAtIndexPath:indexPath];
            break;
        case ContributedSection:
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
        case DataSection:
            return UITableViewCellEditingStyleNone;
        case AliasSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.aliases];
        case AliasOfSection:
            return UITableViewCellEditingStyleNone;
        case AuthoredSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.authored];
        case EditedSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.edited];
        case IllustratedSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.illustrated];
        case ContributedSection:
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
        case DataSection:
            break;
        case AliasSection:
            if (indexPath.row == self.detailItem.aliases.count)
                [self loadPersonViewForPersonType:Alias];
            else
                [self loadPersonDetailViewForPersonType:Alias atIndexPath:indexPath];
            break;
        case AliasOfSection:
            [self loadPersonDetailViewForPerson:self.detailItem.aliasOf];
            break;
        case AuthoredSection:
            if (indexPath.row == self.detailItem.authored.count)
                [self loadTitleViewForPersonType:Author];
            else
                [self loadTitleDetailViewForPersonType:Author atIndexPath:indexPath];
            break;
        case EditedSection:
            if (indexPath.row == self.detailItem.edited.count)
                [self loadTitleViewForPersonType:Editor];
            else
                [self loadTitleDetailViewForPersonType:Editor atIndexPath:indexPath];
            break;
        case IllustratedSection:
            if (indexPath.row == self.detailItem.illustrated.count)
                [self loadTitleViewForPersonType:Illustrator];
            else
                [self loadTitleDetailViewForPersonType:Illustrator atIndexPath:indexPath];
            break;
        case ContributedSection:
            if (indexPath.row == self.detailItem.contributed.count)
                [self loadTitleViewForPersonType:Contributor];
            else
                [self loadTitleDetailViewForPersonType:Contributor atIndexPath:indexPath];
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
            case DataSection:
                // Never delete the data section rows.
                break;
            case AliasSection:
                [self.detailItem removeAliasesObject:[self sortedPersonFromSet:self.detailItem.aliases atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case AliasOfSection:
                break;
            case AuthoredSection:
                [self.detailItem removeAuthoredObject:[self sortedTitleFromSet:self.detailItem.authored atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case EditedSection:
                [self.detailItem removeEditedObject:[self sortedTitleFromSet:self.detailItem.edited atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case IllustratedSection:
                [self.detailItem removeIllustratedObject:[self sortedTitleFromSet:self.detailItem.illustrated atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case ContributedSection:
                [self.detailItem removeContributedObject:[self sortedTitleFromSet:self.detailItem.contributed atIndexPath:indexPath]];
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
        case DataSection:
            break;
        case AliasSection:
            if (self.detailItem.aliases.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Aliases", @"PersonDetailViewController Alias section header.");
            }
            break;
        case AliasOfSection:
            if (self.detailItem.aliasOf)
            {
                header = NSLocalizedString(@"Alias Of", @"PersonDetailViewController Alias Of section header.");
            }
            break;
        case AuthoredSection:
            if (self.detailItem.authored.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Authored", @"PersonDetailViewController Authored section header.");
            }
            break;
        case EditedSection:
            if (self.detailItem.edited.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Edited", @"PersonDetailViewController Edited Of section header.");
            }
            break;
        case IllustratedSection:
            if (self.detailItem.illustrated.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Illustrated", @"PersonDetailViewController Illustrated section header.");
            }
            break;
        case ContributedSection:
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
        case FirstNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"First", @"PersonDetailViewController firstName data field label.");
            cell.textField.text = self.detailItem.firstName;
            cell.textField.tag = FirstNameRow;
            break;
        case MiddleNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Middle", @"PersonDetailViewController middleName data field label.");
            cell.textField.text = self.detailItem.middleName;
            cell.textField.tag = MiddleNameRow;
            break;
        case LastNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Last", @"PersonDetailViewController lastName data field label.");
            cell.textField.text = self.detailItem.lastName;
            cell.textField.tag = LastNameRow;
            break;
        case BornRow:
            cell.fieldLabel.text = NSLocalizedString(@"Born", @"PersonDetailViewController born data field label.");
            bornTextField = cell.textField;
            cell.textField.tag = 3;
            datePicker.tag = 3;
            cell.textField.inputView = datePicker;
            cell.textField.text = [formatter stringFromDate:self.detailItem.born];
            break;
        case DiedRow:
            cell.fieldLabel.text = NSLocalizedString(@"Died", @"PersonDetailViewController died data field label.");
            diedTextField = cell.textField;
            cell.textField.tag = 4;
            datePicker.tag = 4;
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
        Title* title = [self sortedTitleFromSet:self.detailItem.authored atIndexPath:indexPath];
        cell.textLabel.text = title.name;
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
        Title* title = [self sortedTitleFromSet:self.detailItem.authored atIndexPath:indexPath];
        cell.textLabel.text = title.name;
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
        Title* title = [self sortedTitleFromSet:self.detailItem.authored atIndexPath:indexPath];
        cell.textLabel.text = title.name;
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
        Title* title = [self sortedTitleFromSet:self.detailItem.authored atIndexPath:indexPath];
        cell.textLabel.text = title.name;
    }
    
    return cell;
}

#pragma mark - Title Selection Delegate Method

-(void) titleViewController:(TitleViewController *)controller didSelectTitle:(Title *)title forPersonType:(PersonType)type
{
    switch (type)
    {
        case Author:
            [self.detailItem addAuthoredObject:title];
            break;
        case Editor:
            [self.detailItem addEditedObject:title];
            break;
        case Illustrator:
            [self.detailItem addIllustratedObject:title];
            break;
        case Contributor:
            [self.detailItem addContributedObject:title];
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

-(Title*) sortedTitleFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedTitles = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedTitles objectAtIndex:indexPath.row];
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

-(void) loadTitleViewForPersonType:(PersonType)type
{
    TitleViewController* titleViewController = [[TitleViewController alloc] initWithNibName:@"TitleViewController" bundle:nil];
    titleViewController.managedObjectContext = self.detailItem.managedObjectContext;
    titleViewController.delegate = self;
    titleViewController.selectionMode = TRUE;
    titleViewController.personSelectionType = type;
    
    [self.navigationController pushViewController:titleViewController animated:YES];
}

-(void) loadTitleDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath
{
    TitleDetailViewController* titleDetailViewController = [[TitleDetailViewController alloc] initWithNibName:@"TitleDetailViewController" bundle:nil];
    Title* selectedTitle = nil;
    
    switch (type)
    {
        case Author:
            selectedTitle = [self sortedTitleFromSet:self.detailItem.authored atIndexPath:indexPath];
            break;
        case Editor:
            selectedTitle = [self sortedTitleFromSet:self.detailItem.edited atIndexPath:indexPath];
            break;
        case Illustrator:
            selectedTitle = [self sortedTitleFromSet:self.detailItem.illustrated atIndexPath:indexPath];
            break;
        case Contributor:
            selectedTitle = [self sortedTitleFromSet:self.detailItem.contributed atIndexPath:indexPath];
            break;
        default:
            break;
    }
    
    if (selectedTitle)
    {
        titleDetailViewController.detailItem = selectedTitle;
        [self.navigationController pushViewController:titleDetailViewController animated:YES];
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
