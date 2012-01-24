//
//  NewPersonViewController.m
//  Titlz
//
//  Created by David Lains on 1/4/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "NewPersonViewController.h"
#import "EditableTextCell.h"
#import "Person.h"

@implementation NewPersonViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;
@synthesize delegate = _delegate;
@synthesize shouldValidate = _shouldValidate;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.shouldValidate = YES;
    
    self.title = NSLocalizedString(@"New Person", @"NewPersonViewController header bar title.");
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
	// Set up the undo manager and set editing state to YES.
	[self setUpUndoManager];
	self.editing = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[self cleanUpUndoManager];	
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
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
    return [textField resignFirstResponder];
}

-(BOOL) textFieldShouldEndEditing:(UITextField*)textField
{
    BOOL valid = YES;
    NSError* error;
    NSString* value = textField.text;
    NSDate* dateValue;
    
    if (self.shouldValidate)
    {
        switch (textField.tag)
        {
            case PersonLastNameRow:
                valid = [self.detailItem validateValue:&value forKey:@"lastName" error:&error];
                break;
            case PersonBornRow:
                dateValue = self.detailItem.born;
                if (dateValue)
                    valid = [self.detailItem validateValue:&dateValue forKey:@"born" error:&error];
                break;
            case PersonDiedRow:
                dateValue = self.detailItem.died;
                if (dateValue)
                    valid = [self.detailItem validateValue:&dateValue forKey:@"died" error:&error];
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

-(IBAction) cancel:(id)sender
{
    self.shouldValidate = NO;
    [self.delegate newPersonViewController:self didFinishWithSave:NO];
}

-(IBAction) save:(id)sender
{
    [self.delegate newPersonViewController:self didFinishWithSave:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return PersonDataSectionRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
        case PersonFirstNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"First", @"NewPersonViewController firstName data field label.");
            cell.textField.tag = PersonFirstNameRow;
            break;
        case PersonMiddleNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Middle", @"NewPersonViewController middleName data field label.");
            cell.textField.tag = PersonMiddleNameRow;
            break;
        case PersonLastNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Last", @"NewPersonViewController lastName data field label.");
            cell.textField.tag = PersonLastNameRow;
            break;
        case PersonBornRow:
            cell.fieldLabel.text = NSLocalizedString(@"Born", @"NewPersonViewController born data field label.");
            bornTextField = cell.textField;
            cell.textField.tag = PersonBornRow;
            datePicker.tag = PersonBornRow;
            cell.textField.inputView = datePicker;
            break;
        case PersonDiedRow:
            cell.fieldLabel.text = NSLocalizedString(@"Died", @"NewPersonViewController died data field label.");
            diedTextField = cell.textField;
            cell.textField.tag = PersonDiedRow;
            datePicker.tag = PersonDiedRow;
            cell.textField.inputView = datePicker;
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
