//
//  NewBookViewController.m
//  Titlz
//
//  Created by David Lains on 1/2/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "NewBookViewController.h"
#import "PersonViewController.h"
#import "CollectionDetailViewController.h"
#import "AwardDetailViewController.h"
#import "PointDetailViewController.h"
#import "PersonDetailViewController.h"
#import "EditableLookupAndTextCell.h"
#import "EditableImageAndTextCell.h"
#import "EditableTextViewCell.h"
#import "EditableTextCell.h"
#import "Book.h"
#import "Person.h"
#import "Award.h"
#import "DLPoint.h"
#import "Collection.h"
#import "Worker.h"
#import "Publisher.h"
#import "Seller.h"
#import "Photo.h"

@interface NewBookViewController ()
-(UITableViewCell*) configureTitleCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureWorkerCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureDetailsCellAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell*) configureInstanceDetailsCellAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell*) configureSignatureCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureAwardCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configurePointCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureCollectionCellAtIndexPath:(NSIndexPath*)indexPath;
-(Person*) sortedPersonFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(Worker*) sortedWorkerFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(Award*) sortedAwardFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(DLPoint*) sortedPointFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(Collection*) sortedCollectionFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(void) loadPersonViewForPersonType:(PersonType)type;
-(void) loadPublisherView;
-(void) loadSellerView;
-(void) loadNewAwardView;
-(void) loadNewPointView;
-(void) loadCollectionView;
-(void) showLookupViewControllerForLookupType:(LookupType)type;

-(void) addWorkerWithTitle:(NSString*)title andPerson:(Person*)person;
-(void) updateWorkerObject:(NSManagedObjectID*)objectId withTitle:(NSString*)title andPerson:(Person*)person;

-(IBAction) thumbnailButtonPressed:(id)sender;
-(IBAction) lookupButtonPressed:(id)sender;
@end

@implementation NewBookViewController

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

    // Start with a default book title.
    if (self.detailItem.title == nil)
    {
        self.detailItem.title = NSLocalizedString(@"New Title", @"NewBookViewController default book title.");
    }
    
    self.shouldValidate = YES;
    
    self.title = NSLocalizedString(@"New Book", @"NewBookViewController header bar title.");
    self.tableView.backgroundColor = [UIColor colorWithRed:0.93333 green:0.93333 blue:0.93333 alpha:1.0];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = doneButton;

	// Set up the undo manager and set editing state to YES.
	[self setUpUndoManager];
	self.editing = YES;
}

-(void)viewDidUnload
{
	[super viewDidUnload];
	[self cleanUpUndoManager];	
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
	NSUndoManager* bookUndoManager = self.detailItem.managedObjectContext.undoManager;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:bookUndoManager];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoManagerDidRedo:) name:NSUndoManagerDidRedoChangeNotification object:bookUndoManager];
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

