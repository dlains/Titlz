//
//  PersonDetailViewController.m
//  Titlz
//
//  Created by David Lains on 1/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "PersonDetailViewController.h"
#import "BookViewController.h"
#import "BookDetailViewController.h"
#import "EditableLookupAndTextCell.h"
#import "EditableTextCell.h"
#import "Person.h"
#import "Worker.h"
#import "Book.h"

@interface PersonDetailViewController ()
-(UITableViewCell*) configureDataCellForRow:(NSInteger)row;
-(UITableViewCell*) configureWorkedCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureAliasCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureAliasOfCell;
-(UITableViewCell*) configureBooksSignedCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection;
-(Book*) sortedBookFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(Person*) sortedPersonFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(Worker*) sortedWorkerFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath;
-(void) loadBookViewForPersonType:(PersonType)type;
-(void) loadBookDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath;
-(void) loadPersonViewForPersonType:(PersonType)type;
-(void) loadPersonDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath;
-(void) loadPersonDetailViewForPerson:(Person*)person;

-(void) addWorkerWithTitle:(NSString*)title andBook:(Book*)book;
-(void) updateWorkerObject:(NSManagedObjectID*)objectId withTitle:(NSString*)title andBook:(Book*)book;

-(IBAction) lookupButtonPressed:(id)sender;

@end

@implementation PersonDetailViewController

@synthesize detailItem = _detailItem;
@synthesize personTypeBeingAdded = _personTypeBeingAdded;
@synthesize undoManager = _undoManager;
@synthesize lookupJustFinished = _lookupJustFinished;
@synthesize allowDrilldown = _allowDrilldown;

#pragma mark - Initialization

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Person", @"PersonDetailViewController header bar title.");
        self.allowDrilldown = YES;
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

    self.lookupJustFinished = NO;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.93333 green:0.93333 blue:0.93333 alpha:1.0];
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

-(void) textFieldDidBeginEditing:(UITextField*)textField
{
    if (self.lookupJustFinished)
    {
        self.lookupJustFinished = NO;
        return;
    }
    
    switch (textField.tag)
    {
        case PersonWorkedTag:
            lookupTextField = textField;
            [self loadBookViewForPersonType:Workers];
            break;
        case PersonAliasTag:
            if (textField.text.length > 0)
            {
                [textField resignFirstResponder];
                return;
            }
            lookupTextField = textField;
            [self loadPersonViewForPersonType:Alias];
            break;
        case PersonSignedTag:
            if (textField.text.length > 0)
            {
                [textField resignFirstResponder];
                return;
            }
            lookupTextField = textField;
            [self loadBookViewForPersonType:Signature];
            break;
        default:
            lookupTextField = nil;
            break;
    }
}

-(BOOL) textFieldShouldEndEditing:(UITextField*)textField
{
    BOOL valid = YES;
    NSError* error;
    NSString* value = textField.text;
    NSDate* dateValue;
    
    switch (textField.tag)
    {
        case PersonLastNameTag:
            valid = [self.detailItem validateValue:&value forKey:@"lastName" error:&error];
            break;
        case PersonBornTag:
            dateValue = self.detailItem.born;
            if (dateValue)
                valid = [self.detailItem validateValue:&dateValue forKey:@"born" error:&error];
            break;
        case PersonDiedTag:
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
    
    return valid;
}

-(void) textFieldDidEndEditing:(UITextField*)textField
{
    switch (textField.tag)
    {
        case PersonFirstNameTag:
            self.detailItem.firstName = textField.text;
            break;
        case PersonMiddleNameTag:
            self.detailItem.middleName = textField.text;
            break;
        case PersonLastNameTag:
            self.detailItem.lastName = textField.text;
            break;
        case PersonWorkedTag:
        case PersonAliasTag:
        case PersonSignedTag:
            break;
        default:
            break;
    }
    
    [self becomeFirstResponder];
}

-(void) datePickerValueChanged:(id)sender
{
    UIDatePicker* picker = (UIDatePicker*)sender;
    
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    }
    
    switch (picker.tag)
    {
        case PersonBornTag:
            self.detailItem.born = picker.date;
            bornTextField.text = [dateFormatter stringFromDate:picker.date];
            break;
        case PersonDiedTag:
            self.detailItem.died = picker.date;
            diedTextField.text = [dateFormatter stringFromDate:picker.date];
            break;
        default:
            break;
    }
}

