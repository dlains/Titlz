//
//  NewLookupViewController.m
//  Titlz
//
//  Created by David Lains on 1/18/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "NewLookupViewController.h"
#import "EditableTextCell.h"
#import "Lookup.h"

@implementation NewLookupViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;
@synthesize delegate = _delegate;
@synthesize selectedLookupType = _selectedLookupType;
@synthesize shouldValidate = _shouldValidate;

-(void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void) viewDidLoad
{
    [super viewDidLoad];

    self.shouldValidate = YES;
    
    switch (self.selectedLookupType)
    {
        case LookupTypeEdition:
            self.title = NSLocalizedString(@"New Edition", @"NewLookupViewController Edition header bar title.");
            break;
        case LookupTypeFormat:
            self.title = NSLocalizedString(@"New Format", @"NewLookupViewController Format header bar title.");
            break;
        case LookupTypeCondition:
            self.title = NSLocalizedString(@"New Condition", @"NewLookupViewController Condition header bar title.");
            break;
        case LookupTypeCountry:
            self.title = NSLocalizedString(@"New Country", @"NewLookupViewController Country header bar title.");
            break;
        case LookupTypeState:
            self.title = NSLocalizedString(@"New State", @"NewLookupViewController State header bar title.");
            break;
        case LookupTypeWorker:
            self.title = NSLocalizedString(@"New Title", @"NewLookupViewController Title header bar title.");
            break;
        default:
            DLog(@"Invalid LookupType found in LookupViewController init: %i.", self.selectedLookupType);
            break;
    }
    self.tableView.backgroundColor = [UIColor colorWithRed:0.93333 green:0.93333 blue:0.93333 alpha:1.0];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
	// Set up the undo manager and set editing state to YES.
	[self setUpUndoManager];
	self.editing = YES;
}

-(void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
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
    
    if (self.shouldValidate)
    {
        valid = [self.detailItem validateValue:&value forKey:@"value" error:&error];
        
        if (valid)
            [textField resignFirstResponder];
        else
            [ContextUtil displayValidationError:error];
    }
    
    return valid;
}

-(void) textFieldDidEndEditing:(UITextField*)textField
{
    self.detailItem.type = [NSNumber numberWithInt:self.selectedLookupType];
    self.detailItem.name = textField.text;
    
    [self becomeFirstResponder];
}

-(IBAction) cancel:(id)sender
{
    self.shouldValidate = NO;
    [self.delegate newLookupViewController:self didFinishWithSave:NO];
}

-(IBAction) save:(id)sender
{
    [self.delegate newLookupViewController:self didFinishWithSave:YES];
}

#pragma mark - Table view data source

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    
    if (cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.enabled = NO;
    }
    
    switch (self.selectedLookupType)
    {
        case LookupTypeEdition:
            cell.fieldLabel.text = NSLocalizedString(@"Edition", @"NewLookupViewController value data field label.");
            break;
        case LookupTypeFormat:
            cell.fieldLabel.text = NSLocalizedString(@"Format", @"NewLookupViewController value data field label.");
            break;
        case LookupTypeCondition:
            cell.fieldLabel.text = NSLocalizedString(@"Condition", @"NewLookupViewController value data field label.");
            break;
        case LookupTypeCountry:
            cell.fieldLabel.text = NSLocalizedString(@"Country", @"NewLookupViewController value data field label.");
            break;
        case LookupTypeState:
            cell.fieldLabel.text = NSLocalizedString(@"State", @"NewLookupViewController value data field label.");
            break;
        case LookupTypeWorker:
            cell.fieldLabel.text = NSLocalizedString(@"TItle", @"NewLookupViewController value data field label.");
            break;
        default:
            DLog(@"Invalid LookupType found in LookupViewController init: %i.", self.selectedLookupType);
            break;
    }
    cell.textField.text = self.detailItem.name;
    
    return cell;
}

-(UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewCellEditingStyleNone;
}

-(BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
	return NO;
}

@end