-(void) textFieldDidBeginEditing:(UITextField*)textField
{
    switch (textField.tag)
    {
        case BookWorkerTag:
            lookupTextField = textField;
            [textField resignFirstResponder];
            [self loadPersonViewForPersonType:Workers];
            break;
        case BookFormatTag:
            lookupTextField = textField;
            [textField resignFirstResponder];
            [self showLookupViewControllerForLookupType:LookupTypeFormat];
            break;
        case BookEditionTag:
            lookupTextField = textField;
            [textField resignFirstResponder];
            [self showLookupViewControllerForLookupType:LookupTypeEdition];
            break;
        case BookBookConditionTag:
        case BookJacketConditionTag:
            lookupTextField = textField;
            [textField resignFirstResponder];
            [self showLookupViewControllerForLookupType:LookupTypeCondition];
            break;
        case BookPublisherTag:
            lookupTextField = textField;
            [textField resignFirstResponder];
            [self loadPublisherView];
            break;
        case BookBoughtFromTag:
            lookupTextField = textField;
            [textField resignFirstResponder];
            [self loadSellerView];
        case BookSignatureTag:
            if (textField.text.length > 0)
            {
                [textField resignFirstResponder];
                return;
            }
            lookupTextField = textField;
            [self loadPersonViewForPersonType:Signature];
            break;
        case BookAwardTag:
            if (textField.text.length > 0)
            {
                [textField resignFirstResponder];
                return;
            }
            lookupTextField = textField;
            [self loadNewAwardView];
            break;
        case BookPointTag:
            if (textField.text.length > 0)
            {
                [textField resignFirstResponder];
                return;
            }
            lookupTextField = textField;
            [self loadNewPointView];
            break;
        case BookCollectionTag:
            if (textField.text.length > 0)
            {
                [textField resignFirstResponder];
                return;
            }
            lookupTextField = textField;
            [self loadCollectionView];
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
    
    if (self.shouldValidate)
    {
        switch (textField.tag)
        {
            case BookTitleTag:
                valid = [self.detailItem validateValue:&value forKey:@"title" error:&error];
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
        case BookTitleTag:
            self.detailItem.title = textField.text;
            break;
        case BookWorkerTag:
        case BookFormatTag:
        case BookPublisherTag:
        case BookBoughtFromTag:
        case BookEditionTag:
            break;
        case BookPrintingTag:
            self.detailItem.printing = ([textField.text length] > 0) ? [NSNumber numberWithInt:[textField.text intValue]] : nil;
            break;
        case BookIsbnTag:
            self.detailItem.isbn = textField.text;
            break;
        case BookPagesTag:
            self.detailItem.pages = ([textField.text length] > 0) ? [NSNumber numberWithInt:[textField.text intValue]] : nil;
            break;
        case BookReleaseDateTag:
        case BookPurchaseDateTag:
            break;
        case BookOriginalPriceTag:
            self.detailItem.originalPrice = ([textField.text length] > 0) ? [NSDecimalNumber decimalNumberWithString:textField.text] : nil;
            break;
        case BookPricePaidTag:
            self.detailItem.pricePaid = ([textField.text length] > 0) ? [NSDecimalNumber decimalNumberWithString:textField.text] : nil;
            break;
        case BookCurrentValueTag:
            self.detailItem.currentValue = ([textField.text length] > 0) ? [NSDecimalNumber decimalNumberWithString:textField.text] : nil;
            break;
        case BookBookConditionTag:
        case BookJacketConditionTag:
            break;
        case BookNumberTag:
            self.detailItem.number = ([textField.text length] > 0) ? [NSNumber numberWithInt:[textField.text intValue]] : nil;
            break;
        case BookPrintRunTag:
            self.detailItem.printRun = ([textField.text length] > 0) ? [NSNumber numberWithInt:[textField.text intValue]] : nil;
            break;
        case BookCommentsTag:
        case BookSignatureTag:
        case BookAwardTag:
        case BookPointTag:
        case BookCollectionTag:
            break;
        default:
            DLog(@"Invalid NewBookViewController textField.tag value found: %i.", textField.tag);
            break;
    }
    
    [self becomeFirstResponder];
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    switch (textView.tag)
    {
        case BookCommentsTag:
            self.detailItem.comments = textView.text;
            break;
        default:
            DLog(@"Invalid NewBookViewController textView.tag value found: %i.", textView.tag);
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
        case BookReleaseDateTag:
            self.detailItem.releaseDate = picker.date;
            releaseDateTextField.text = [dateFormatter stringFromDate:picker.date];
            break;
        case BookPurchaseDateTag:
            self.detailItem.purchaseDate = picker.date;
            purchaseDateTextField.text = [dateFormatter stringFromDate:picker.date];
            break;
        default:
            break;
    }
}

-(void) lookupViewController:(LookupViewController *)controller didSelectValue:(NSString *)value withLookupType:(LookupType)type
{
    EditableLookupAndTextCell* lookupCell = nil;
    
    if (value.length > 0)
    {
        switch (type)
        {
            case LookupTypeEdition:
                self.detailItem.edition = value;
                lookupTextField.text = value;
                break;
            case LookupTypeFormat:
                self.detailItem.format = value;
                lookupTextField.text = value;
                break;
            case LookupTypeCondition:
                if (lookupTextField.tag == BookBookConditionTag)
                {
                    self.detailItem.bookCondition = value;
                    lookupTextField.text = value;
                }
                else if (lookupTextField.tag == BookJacketConditionTag)
                {
                    self.detailItem.jacketCondition = value;
                    lookupTextField.text = value;
                }
                else
                    DLog(@"Invalid textField.tag found for LookupTypeCondition selection: %i.", lookupTextField.tag);
                break;
            case LookupTypeWorker:
                lookupCell = (EditableLookupAndTextCell*)workerLookupLabel.superview.superview;
                [self updateWorkerObject:lookupCell.objectId withTitle:value andPerson:nil];
                workerLookupLabel.text = value;
                break;
            default:
                DLog(@"Invalid LookupType found in NewBookViewController::lookupViewController:didSelectValue:withLookupType: %i.", type);
                break;
        }
    }
    
    [self becomeFirstResponder];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(IBAction) cancel:(id)sender
{
    self.shouldValidate = NO;
    [self.delegate newBookViewController:self didFinishWithSave:NO];
}

-(IBAction) save:(id)sender
{
    [self.delegate newBookViewController:self didFinishWithSave:YES];
}

// Customize the number of sections in the table view.
-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return BookDetailSectionCount;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger insertionRow = 0;
    
    // If the table is in editing mode add one row for inserting new records to most of the sections.
    if(self.editing)
        insertionRow = 1;
    
    switch (section)
    {
        case BookTitleSection:
            return BookTitleSectionRowCount;
        case BookWorkersSection:
            return self.detailItem.workers.count + insertionRow;
        case BookDetailsSection:
            return BookDetailsSectionRowCount;
        case BookInstanceDetailsSection:
            return BookInstanceDetailsSectionRowCount;
        case BookSignatureSection:
            return self.detailItem.signatures.count + insertionRow;
        case BookAwardSection:
            return self.detailItem.awards.count + insertionRow;
        case BookPointSection:
            return self.detailItem.points.count + insertionRow;
        case BookCollectionSection:
            return self.detailItem.collections.count + insertionRow;
        default:
            DLog(@"Invalid NewBookViewController section found: %i.", section);
            return 0;
    }
}

// Customize the appearance of table view cells.
-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section)
    {
        case BookTitleSection:
            cell = [self configureTitleCellAtIndexPath:indexPath];
            break;
        case BookWorkersSection:
            cell = [self configureWorkerCellAtIndexPath:indexPath];
            break;
        case BookDetailsSection:
            cell = [self configureDetailsCellAtIndexPath:indexPath];
            break;
        case BookInstanceDetailsSection:
            cell = [self configureInstanceDetailsCellAtIndexPath:indexPath];
            break;
        case BookSignatureSection:
            cell = [self configureSignatureCellAtIndexPath:indexPath];
            break;
        case BookAwardSection:
            cell = [self configureAwardCellAtIndexPath:indexPath];
            break;
        case BookPointSection:
            cell = [self configurePointCellAtIndexPath:indexPath];
            break;
        case BookCollectionSection:
            cell = [self configureCollectionCellAtIndexPath:indexPath];
            break;
        default:
            DLog(@"Invalid NewBookViewController section found: %i.", indexPath.section);
            break;
    }
    
    return cell;
}