-(void) lookupViewController:(LookupViewController *)controller didSelectValue:(NSString *)value withLookupType:(LookupType)type
{
    EditableLookupAndTextCell* lookupCell = nil;
    
    switch (type)
    {
        case LookupTypeWorker:
            lookupCell = (EditableLookupAndTextCell*)workerLookupLabel.superview.superview;
            [self updateWorkerObject:lookupCell.objectId withTitle:value andBook:nil];
            workerLookupLabel.text = value;
            break;
        default:
            DLog(@"Invalid LookupType found in PersonDetailViewController::lookupViewController:didSelectValue:withLookupType: %i.", type);
            break;
    }
}

#pragma mark - Table view data source

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
	// Hide the back button when editing starts, and show it again when editing finishes.
    [self.navigationItem setHidesBackButton:editing animated:animated];

    NSIndexPath* worked        = [NSIndexPath indexPathForRow:self.detailItem.worked.count inSection:PersonWorkedSection];
    NSIndexPath* alias         = [NSIndexPath indexPathForRow:self.detailItem.aliases.count inSection:PersonAliasSection];
    NSIndexPath* booksSigned   = [NSIndexPath indexPathForRow:self.detailItem.booksSigned.count inSection:PersonBooksSignedSection];
        
    NSArray* paths = [NSArray arrayWithObjects:worked, alias, booksSigned, nil];

    if (editing)
    {
        [self setUpUndoManager];
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationRight];
    }
    else
    {
		[self cleanUpUndoManager];

        // Save the changes.
        [ContextUtil saveContext:self.detailItem.managedObjectContext];

        [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return PersonDetailSectionCount;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger insertionRow = 0;
    
    // If the table is in editing mode add one row for inserting new records to most of the sections.
    if(self.editing)
        insertionRow = 1;
    
    switch (section)
    {
        case PersonDataSection:
            return PersonDataSectionRowCount;
        case PersonWorkedSection:
            return self.detailItem.worked.count + insertionRow;
        case PersonAliasSection:
            return self.detailItem.aliases.count + insertionRow;
        case PersonAliasOfSection:
            return (self.detailItem.aliasOf) ? 1 : 0;
        case PersonBooksSignedSection:
            return self.detailItem.booksSigned.count + insertionRow;
        default:
            return 0;
    }
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section)
    {
        case PersonDataSection:
            cell = [self configureDataCellForRow:indexPath.row];
            break;
        case PersonWorkedSection:
            cell = [self configureWorkedCellAtIndexPath:indexPath];
            break;
        case PersonAliasSection:
            cell = [self configureAliasCellAtIndexPath:indexPath];
            break;
        case PersonAliasOfSection:
            cell = [self configureAliasOfCell];
            break;
        case PersonBooksSignedSection:
            cell = [self configureBooksSignedCellAtIndexPath:indexPath];
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
        case PersonDataSection:
            return UITableViewCellEditingStyleNone;
        case PersonWorkedSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.worked];
        case PersonAliasSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.aliases];
        case PersonAliasOfSection:
            return UITableViewCellEditingStyleNone;
        case PersonBooksSignedSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.booksSigned];
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

#pragma mark - Table view delegate

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.editing)
        return;

    if (self.allowDrilldown == NO)
        return;

    switch (indexPath.section)
    {
        case PersonDataSection:
            break;
        case PersonWorkedSection:
            [self loadBookDetailViewForPersonType:Workers atIndexPath:indexPath];
            break;
        case PersonAliasSection:
            [self loadPersonDetailViewForPersonType:Alias atIndexPath:indexPath];
            break;
        case PersonAliasOfSection:
            [self loadPersonDetailViewForPerson:self.detailItem.aliasOf];
            break;
        case PersonBooksSignedSection:
            [self loadBookDetailViewForPersonType:Signature atIndexPath:indexPath];
            break;
        default:
            DLog(@"Invalid PersonDetailViewController section found: %i.", indexPath.section);
            break;
    }
}

