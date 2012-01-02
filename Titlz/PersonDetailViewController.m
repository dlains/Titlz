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
-(void) doneButtonPressed;
-(void) cancelButtonPressed;
-(UITableViewCell*) configureDataCellForRow:(NSInteger)row;
-(UITableViewCell*) configureAliasCell;
-(UITableViewCell*) configureAuthoredCell;
-(UITableViewCell*) configureEditedCell;
-(UITableViewCell*) configureIllustratedCell;
-(UITableViewCell*) configureContributedToCell;
-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection;
@end

@implementation PersonDetailViewController

@synthesize detailItem = _detailItem;
@synthesize editingContext = _editingContext;
@synthesize editMode = _editMode;
@synthesize newRecord = _newRecord;

#pragma mark - Initialization

-(id) initWithPrimaryManagedObjectContext:(NSManagedObjectContext*)primaryManagedObjectContext
{
    if (self = [super initWithNibName:@"PersonDetailViewController" bundle:nil])
    {
        self.editingContext = [[NSManagedObjectContext alloc] init];
        [self.editingContext setPersistentStoreCoordinator:[primaryManagedObjectContext persistentStoreCoordinator]];
        NSUndoManager* undoManager = [[NSUndoManager alloc] init];
        [self.editingContext setUndoManager:undoManager];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    self.editingContext = nil;
    self.detailItem = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Register for undo and redo change notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoOrRedoAction:) name:NSUndoManagerDidUndoChangeNotification object:[self.editingContext undoManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoOrRedoAction:) name:NSUndoManagerDidRedoChangeNotification object:[self.editingContext undoManager]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.editingContext = nil;
    self.detailItem = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	// Check to see if the detailItem is set, if not this is a new record, switch to editing mode.
    if (self.detailItem == nil)
    {
        // Create a new empty Person entity.
        self.detailItem = [Person personInManagedObjectContext:self.editingContext];
        
        self.title = @"New Person";
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
        self.navigationItem.rightBarButtonItem = doneButton;
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        [self setEditing:YES animated:NO];
    }
    else
    {
        self.title = @"Person";
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [[self.editingContext undoManager] removeAllActions];
    [self.editingContext reset];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    self.detailItem.firstName = textField.text;
    
    [self becomeFirstResponder];
}

#pragma mark - Table view data source

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    self.editMode = editing;
    [super setEditing:editing animated:animated];
    
    if(!self.newRecord)
    {
        NSIndexPath* alias         = [NSIndexPath indexPathForRow:self.detailItem.aliases.count inSection:AliasSection];
        NSIndexPath* authored      = [NSIndexPath indexPathForRow:self.detailItem.authored.count inSection:AuthoredSection];
        NSIndexPath* edited        = [NSIndexPath indexPathForRow:self.detailItem.edited.count inSection:EditedSection];
        NSIndexPath* illustrated   = [NSIndexPath indexPathForRow:self.detailItem.illustrated.count inSection:IllustratedSection];
        NSIndexPath* contributedTo = [NSIndexPath indexPathForRow:self.detailItem.contributedTo.count inSection:ContributedToSection];
        
        NSArray* paths = [NSArray arrayWithObjects:alias, authored, edited, illustrated, contributedTo, nil];
        
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return PersonDetailSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger insertionRow = 0;
    
    // If the table is in editing mode add one row for inserting new records to most of the sections.
    if(self.editMode)
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
        case ContributedToSection:
            return self.detailItem.contributedTo.count + insertionRow;
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
        case ContributedToSection:
            cell = [self configureContributedToCell];
            break;
        default:
            DLog(@"Invalid PersonDetailViewController section found: %i.", indexPath.section);
            break;
    }
    
    return cell;
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
            if (self.detailItem.aliases.count > 0 || self.editMode)
            {
                header = [NSString stringWithString:@"Aliases"];
            }
            break;
        case AuthoredSection:
            if (self.detailItem.authored.count > 0 || self.editMode)
            {
                header = [NSString stringWithString:@"Authored"];
            }
            break;
        case EditedSection:
            if (self.detailItem.edited.count > 0 || self.editMode)
            {
                header = [NSString stringWithString:@"Edited"];
            }
            break;
        case IllustratedSection:
            if (self.detailItem.illustrated.count > 0 || self.editMode)
            {
                header = [NSString stringWithString:@"Illustrated"];
            }
            break;
        case ContributedToSection:
            if (self.detailItem.contributedTo.count > 0 || self.editMode)
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
            if(self.editMode && [self.detailItem.firstName length] <= 0)
            {
                cell.textField.placeholder = @"First";
            }
            else
            {
                cell.textField.text = self.detailItem.firstName;
            }
            break;
        case MiddleNameRow:
            if(self.editMode && [self.detailItem.middleName length] <= 0)
            {
                cell.textField.placeholder = @"Middle";
            }
            else
            {
                cell.textField.text = self.detailItem.middleName;
            }
            break;
        case LastNameRow:
            if(self.editMode && [self.detailItem.lastName length] <= 0)
            {
                cell.textField.placeholder = @"Last";
            }
            else
            {
                cell.textField.text = self.detailItem.lastName;
            }
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
    
    if(self.editMode)
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
    
    if(self.editMode)
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
    
    if(self.editMode)
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
    
    if(self.editMode)
        cell.textLabel.text = @"Add New Illustrated Title...";
    
    return cell;
}

-(UITableViewCell*) configureContributedToCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editMode)
        cell.textLabel.text = @"Add New Contributed To Title...";
    
    return cell;
}

@end