-(UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewCellEditingStyleNone;
}

-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == BookTitleSection && indexPath.row == BookTitleRow)
    {
        return 130.0f;
    }
    else if (indexPath.section == BookInstanceDetailsSection && indexPath.row == BookCommentsRow)
    {
        return 90.0f;
    }
    else
    {
        return UITableViewAutomaticDimension;
    }
}

-(BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
	return NO;
}

-(UITableViewCell*) configureTitleCellAtIndexPath:(NSIndexPath*)indexPath
{
    EditableImageAndTextCell* imageCell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableImageAndTextCell"];

    if(imageCell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableImageAndTextCell" owner:self options:nil];
        imageCell = [topLevelObjects objectAtIndex:0];
        [imageCell.thumbnailButton addTarget:self action:@selector(thumbnailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        imageCell.textField.tag = BookTitleTag;
    }

    if (self.editing)
    {
        imageCell.thumbnailButton.enabled = YES;
        imageCell.textField.enabled = YES;
        imageCell.textField.hidden = NO;
        imageCell.titleLabel.hidden = YES;
    }
    else
    {
        imageCell.thumbnailButton.enabled = NO;
        imageCell.textField.enabled = NO;
        imageCell.textField.hidden = YES;
        imageCell.titleLabel.hidden = NO;
    }

    switch (indexPath.row)
    {
        case BookTitleRow:
            if (self.detailItem.thumbnail == nil)
                imageCell.thumbnailView.image = [UIImage imageNamed:@"BookCover-leather-large.jpg"];
            else
                imageCell.thumbnailView.image = self.detailItem.thumbnail;
            imageCell.textField.text = self.detailItem.title;
            imageCell.titleLabel.text = self.detailItem.title;
            break;
        default:
            DLog(@"Invalid NewBookViewController Title section row found: %i.", indexPath.row);
            break;
    }
    
    return imageCell;
}

-(UITableViewCell*) configureWorkerCellAtIndexPath:(NSIndexPath*)indexPath
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
        workerCell.textField.delegate = self;
        workerCell.textField.enabled = NO;
        workerCell.textField.inputView = dummyView;
        workerCell.lookupButton.enabled = NO;
        workerCell.textField.tag = BookWorkerTag;
        [workerCell.lookupButton addTarget:self action:@selector(lookupButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }

    Worker* worker = [self sortedWorkerFromSet:self.detailItem.workers atIndexPath:indexPath];
    
    if (worker != nil)
    {
        workerCell.fieldLabel.text = worker.title;
        workerCell.textField.text = worker.person.fullName;
        workerCell.objectId = worker.objectID;
    }
    else
    {
        workerCell.fieldLabel.text = @"Author";
        workerCell.textField.text = @"";
    }
    
    return workerCell;
}

-(UITableViewCell*) configureDetailsCellAtIndexPath:(NSIndexPath *)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    
    // Create the date picker to use for the releaseDate field.
    if (releaseDatePicker == nil)
    {
        releaseDatePicker = [[UIDatePicker alloc] init];
        releaseDatePicker.datePickerMode = UIDatePickerModeDate;
        [releaseDatePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    }
    
    // A dummy view to keep the keyboard from popping up in the lookup fields.
    if (dummyView == nil)
    {
        dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
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
    
    switch (indexPath.row)
    {
        case BookFormatRow:
            cell.fieldLabel.text = NSLocalizedString(@"Format", @"NewBookViewController format data field label.");
            cell.textField.text = self.detailItem.format;
            cell.textField.inputView = dummyView;
            cell.textField.tag = BookFormatTag;
            break;
        case BookEditionRow:
            cell.fieldLabel.text = NSLocalizedString(@"Edition", @"NewBookViewController edition data field label.");
            cell.textField.text = self.detailItem.edition;
            cell.textField.inputView = dummyView;
            cell.textField.tag = BookEditionTag;
            break;
        case BookPagesRow:
            cell.fieldLabel.text = NSLocalizedString(@"Pages", @"NewBookViewController pages data field label.");
            cell.textField.text = (self.detailItem.pages == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.pages intValue]];
            cell.textField.tag = BookPagesTag;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case BookIsbnRow:
            cell.fieldLabel.text = NSLocalizedString(@"ISBN", @"NewBookViewController isbn data field label.");
            cell.textField.text = self.detailItem.isbn;
            cell.textField.tag = BookIsbnTag;
            cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        case BookOriginalPriceRow:
            cell.fieldLabel.text = NSLocalizedString(@"Original Price", @"NewBookViewController originalPrice data field label.");
            cell.textField.text = (self.detailItem.originalPrice == nil) ? @"" : [NSString stringWithFormat:@"%1.2f", [self.detailItem.originalPrice floatValue]];
            cell.textField.tag = BookOriginalPriceTag;
            cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case BookReleaseDateRow:
            cell.fieldLabel.text = NSLocalizedString(@"Released", @"NewBookViewController releaseDate data field label.");
            releaseDateTextField = cell.textField;
            cell.textField.tag = BookReleaseDateTag;
            releaseDatePicker.tag = BookReleaseDateTag;
            cell.textField.inputView = releaseDatePicker;
            cell.textField.text = [dateFormatter stringFromDate:self.detailItem.releaseDate];
            break;
        case BookPublisherRow:
            cell.fieldLabel.text = NSLocalizedString(@"Publisher", @"NewBookViewController publisher data field label.");
            if (self.detailItem.publisher != nil)
                cell.textField.text = self.detailItem.publisher.name;
            cell.textField.inputView = dummyView;
            cell.textField.tag = BookPublisherTag;
            break;
        default:
            DLog(@"Invalid NewBookViewController Data section row found: %i.", indexPath.row);
            break;
    }
    
    return cell;
}

-(UITableViewCell*) configureInstanceDetailsCellAtIndexPath:(NSIndexPath *)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    EditableTextViewCell* textCell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextViewCell"];
    
    // Create the date picker to use for the purchaseDate field.
    if (purchaseDatePicker == nil)
    {
        purchaseDatePicker = [[UIDatePicker alloc] init];
        purchaseDatePicker.datePickerMode = UIDatePickerModeDate;
        [purchaseDatePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    }
    
    // A dummy view to keep the keyboard from popping up in the lookup fields.
    if (dummyView == nil)
    {
        dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }

    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.delegate = self;
    }
    
    if(textCell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextViewCell" owner:self options:nil];
        textCell = [topLevelObjects objectAtIndex:0];
        textCell.textView.delegate = self;
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.textField.inputView = nil;
    cell.textField.keyboardType = UIKeyboardTypeDefault;
    cell.textField.text = @"";
    if (self.editing)
    {
        cell.textField.enabled = YES;
        textCell.textView.editable = YES;
    }
    else
    {
        cell.textField.enabled = NO;
        textCell.textView.editable = NO;
    }
    
    switch (indexPath.row)
    {
        case BookBookConditionRow:
            cell.fieldLabel.text = NSLocalizedString(@"Book Cond.", @"NewBookViewController bookCondition data field label.");
            cell.textField.text = self.detailItem.bookCondition;
            cell.textField.inputView = dummyView;
            cell.textField.tag = BookBookConditionTag;
            break;
        case BookJacketConditionRow:
            cell.fieldLabel.text = NSLocalizedString(@"Jacket Cond.", @"NewBookViewController jacketCondition data field label.");
            cell.textField.text = self.detailItem.jacketCondition;
            cell.textField.inputView = dummyView;
            cell.textField.tag = BookJacketConditionTag;
            break;
        case BookPurchaseDateRow:
            cell.fieldLabel.text = NSLocalizedString(@"Puchased", @"NewBookViewController purchaseDate data field label.");
            purchaseDateTextField = cell.textField;
            cell.textField.tag = BookPurchaseDateTag;
            purchaseDatePicker.tag = BookPurchaseDateTag;
            cell.textField.inputView = purchaseDatePicker;
            cell.textField.text = [dateFormatter stringFromDate:self.detailItem.purchaseDate];
            break;
        case BookPricePaidRow:
            cell.fieldLabel.text = NSLocalizedString(@"Price Paid", @"NewBookViewController pricePaid data field label.");
            cell.textField.text = (self.detailItem.pricePaid == nil) ? @"" : [NSString stringWithFormat:@"%1.2f", [self.detailItem.pricePaid floatValue]];
            cell.textField.tag = BookPricePaidTag;
            cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case BookCurrentValueRow:
            cell.fieldLabel.text = NSLocalizedString(@"Current Value", @"NewBookViewController currentValue data field label.");
            cell.textField.text = (self.detailItem.currentValue == nil) ? @"" : [NSString stringWithFormat:@"%1.2f", [self.detailItem.currentValue floatValue]];
            cell.textField.tag = BookCurrentValueTag;
            cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case BookPrintingRow:
            cell.fieldLabel.text = NSLocalizedString(@"Printing", @"NewBookViewController printing data field label.");
            cell.textField.text = (self.detailItem.printing == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.printing intValue]];
            cell.textField.tag = BookPrintingTag;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case BookNumberRow:
            cell.fieldLabel.text = NSLocalizedString(@"Number", @"NewBookViewController number data field label.");
            cell.textField.text = (self.detailItem.number == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.number intValue]];
            cell.textField.tag = BookNumberTag;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case BookPrintRunRow:
            cell.fieldLabel.text = NSLocalizedString(@"Print Run", @"NewBookViewController printRun data field label.");
            cell.textField.text = (self.detailItem.printRun == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.printRun intValue]];
            cell.textField.tag = BookPrintRunTag;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case BookBoughtFromRow:
            cell.fieldLabel.text = NSLocalizedString(@"Seller", @"NewBookViewController boughtFrom data field label.");
            if (self.detailItem.boughtFrom != nil)
                cell.textField.text = self.detailItem.boughtFrom.name;
            cell.textField.inputView = dummyView;
            cell.textField.tag = BookBoughtFromTag;
            break;
        case BookCommentsRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Comments", @"BookDetailViewController comments data field label.");
            textCell.textView.text = self.detailItem.comments;
            textCell.textView.tag = BookCommentsTag;
            return textCell;
        default:
            DLog(@"Invalid NewBookViewController Data section row found: %i.", indexPath.row);
            break;
    }
    
    return cell;
}