-(void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    Worker* worker = nil;
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        switch (indexPath.section)
        {
            case PersonDataSection:
                // Never delete the data section rows.
                break;
            case PersonWorkedSection:
                worker = [self sortedWorkerFromSet:self.detailItem.worked atIndexPath:indexPath];
                [self.detailItem removeWorkedObject:worker];
                [self.detailItem.managedObjectContext deleteObject:worker];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case PersonAliasSection:
                [self.detailItem removeAliasesObject:[self sortedPersonFromSet:self.detailItem.aliases atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case PersonAliasOfSection:
                break;
            case PersonBooksSignedSection:
                [self.detailItem removeBooksSignedObject:[self sortedBookFromSet:self.detailItem.booksSigned atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            default:
                break;
        }
        
        // Save the context.
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
    }   
}

-(BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case PersonDataSection:
            return NO;
        default:
            return YES;
    }
}

-(UITableViewCell*) configureDataCellForRow:(NSInteger)row
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    
    // Create the date picker to use for the Born and Died fields.
    if (bornDatePicker == nil)
    {
        bornDatePicker = [[UIDatePicker alloc] init];
        bornDatePicker.datePickerMode = UIDatePickerModeDate;
        [bornDatePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    if (diedDatePicker == nil)
    {
        diedDatePicker = [[UIDatePicker alloc] init];
        diedDatePicker.datePickerMode = UIDatePickerModeDate;
        [diedDatePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    }

    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    }

    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.delegate = self;
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.textField.inputView = nil;
    cell.textField.keyboardType = UIKeyboardTypeDefault;
    cell.textField.text = @"";
    if (self.editing)
        cell.textField.enabled = YES;
    else
        cell.textField.enabled = NO;

    switch (row)
    {
        case PersonFirstNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"First", @"PersonDetailViewController firstName data field label.");
            cell.textField.text = self.detailItem.firstName;
            cell.textField.tag = PersonFirstNameTag;
            break;
        case PersonMiddleNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Middle", @"PersonDetailViewController middleName data field label.");
            cell.textField.text = self.detailItem.middleName;
            cell.textField.tag = PersonMiddleNameTag;
            break;
        case PersonLastNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Last", @"PersonDetailViewController lastName data field label.");
            cell.textField.text = self.detailItem.lastName;
            cell.textField.tag = PersonLastNameTag;
            break;
        case PersonBornRow:
            cell.fieldLabel.text = NSLocalizedString(@"Born", @"PersonDetailViewController born data field label.");
            bornTextField = cell.textField;
            cell.textField.tag = PersonBornTag;
            bornDatePicker.tag = PersonBornTag;
            cell.textField.inputView = bornDatePicker;
            cell.textField.text = [dateFormatter stringFromDate:self.detailItem.born];
            break;
        case PersonDiedRow:
            cell.fieldLabel.text = NSLocalizedString(@"Died", @"PersonDetailViewController died data field label.");
            diedTextField = cell.textField;
            cell.textField.tag = PersonDiedTag;
            diedDatePicker.tag = PersonDiedTag;
            cell.textField.inputView = diedDatePicker;
            cell.textField.text = [dateFormatter stringFromDate:self.detailItem.died];
            break;
        default:
            break;
    }

    return cell;
}

-(UITableViewCell*) configureWorkedCellAtIndexPath:(NSIndexPath*)indexPath
{
    EditableLookupAndTextCell* workerCell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableLookupAndTextCell"];
    
    if (dummyView == nil)
    {
        dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }

    if (workerCell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableLookupAndTextCell" owner:self options:nil];
        workerCell = [topLevelObjects objectAtIndex:0];
        [workerCell.lookupButton addTarget:self action:@selector(lookupButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        workerCell.textField.delegate = self;
        workerCell.textField.inputView = dummyView;
        workerCell.textField.tag = PersonWorkedTag;
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    workerCell.textField.text = @"";
    if (self.editing)
    {
        workerCell.textField.enabled = YES;
        workerCell.lookupButton.enabled = YES;
    }
    else
    {
        workerCell.textField.enabled = NO;
        workerCell.lookupButton.enabled = NO;
    }

    Worker* worker = [self sortedWorkerFromSet:self.detailItem.worked atIndexPath:indexPath];
    
    if (worker != nil)
    {
        workerCell.fieldLabel.text = worker.title;
        workerCell.textField.text = worker.book.title;
        workerCell.objectId = worker.objectID;
    }
    else
    {
        workerCell.fieldLabel.text = @"Author";
    }
    
    return workerCell;
}

-(UITableViewCell*) configureAliasCellAtIndexPath:(NSIndexPath*)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"AliasEditableTextCell"];
    
    if (dummyView == nil)
    {
        dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }
    
    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.fieldLabel.text = NSLocalizedString(@"Alias", @"PersonDetailViewController alias cell field label text.");
        cell.textField.delegate = self;
        cell.textField.inputView = dummyView;
        cell.textField.tag = PersonAliasTag;
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.textField.text = @"";
    if (self.editing)
        cell.textField.enabled = YES;
    else
        cell.textField.enabled = NO;
    
    Person* person = [self sortedPersonFromSet:self.detailItem.aliases atIndexPath:indexPath];
    
    if (person != nil)
    {
        cell.textField.text = person.fullName;
    }
    
    return cell;
}

-(UITableViewCell*) configureAliasOfCell
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"AliasOfEditableTextCell"];
    
    if (dummyView == nil)
    {
        dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }
    
    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.fieldLabel.text = NSLocalizedString(@"Alias of", @"PersonDetailViewController alias of cell field label text.");
        cell.textField.delegate = self;
        cell.textField.inputView = dummyView;
        cell.textField.tag = PersonAliasOfTag;
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.textField.text = @"";
    if (self.editing)
        cell.textField.enabled = YES;
    else
        cell.textField.enabled = NO;

    Person* person = self.detailItem.aliasOf;
    
    if (person != nil)
    {
        cell.textField.text = person.fullName;
    }
    
    return cell;
}

-(UITableViewCell*) configureBooksSignedCellAtIndexPath:(NSIndexPath*)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"SignedEditableTextCell"];
    
    if (dummyView == nil)
    {
        dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }
    
    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.fieldLabel.text = NSLocalizedString(@"Signed", @"PersonDetailViewController booksSigned cell field label text.");
        cell.textField.delegate = self;
        cell.textField.inputView = dummyView;
        cell.textField.tag = PersonSignedTag;
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.textField.text = @"";
    if (self.editing)
        cell.textField.enabled = YES;
    else
        cell.textField.enabled = NO;
    
    Book* book = [self sortedBookFromSet:self.detailItem.booksSigned atIndexPath:indexPath];
    
    if (book != nil)
    {
        cell.textField.text = book.title;
    }
    
    return cell;
}

