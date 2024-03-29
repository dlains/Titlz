//
//  NewCollectionViewController.m
//  Titlz
//
//  Created by David Lains on 1/30/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "NewCollectionViewController.h"
#import "EditableTextCell.h"
#import "Collection.h"


@implementation NewCollectionViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;
@synthesize delegate = _delegate;
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
    
    self.title = NSLocalizedString(@"New Collection", @"NewCollectionViewController header bar title.");
    self.tableView.backgroundColor = [UIColor colorWithRed:0.93333 green:0.93333 blue:0.93333 alpha:1.0];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
	// Set up the undo manager and set editing state to YES.
	[self setUpUndoManager];
	self.editing = YES;

    [TestFlight passCheckpoint:@"NewCollectionViewController Loaded"];
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
    return self.detailItem.managedObjectContext.undoManager;
}

-(void) undoManagerDidUndo:(NSNotification*)notification
{
    [self.tableView reloadData];
}

-(void) undoManagerDidRedo:(NSNotification*)notification
{
    [self.tableView reloadData];
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
        switch (textField.tag)
        {
            case CollectionNameRow:
                valid = [self.detailItem validateValue:&value forKey:@"name" error:&error];
                break;
            default:
                break;
        }
        
        if (valid)
            [textField resignFirstResponder];
        else
            [ContextUtil displayValidationError:error];
    }
    
    return valid;
}

-(void) textFieldDidEndEditing:(UITextField*)textField
{
    switch (textField.tag)
    {
        case CollectionNameRow:
            self.detailItem.name = textField.text;
            break;
        default:
            break;
    }
    
    [self becomeFirstResponder];
}

-(IBAction) cancel:(id)sender
{
    self.shouldValidate = NO;
    [self.delegate newCollectionViewController:self didFinishWithSave:NO];
}

-(IBAction) save:(id)sender
{
    [self.delegate newCollectionViewController:self didFinishWithSave:YES];
}

#pragma mark - Table view data source

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return CollectionDataSectionRowCount;
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
        case CollectionNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Name", @"NewCollectionViewController name data field label.");
            cell.textField.tag = CollectionNameRow;
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
