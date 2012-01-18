//
//  NewPublisherViewController.m
//  Titlz
//
//  Created by David Lains on 1/13/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "NewPublisherViewController.h"
#import "EditableTextCell.h"
#import "Publisher.h"


@implementation NewPublisherViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;
@synthesize delegate = _delegate;

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
    
    self.title = NSLocalizedString(@"New Publisher", @"NewPublisherViewController header bar title.");
    
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
	[self cleanUpUndoManager];	
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
	NSUndoManager* editionUndoManager = self.detailItem.managedObjectContext.undoManager;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:editionUndoManager];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidRedo:) name:NSUndoManagerDidRedoChangeNotification object:editionUndoManager];
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

-(void) textFieldDidEndEditing:(UITextField*)textField
{
    switch (textField.tag)
    {
        case PublisherNameRow:
            self.detailItem.name = textField.text;
            break;
        case PublisherParentRow:
            self.detailItem.parent = textField.text;
            break;
        case PublisherStreetRow:
            self.detailItem.street = textField.text;
            break;
        case PublisherStreet1Row:
            self.detailItem.street1 = textField.text;
            break;
        case PublisherCityRow:
            self.detailItem.city = textField.text;
            break;
        case PublisherStateRow:
            self.detailItem.state = textField.text;
            break;
        case PublisherPostalCodeRow:
            self.detailItem.postalCode = textField.text;
            break;
        case PublisherCountryRow:
            self.detailItem.country = textField.text;
            break;
        default:
            break;
    }
    
    [self becomeFirstResponder];
}

-(IBAction) cancel:(id)sender
{
    [self.delegate newPublisherViewController:self didFinishWithSave:NO];
}

-(IBAction) save:(id)sender
{
    [self.delegate newPublisherViewController:self didFinishWithSave:YES];
}

#pragma mark - Table view data source

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return PublisherDataSectionRowCount;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    
    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.enabled = NO;
    }
    
    switch (indexPath.row)
    {
        case PublisherNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Name", @"NewPublisherViewController name data field label.");
            cell.textField.tag = PublisherNameRow;
            break;
        case PublisherParentRow:
            cell.fieldLabel.text = NSLocalizedString(@"Parent", @"NewPublisherViewController parent data field label.");
            cell.textField.tag = PublisherParentRow;
            break;
        case PublisherStreetRow:
            cell.fieldLabel.text = NSLocalizedString(@"Street", @"NewPublisherViewController street data field label.");
            cell.textField.tag = PublisherStreetRow;
            break;
        case PublisherStreet1Row:
            cell.fieldLabel.text = NSLocalizedString(@"Street", @"NewPublisherViewController street data field label.");
            cell.textField.tag = PublisherStreet1Row;
            break;
        case PublisherCityRow:
            cell.fieldLabel.text = NSLocalizedString(@"City", @"NewPublisherViewController city data field label.");
            cell.textField.tag = PublisherCityRow;
            break;
        case PublisherStateRow:
            cell.fieldLabel.text = NSLocalizedString(@"State", @"NewPublisherViewController state data field label.");
            cell.textField.tag = PublisherStateRow;
            break;
        case PublisherPostalCodeRow:
            cell.fieldLabel.text = NSLocalizedString(@"Postal Code", @"NewPublisherViewController postalCode data field label.");
            cell.textField.tag = PublisherPostalCodeRow;
            break;
        case PublisherCountryRow:
            cell.fieldLabel.text = NSLocalizedString(@"Country", @"NewPublisherViewController country data field label.");
            cell.textField.tag = PublisherCountryRow;
            break;
        default:
            break;
    }
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