-(UITableViewCell*) configureSignatureCellAtIndexPath:(NSIndexPath*)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"SignatureEditableTextCell"];

    // A dummy view to keep the keyboard from popping up in the lookup fields.
    if (dummyView == nil)
    {
        dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }
    
    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.delegate = self;
        cell.fieldLabel.text = NSLocalizedString(@"Signed by", @"NewBookViewController signature cell field label text.");
        cell.textField.text = @"";
        cell.textField.inputView = dummyView;
        cell.textField.tag = BookSignatureTag;
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    if (self.editing)
        cell.textField.enabled = YES;
    else
        cell.textField.enabled = NO;
    
    Person* person = [self sortedPersonFromSet:self.detailItem.signatures atIndexPath:indexPath];
    
    if (person != nil)
    {
        cell.textField.text = person.fullName;
    }
    
    return cell;
}

-(UITableViewCell*) configureAwardCellAtIndexPath:(NSIndexPath*)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"AwardEditableTextCell"];
    
    // A dummy view to keep the keyboard from popping up in the lookup fields.
    if (dummyView == nil)
    {
        dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }
    
    if (cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.delegate = self;
        cell.fieldLabel.text = NSLocalizedString(@"Award", @"NewBookViewController award cell field label text.");
        cell.textField.text = @"";
        cell.textField.inputView = dummyView;
        cell.textField.tag = BookAwardTag;
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    if (self.editing)
        cell.textField.enabled = YES;
    else
        cell.textField.enabled = NO;

    Award* award = [self sortedAwardFromSet:self.detailItem.awards atIndexPath:indexPath];

    if(award != nil)
    {
        cell.textField.text = award.name;
    }
    
    return cell;
}

