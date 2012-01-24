//
//  AwardDetailViewController.m
//  Titlz
//
//  Created by David Lains on 1/19/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "AwardDetailViewController.h"
#import "EditableTextCell.h"
#import "Award.h"

@interface AwardDetailViewController ()
-(UITableViewCell*) configureDataCellForRow:(NSInteger)row;
@end

@implementation AwardDetailViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;

#pragma mark - Initialization

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Award", @"AwardDetailViewController header bar title.");
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidRedo:) name:NSUndoManagerDidRedoChangeNotification object:self.detailItem.managedObjectContext.undoManager];
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
        case AwardNameRow:
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
        case AwardNameRow:
            self.detailItem.name = textField.text;
            break;
        case AwardCategoryRow:
            self.detailItem.category = textField.text;
            break;
        case AwardYearRow:
            self.detailItem.year = textField.text;
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
    
    if (editing)
    {
        [self setUpUndoManager];
    }
    else
    {
		[self cleanUpUndoManager];
		// Save the changes.
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
        [self.tableView reloadData];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return AwardDetailSectionCount;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case AwardDataSection:
            return AwardDataSectionRowCount;
        default:
            return 0;
    }
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section)
    {
        case AwardDataSection:
            cell = [self configureDataCellForRow:indexPath.row];
            break;
        default:
            DLog(@"Invalid AwardDetailViewController section found: %i.", indexPath.section);
            break;
    }
    
    return cell;
}

// Editing styles per row.
-(UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case AwardDataSection:
            return UITableViewCellEditingStyleNone;
        default:
            DLog(@"Invalid AwardDetailViewController section found: %i.", indexPath.section);
            return UITableViewCellEditingStyleNone;
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
        case AwardNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Name", @"AwardDetailViewController name data field label.");
            cell.textField.text = self.detailItem.name;
            cell.textField.tag = AwardNameRow;
            break;
        case AwardCategoryRow:
            cell.fieldLabel.text = NSLocalizedString(@"Category", @"AwardDetailViewController category data field label.");
            cell.textField.text = self.detailItem.category;
            cell.textField.tag = AwardCategoryRow;
            break;
        case AwardYearRow:
            cell.fieldLabel.text = NSLocalizedString(@"Year", @"AwardDetailViewController year data field label.");
            cell.textField.text = self.detailItem.year;
            cell.textField.tag = AwardYearRow;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        default:
            break;
    }
    
    return cell;
}

@end
