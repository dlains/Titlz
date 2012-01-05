//
//  PersonDetailViewController.m
//  Titlz
//
//  Created by David Lains on 1/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "PersonDetailViewController.h"
#import "EditableTextCell.h"
#import "Person.h"

@interface PersonDetailViewController ()
-(UITableViewCell*) configureDataCellForRow:(NSInteger)row;
-(UITableViewCell*) configureAliasCell;
-(UITableViewCell*) configureAuthoredCell;
-(UITableViewCell*) configureEditedCell;
-(UITableViewCell*) configureIllustratedCell;
-(UITableViewCell*) configureContributedCell;
-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection;
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
        self.title = NSLocalizedString(@"Person", @"Person");
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

    self.title = @"Person";
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

-(void) updateRightBarButtonItemState
{
	// Conditionally enable the right bar button item -- it should only be enabled if the title is in a valid state for saving.
    self.navigationItem.rightBarButtonItem.enabled = [self.detailItem validateForUpdate:NULL];
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
    NSIndexPath* contributed = [NSIndexPath indexPathForRow:self.detailItem.contributed.count inSection:ContributedSection];
        
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
            cell = [self configureAliasCell];
            break;
        case AuthoredSection:
            cell = [self configureAuthoredCell];
            break;
        case EditedSection:
            cell = [self configureEditedCell];
            break;
        case IllustratedSection:
            cell = [self configureIllustratedCell];
            break;
        case ContributedSection:
            cell = [self configureContributedCell];
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
    NSInteger insertionRow = 0;
    
    if(self.editing)
        insertionRow = 1;
    
    // The last row should be the insert style, all others should be delete.
    if(collection.count == 0 || row == collection.count + insertionRow)
        return UITableViewCellEditingStyleInsert;
    else
        return UITableViewCellEditingStyleDelete;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
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
                header = [NSString stringWithString:@"Aliases"];
            }
            break;
        case AuthoredSection:
            if (self.detailItem.authored.count > 0 || self.editing)
            {
                header = [NSString stringWithString:@"Authored"];
            }
            break;
        case EditedSection:
            if (self.detailItem.edited.count > 0 || self.editing)
            {
                header = [NSString stringWithString:@"Edited"];
            }
            break;
        case IllustratedSection:
            if (self.detailItem.illustrated.count > 0 || self.editing)
            {
                header = [NSString stringWithString:@"Illustrated"];
            }
            break;
        case ContributedSection:
            if (self.detailItem.contributed.count > 0 || self.editing)
            {
                header = [NSString stringWithString:@"Contributed To"];
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
            if(self.editing && [self.detailItem.firstName length] <= 0)
            {
                cell.textField.placeholder = @"First";
            }
            else
            {
                cell.textField.text = self.detailItem.firstName;
            }
            cell.tag = FirstNameRow;
            break;
        case MiddleNameRow:
            if(self.editing && [self.detailItem.middleName length] <= 0)
            {
                cell.textField.placeholder = @"Middle";
            }
            else
            {
                cell.textField.text = self.detailItem.middleName;
            }
            cell.tag = MiddleNameRow;
            break;
        case LastNameRow:
            if(self.editing && [self.detailItem.lastName length] <= 0)
            {
                cell.textField.placeholder = @"Last";
            }
            else
            {
                cell.textField.text = self.detailItem.lastName;
            }
            cell.tag = LastNameRow;
            break;
        case BornRow:
        case DiedRow:
        default:
            break;
    }

    return cell;
}

-(UITableViewCell*) configureAliasCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing)
        cell.textLabel.text = @"Add New Alias...";
    
    return cell;
}

-(UITableViewCell*) configureAuthoredCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing)
        cell.textLabel.text = @"Add New Authored Title...";
    
    return cell;
}

-(UITableViewCell*) configureEditedCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing)
        cell.textLabel.text = @"Add New Edited Title...";
    
    return cell;
}

-(UITableViewCell*) configureIllustratedCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing)
        cell.textLabel.text = @"Add New Illustrated Title...";
    
    return cell;
}

-(UITableViewCell*) configureContributedCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing)
        cell.textLabel.text = @"Add New Contributed To Title...";
    
    return cell;
}

@end