-(UITableViewCell*) configurePointCellAtIndexPath:(NSIndexPath*)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"PointEditableTextCell"];
    
    // A dummy view to keep the keyboard from popping up in the lookup fields.
    if (dummyView == nil)
    {
        dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }
    
    if (cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.delegate = self;
        cell.fieldLabel.text = NSLocalizedString(@"Point", @"NewBookViewController point cell field label text.");
        cell.textField.text = @"";
        cell.textField.inputView = dummyView;
        cell.textField.tag = BookPointTag;
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    if (self.editing)
        cell.textField.enabled = YES;
    else
        cell.textField.enabled = NO;
    
    DLPoint* point = [self sortedPointFromSet:self.detailItem.points atIndexPath:indexPath];

    if(point != nil)
    {
        cell.textField.text = point.issue;
    }
    
    return cell;
}

-(UITableViewCell*) configureCollectionCellAtIndexPath:(NSIndexPath*)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"CollectionEditableTextCell"];
    
    // A dummy view to keep the keyboard from popping up in the lookup fields.
    if (dummyView == nil)
    {
        dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }
    
    if (cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.delegate = self;
        cell.fieldLabel.text = NSLocalizedString(@"Collection", @"NewBookViewController collection cell field label text.");
        cell.textField.text = @"";
        cell.textField.inputView = dummyView;
        cell.textField.tag = BookCollectionTag;
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    if (self.editing)
        cell.textField.enabled = YES;
    else
        cell.textField.enabled = NO;
    
    Collection* collection = [self sortedCollectionFromSet:self.detailItem.collections atIndexPath:indexPath];
    
    if(collection != nil)
    {
        cell.textField.text = collection.name;
    }
    
    return cell;
}