#pragma mark - Book Selection Delegate Method

-(void) addWorkerWithTitle:(NSString*)title andBook:(Book*)book
{
    Worker* worker = [Worker workerInManagedObjectContext:self.detailItem.managedObjectContext];
    
    worker.title = title;
    worker.book = book;
    worker.person = self.detailItem;
    [self.detailItem addWorkedObject:worker];
}

-(void) updateWorkerObject:(NSManagedObjectID*)objectId withTitle:(NSString*)title andBook:(Book*)book
{
    if (objectId != nil)
    {
        NSError* error;
        Worker* worker = (Worker*)[self.detailItem.managedObjectContext existingObjectWithID:objectId error:&error];
        if (worker != nil)
        {
            worker.title = title;
            if (book != nil)
            {
                worker.book = book;
            }
            [ContextUtil saveContext:self.detailItem.managedObjectContext];
        }
    }
}

-(void) bookViewController:(BookViewController *)controller didSelectBook:(Book*)book forPersonType:(PersonType)type
{
    if (book != nil)
    {
        EditableLookupAndTextCell* workerCell = nil;
        
        switch (type)
        {
            case Workers:
                workerCell = (EditableLookupAndTextCell*)lookupTextField.superview.superview;
                if (workerCell.objectId != nil)
                {
                    [self updateWorkerObject:workerCell.objectId withTitle:workerCell.fieldLabel.text andBook:book];
                }
                else
                {
                    [self addWorkerWithTitle:workerCell.fieldLabel.text andBook:book];
                }
                break;
            case Signature:
                [self.detailItem addBooksSignedObject:book];
                break;
            default:
                DLog(@"Invalid PersonType found in PersonDetailViewController: %i.", type);
                break;
        }
        
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
    }

    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

-(void) personViewController:(PersonViewController *)controller didSelectPerson:(Person *)person withPersonType:(PersonType)type
{
    if (person != nil)
    {
        if (type == Alias)
        {
            [self.detailItem addAliasesObject:person];
            [ContextUtil saveContext:self.detailItem.managedObjectContext];
        }
    }

    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - Local Helper Methods

-(Book*) sortedBookFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    if (set.count <= 0 || indexPath.row > set.count - 1)
        return nil;
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedBooks = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedBooks objectAtIndex:indexPath.row];
}

