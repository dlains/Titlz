//
//  NewEditionViewController.m
//  Titlz
//
//  Created by David Lains on 1/11/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "NewEditionViewController.h"
#import "EditionDetailViewController.h"
#import "EditableTextCell.h"
#import "Edition.h"

@implementation NewEditionViewController

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
    
    self.title = NSLocalizedString(@"New Edition", @"NewEditionViewController header bar title.");
    
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
        case EditionNameRow:
            self.detailItem.name = textField.text;
            break;
        case EditionFormatRow:
            self.detailItem.format = textField.text;
            break;
        case EditionIsbn10Row:
            self.detailItem.isbn10 = textField.text;
            break;
        case EditionIsbn13Row:
            self.detailItem.isbn13 = textField.text;
            break;
        case EditionPagesRow:
            self.detailItem.pages = textField.text;
            break;
        case EditionPrintRunRow:
            self.detailItem.printRun = textField.text;
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
        case EditionReleaseDateRow:
            self.detailItem.releaseDate = datePicker.date;
            releaseDateTextField.text = [formatter stringFromDate:datePicker.date];
            break;
        default:
            break;
    }
}

-(IBAction) cancel:(id)sender
{
    [self.delegate newEditionViewController:self didFinishWithSave:NO];
}

-(IBAction) save:(id)sender
{
    [self.delegate newEditionViewController:self didFinishWithSave:YES];
}

#pragma mark - Table view data source

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return EditionDataSectionRowCount;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    
    // Create the date picker to use for the Born and Died fields.
    UIDatePicker* datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.enabled = NO;
    }
    
    switch (indexPath.row)
    {
        case EditionNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Name", @"NewEditionViewController name data field label.");
            cell.textField.tag = EditionNameRow;
            break;
        case EditionFormatRow:
            cell.fieldLabel.text = NSLocalizedString(@"Format", @"NewEditionViewController format data field label.");
            cell.textField.tag = EditionFormatRow;
            break;
        case EditionIsbn10Row:
            cell.fieldLabel.text = NSLocalizedString(@"ISBN 10", @"NewEditionViewController isbn10 data field label.");
            cell.textField.tag = EditionIsbn10Row;
            break;
        case EditionIsbn13Row:
            cell.fieldLabel.text = NSLocalizedString(@"ISBN 13", @"NewEditionViewController isbn13 data field label.");
            cell.textField.tag = EditionIsbn13Row;
            break;
        case EditionPagesRow:
            cell.fieldLabel.text = NSLocalizedString(@"Pages", @"NewEditionViewController pages data field label.");
            cell.textField.tag = EditionPagesRow;
            break;
        case EditionPrintRunRow:
            cell.fieldLabel.text = NSLocalizedString(@"Print Run", @"NewEditionViewController printRun data field label.");
            cell.textField.tag = EditionPrintRunRow;
            break;
        case EditionReleaseDateRow:
            cell.fieldLabel.text = NSLocalizedString(@"Released", @"NewEditionViewController releaseDate data field label.");
            releaseDateTextField = cell.textField;
            cell.textField.tag = EditionReleaseDateRow;
            datePicker.tag = EditionReleaseDateRow;
            cell.textField.inputView = datePicker;
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