#pragma mark - Person Selection Delegate Method

-(void) addWorkerWithTitle:(NSString*)title andPerson:(Person*)person
{
    Worker* worker = [Worker workerInManagedObjectContext:self.detailItem.managedObjectContext];
    
    worker.title = title;
    worker.book = self.detailItem;
    worker.person = person;
    [self.detailItem addWorkersObject:worker];
}

-(void) updateWorkerObject:(NSManagedObjectID*)objectId withTitle:(NSString*)title andPerson:(Person *)person
{
    if (objectId != nil)
    {
        NSError* error;
        Worker* worker = (Worker*)[self.detailItem.managedObjectContext existingObjectWithID:objectId error:&error];
        if (worker != nil)
        {
            worker.title = title;
            if (person != nil)
            {
                worker.person = person;
            }
            [ContextUtil saveContext:self.detailItem.managedObjectContext];
        }
    }
}

-(void) personViewController:(PersonViewController *)controller didSelectPerson:(Person *)person withPersonType:(PersonType)type
{
    EditableLookupAndTextCell* workerCell = nil;
    
    if (person != nil)
    {
        switch (type)
        {
            case Workers:
                workerCell = (EditableLookupAndTextCell*)lookupTextField.superview.superview;
                if (workerCell.objectId != nil)
                {
                    [self updateWorkerObject:workerCell.objectId withTitle:workerCell.fieldLabel.text andPerson:person];
                }
                else
                {
                    [self addWorkerWithTitle:workerCell.fieldLabel.text andPerson:person];
                }
                break;
            case Signature:
                [self.detailItem addSignaturesObject:person];
                break;
            default:
                DLog(@"Invalid PersonType found in TitleDetailViewController: %i.", type);
                break;
        }
    }
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - Publisher Selection Delegate Method

-(void) publisherViewController:(PublisherViewController *)controller didSelectPublisher:(Publisher *)publisher
{
    if (publisher != nil)
    {
        self.detailItem.publisher = publisher;
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
    }
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - Seller Selection Delegate Method

-(void) sellerViewController:(SellerViewController *)controller didSelectSeller:(Seller*)seller
{
    if (seller != nil)
    {
        self.detailItem.boughtFrom = seller;
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
    }
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - Collection Selection Delegate Method

-(void) collectionViewController:(CollectionViewController *)controller didSelectCollection:(Collection *)collection
{
    if (collection != nil)
    {
        [self.detailItem addCollectionsObject:collection];
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
    }
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - New Award Handling

-(void) newAwardViewController:(NewAwardViewController*)controller didFinishWithSave:(BOOL)save
{
    if (save)
    {
        [self.detailItem addAwardsObject:controller.detailItem];
        
        if (![ContextUtil saveContext:self.detailItem.managedObjectContext])
        {
            // Didn't save, so don't dismiss the modal view.
            return;
        }
    }
    else
    {
        // Canceled the insert, remove the managed object.
        [self.detailItem removeAwardsObject:controller.detailItem];
        [self.detailItem.managedObjectContext deleteObject:controller.detailItem];
    }
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - New Point Handling

-(void) newPointViewController:(NewPointViewController*)controller didFinishWithSave:(BOOL)save
{
    if (save)
    {
        [self.detailItem addPointsObject:controller.detailItem];
        
        if (![ContextUtil saveContext:self.detailItem.managedObjectContext])
        {
            // Didn't save, so don't dismiss the modal view.
            return;
        }
    }
    else
    {
        // Canceled the insert, remove the managed object.
        [self.detailItem removePointsObject:controller.detailItem];
        [self.detailItem.managedObjectContext deleteObject:controller.detailItem];
    }
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - Local Helper Methods

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

    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"person.lastName" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedWorkers = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedWorkers objectAtIndex:indexPath.row];
}

-(Award*) sortedAwardFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    if (set.count <= 0 || indexPath.row > set.count - 1)
        return nil;

    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedAwards = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedAwards objectAtIndex:indexPath.row];
}

-(DLPoint*) sortedPointFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    if (set.count <= 0 || indexPath.row > set.count - 1)
        return nil;

    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"issue" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedPoints = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedPoints objectAtIndex:indexPath.row];
}

