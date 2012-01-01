//
//  TitleDetailViewController.m
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import "TitleDetailViewController.h"
#import "EditableTextCell.h"
#import "Title.h"

@interface TitleDetailViewController ()
-(void) doneButtonPressed;
-(void) cancelButtonPressed;
-(UITableViewCell*) configureNameCell;
-(UITableViewCell*) configureEditionCell;
@end

@implementation TitleDetailViewController

@synthesize detailItem = _detailItem;
@synthesize editingContext = _editingContext;

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
        self.tableView.editing = TRUE;
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
        NSLog(@"Error saving: %@.", error);
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

// Customize the number of sections in the table view.
-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return TitleDetailSectionCount;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case NameSection:
            return 1;
        case EditionSection:
            return self.detailItem.editions.count;
        case AuthorSection:
            return self.detailItem.authors.count;
        case EditorSection:
            return self.detailItem.editors.count;
        case IllustratorSection:
            return self.detailItem.illustrators.count;
        case ContributorSection:
            return self.detailItem.contributors.count;
        case BookSection:
            return self.detailItem.books.count;
        case CollectionSection:
            return self.detailItem.collections.count;
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
        default:
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
                
        default:
            return UITableViewCellEditingStyleInsert;
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

    if(self.tableView.editing && [self.detailItem.name length] <= 0)
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
    return nil;
}

@end