-(Person*) sortedPersonFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    if (set.count <= 0 || indexPath.row > set.count - 1)
        return nil;
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedPeople = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedPeople objectAtIndex:indexPath.row];
}

-(Worker*) sortedWorkerFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    if (set.count <= 0 || indexPath.row > set.count - 1)
        return nil;
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"book.title" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedWorkers = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedWorkers objectAtIndex:indexPath.row];
}

-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    NSArray* paths = [NSArray arrayWithObjects:path, nil];
    
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
}

-(void) loadBookViewForPersonType:(PersonType)type
{
    self.lookupJustFinished = YES;
    
    BookViewController* bookViewController = [[BookViewController alloc] initWithManagedObjectContext:self.detailItem.managedObjectContext];
    bookViewController.delegate = self;
    bookViewController.selectionMode = SingleSelection;
    bookViewController.personSelectionType = type;
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:bookViewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadBookDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath
{
    BookDetailViewController* bookDetailViewController = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
    Book* selectedBook = nil;
    Worker* worker = nil;
    
    switch (type)
    {
        case Workers:
            worker = [self sortedWorkerFromSet:self.detailItem.worked atIndexPath:indexPath];
            selectedBook = worker.book;
            break;
        case Signature:
            selectedBook = [self sortedBookFromSet:self.detailItem.booksSigned atIndexPath:indexPath];
            break;
        default:
            break;
    }
    
    if (selectedBook)
    {
        bookDetailViewController.detailItem = selectedBook;
        [self.navigationController pushViewController:bookDetailViewController animated:YES];
    }
}

-(void) loadPersonViewForPersonType:(PersonType)type
{
    self.lookupJustFinished = YES;
    
    PersonViewController* personViewController = [[PersonViewController alloc] initWithNibName:@"PersonViewController" bundle:nil];
    personViewController.delegate = self;
    personViewController.managedObjectContext = self.detailItem.managedObjectContext;
    personViewController.selectionMode = TRUE;
    personViewController.personSelectionType = type;
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:personViewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController presentModalViewController:navController animated:YES];
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

-(void) showLookupViewControllerForLookupType:(LookupType)type
{
    self.lookupJustFinished = YES;
    
    LookupViewController* controller = [[LookupViewController alloc] initWithLookupType:type];
    controller.delegate = self;
    controller.managedObjectContext = self.detailItem.managedObjectContext;
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController presentModalViewController:navController animated:YES];
}

#pragma mark - Worker Lookup Handling

-(void) lookupButtonPressed:(id)sender
{
    UIButton* button = sender;
    EditableLookupAndTextCell* workerCell = (EditableLookupAndTextCell*)button.superview.superview;
    workerLookupLabel = workerCell.fieldLabel;
    
    [self showLookupViewControllerForLookupType:LookupTypeWorker];
}

@end