-(Collection*) sortedCollectionFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    if (set.count <= 0 || indexPath.row > set.count - 1)
        return nil;

    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedCollections = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedCollections objectAtIndex:indexPath.row];
}

-(void) loadPersonViewForPersonType:(PersonType)type
{
    PersonViewController* personViewController = [[PersonViewController alloc] initWithNibName:@"PersonViewController" bundle:nil];
    personViewController.managedObjectContext = self.detailItem.managedObjectContext;
    personViewController.delegate = self;
    personViewController.selectionMode = TRUE;
    personViewController.personSelectionType = type;

	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:personViewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadPublisherView
{
    PublisherViewController* publisherViewController = [[PublisherViewController alloc] initWithStyle:UITableViewStyleGrouped];
    publisherViewController.managedObjectContext = self.detailItem.managedObjectContext;
    publisherViewController.delegate = self;
    publisherViewController.selectionMode = TRUE;
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:publisherViewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadSellerView
{
    SellerViewController* sellerViewController = [[SellerViewController alloc] initWithStyle:UITableViewStyleGrouped];
    sellerViewController.managedObjectContext = self.detailItem.managedObjectContext;
    sellerViewController.delegate = self;
    sellerViewController.selectionMode = TRUE;
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:sellerViewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadNewAwardView
{
    NewAwardViewController* newAwardViewController = [[NewAwardViewController alloc] initWithStyle:UITableViewStyleGrouped];
	newAwardViewController.delegate = self;
	newAwardViewController.detailItem = [Award awardInManagedObjectContext:self.detailItem.managedObjectContext];
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newAwardViewController];
	navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadNewPointView
{
    NewPointViewController* newPointViewController = [[NewPointViewController alloc] initWithStyle:UITableViewStyleGrouped];
	newPointViewController.delegate = self;
	newPointViewController.detailItem = [DLPoint pointInManagedObjectContext:self.detailItem.managedObjectContext];
	
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newPointViewController];
	navController.navigationBar.barStyle = UIBarStyleBlack;
	
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadCollectionView
{
    CollectionViewController* collectionViewController = [[CollectionViewController alloc] initWithNibName:@"CollectionViewController" bundle:nil];
    collectionViewController.managedObjectContext = self.detailItem.managedObjectContext;
	collectionViewController.delegate = self;
    collectionViewController.selectionMode = TRUE;
	
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:collectionViewController];
	navController.navigationBar.barStyle = UIBarStyleBlack;

    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) showLookupViewControllerForLookupType:(LookupType)type
{
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

#pragma mark - Image Handling

-(void) thumbnailButtonPressed:(id)sender
{
    UIButton* button = sender;
    EditableImageAndTextCell* imageCell = (EditableImageAndTextCell*)button.superview.superview;
    thumbnailView = imageCell.thumbnailView;
    
    UIActionSheet* actionSheet;
    
    NSString* cancel = NSLocalizedString(@"Cancel", @"EditableImageAndTextCell action sheet cancel button title.");
    NSString* delete = NSLocalizedString(@"Delete Photo", @"EditableImageAndTextCell action sheet delete photo button title.");
    NSString* take   = NSLocalizedString(@"Take Photo", @"EditableImageAndTextCell action sheet take photo button title.");
    NSString* choose = NSLocalizedString(@"Choose Photo", @"EditableImageAndTextCell action sheet choose photo button title.");
    
    if (button.enabled)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            // Camera available.
            if (self.detailItem.thumbnail != nil)
            {
                // Image already exists, so add the edit and delete options.
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancel destructiveButtonTitle:delete otherButtonTitles:take, choose, nil];
            }
            else
            {
                // Just the take photo and choose photo options.
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancel destructiveButtonTitle:nil otherButtonTitles:take, choose, nil];
            }
        }
        else
        {
            // No camera available.
            if (self.detailItem.thumbnail != nil)
            {
                // Image already exists, so add the edit and delete options.
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancel destructiveButtonTitle:delete otherButtonTitles:choose, nil];
            }
            else
            {
                // Just the choose photo option.
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancel destructiveButtonTitle:nil otherButtonTitles:choose, nil];
            }
        }
        
        [actionSheet showInView:self.view];
    }
}

-(void) actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* cancel = NSLocalizedString(@"Cancel", @"EditableImageAndTextCell action sheet cancel button title.");
    NSString* delete = NSLocalizedString(@"Delete Photo", @"EditableImageAndTextCell action sheet delete photo button title.");
    NSString* take   = NSLocalizedString(@"Take Photo", @"EditableImageAndTextCell action sheet take photo button title.");
    NSString* choose = NSLocalizedString(@"Choose Photo", @"EditableImageAndTextCell action sheet choose photo button title.");
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:cancel])
    {
        return;
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:delete])
    {
        self.detailItem.thumbnail = nil;
        [self.detailItem.managedObjectContext deleteObject:self.detailItem.photo];
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
        [self.tableView reloadData];
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:take])
    {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.navigationController presentModalViewController:picker animated:YES];
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:choose])
    {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.navigationController presentModalViewController:picker animated:YES];
    }
}

-(void) imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
	// If the Book already has a photo, delete it.
	if (self.detailItem.photo)
    {
		[self.detailItem.managedObjectContext deleteObject:self.detailItem.photo];
	}
	
	// Create a new photo object and set the image.
	Photo* photo = [Photo photoInManagedObjectContext:self.detailItem.managedObjectContext];
    UIImage* selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	photo.image = selectedImage;
	
	// Associate the photo object with the book.
	self.detailItem.photo = photo;	
	
	// Create a thumbnail version of the image for the book object.
    CGRect thumbnailRect = CGRectMake(0, 0, 175, 260);
    
	UIGraphicsBeginImageContext(thumbnailRect.size);
	[selectedImage drawInRect:thumbnailRect];
	self.detailItem.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    thumbnailView.image = self.detailItem.thumbnail;
	UIGraphicsEndImageContext();
    
	[ContextUtil saveContext:self.detailItem.managedObjectContext];
	
    [self dismissModalViewControllerAnimated:YES];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
	// The user canceled -- simply dismiss the image picker.
	[self dismissModalViewControllerAnimated:YES];
}

@end
