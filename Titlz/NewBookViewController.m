//
//  NewBookViewController.m
//  Titlz
//
//  Created by David Lains on 1/2/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "NewBookViewController.h"
#import "EditableTextCell.h"
#import "Book.h"

@implementation NewBookViewController

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

    self.title = NSLocalizedString(@"New Book", @"NewBookViewController header bar title.");
    
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

-(BOOL) textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField*)textField
{
    switch (textField.tag)
    {
        case BookTitleRow:
            self.detailItem.title = textField.text;
            break;
        case BookFormatRow:
            self.detailItem.format = textField.text;
            break;
        case BookEditionRow:
            self.detailItem.edition = textField.text;
            break;
        case BookPrintingRow:
            self.detailItem.printing = [NSNumber numberWithInt:[textField.text intValue]];
            break;
        case BookIsbnRow:
            self.detailItem.isbn = textField.text;
            break;
        case BookPagesRow:
            self.detailItem.pages = [NSNumber numberWithInt:[textField.text intValue]];
            break;
        case BookReleaseDateRow:
        case BookPurchaseDateRow:
            break;
        case BookOriginalPriceRow:
            self.detailItem.originalPrice = [NSDecimalNumber decimalNumberWithString:textField.text];
            break;
        case BookPricePaidRow:
            self.detailItem.pricePaid = [NSDecimalNumber decimalNumberWithString:textField.text];
            break;
        case BookCurrentValueRow:
            self.detailItem.currentValue = [NSDecimalNumber decimalNumberWithString:textField.text];
            break;
        case BookBookConditionRow:
            self.detailItem.bookCondition = textField.text;
            break;
        case BookJacketConditionRow:
            self.detailItem.jacketCondition = textField.text;
            break;
        case BookNumberRow:
            self.detailItem.number = [NSNumber numberWithInt:[textField.text intValue]];
            break;
        case BookPrintRunRow:
            self.detailItem.printRun = [NSNumber numberWithInt:[textField.text intValue]];
            break;
        case BookCommentsRow:
            self.detailItem.comments = textField.text;
            break;
        default:
            DLog(@"Invalid NewBookViewController textField.tag value found: %i.", textField.tag);
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
        case BookReleaseDateRow:
            self.detailItem.releaseDate = datePicker.date;
            releaseDateTextField.text = [formatter stringFromDate:datePicker.date];
            break;
        case BookPurchaseDateRow:
            self.detailItem.purchaseDate = datePicker.date;
            purchaseDateTextField.text = [formatter stringFromDate:datePicker.date];
            break;
        default:
            break;
    }
}

-(IBAction) cancel:(id)sender
{
    [self.delegate newBookViewController:self didFinishWithSave:NO];
}

-(IBAction) save:(id)sender
{
    [self.delegate newBookViewController:self didFinishWithSave:YES];
}

// Customize the number of sections in the table view.
-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return BookDataSectionRowCount;
}

// Customize the appearance of table view cells.
-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.textField.inputView = nil;
    cell.textField.keyboardType = UIKeyboardTypeDefault;
    cell.textField.text = @"";
    
    // Create the date picker to use for the releaseDate field.
    UIDatePicker* datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    
    // Create a localized currency symbol to use in the price fields.
    NSString* currencySymbol = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];

    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.enabled = NO;
    }
    
    switch (indexPath.row)
    {
        case BookTitleRow:
            cell.fieldLabel.text = NSLocalizedString(@"Title", @"NewBookViewController title data field label.");
            cell.textField.text = self.detailItem.title;
            cell.textField.tag = BookTitleRow;
            break;
        case BookFormatRow:
            cell.fieldLabel.text = NSLocalizedString(@"Format", @"NewBookViewController format data field label.");
            cell.textField.text = self.detailItem.format;
            cell.textField.tag = BookFormatRow;
            break;
        case BookEditionRow:
            cell.fieldLabel.text = NSLocalizedString(@"Edition", @"NewBookViewController edition data field label.");
            cell.textField.text = self.detailItem.edition;
            cell.textField.tag = BookEditionRow;
            break;
        case BookPrintingRow:
            cell.fieldLabel.text = NSLocalizedString(@"Printing", @"NewBookViewController printing data field label.");
            cell.textField.text = (self.detailItem.printing == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.printing intValue]];
            cell.textField.tag = BookPrintingRow;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case BookIsbnRow:
            cell.fieldLabel.text = NSLocalizedString(@"ISBN", @"NewBookViewController isbn data field label.");
            cell.textField.text = self.detailItem.isbn;
            cell.textField.tag = BookIsbnRow;
            cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        case BookPagesRow:
            cell.fieldLabel.text = NSLocalizedString(@"Pages", @"NewBookViewController pages data field label.");
            cell.textField.text = (self.detailItem.pages == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.pages intValue]];
            cell.textField.tag = BookPagesRow;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case BookReleaseDateRow:
            cell.fieldLabel.text = NSLocalizedString(@"Released", @"NewBookViewController releaseDate data field label.");
            releaseDateTextField = cell.textField;
            cell.textField.tag = BookReleaseDateRow;
            datePicker.tag = BookReleaseDateRow;
            cell.textField.inputView = datePicker;
            cell.textField.text = [formatter stringFromDate:self.detailItem.releaseDate];
            break;
        case BookPurchaseDateRow:
            cell.fieldLabel.text = NSLocalizedString(@"Puchased", @"NewBookViewController purchaseDate data field label.");
            purchaseDateTextField = cell.textField;
            cell.textField.tag = BookPurchaseDateRow;
            datePicker.tag = BookPurchaseDateRow;
            cell.textField.inputView = datePicker;
            cell.textField.text = [formatter stringFromDate:self.detailItem.releaseDate];
            break;
        case BookOriginalPriceRow:
            cell.fieldLabel.text = NSLocalizedString(@"Original Price", @"NewBookViewController originalPrice data field label.");
            cell.textField.text = (self.detailItem.originalPrice == nil) ? @"" : [NSString stringWithFormat:@"%@%1.2f", currencySymbol, [self.detailItem.originalPrice floatValue]];
            cell.textField.tag = BookOriginalPriceRow;
            cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case BookPricePaidRow:
            cell.fieldLabel.text = NSLocalizedString(@"Price Paid", @"NewBookViewController pricePaid data field label.");
            cell.textField.text = (self.detailItem.pricePaid == nil) ? @"" : [NSString stringWithFormat:@"%@%1.2f", currencySymbol, [self.detailItem.pricePaid floatValue]];
            cell.textField.tag = BookPricePaidRow;
            cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case BookCurrentValueRow:
            cell.fieldLabel.text = NSLocalizedString(@"Current Value", @"NewBookViewController currentValue data field label.");
            cell.textField.text = (self.detailItem.currentValue == nil) ? @"" : [NSString stringWithFormat:@"%@%1.2f", currencySymbol, [self.detailItem.currentValue floatValue]];
            cell.textField.tag = BookCurrentValueRow;
            cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case BookBookConditionRow:
            cell.fieldLabel.text = NSLocalizedString(@"Book Condition", @"NewBookViewController bookCondition data field label.");
            cell.textField.text = self.detailItem.bookCondition;
            cell.textField.tag = BookBookConditionRow;
            break;
        case BookJacketConditionRow:
            cell.fieldLabel.text = NSLocalizedString(@"Jacket Condition", @"NewBookViewController jacketCondition data field label.");
            cell.textField.text = self.detailItem.jacketCondition;
            cell.textField.tag = BookJacketConditionRow;
            break;
        case BookNumberRow:
            cell.fieldLabel.text = NSLocalizedString(@"Number", @"NewBookViewController number data field label.");
            cell.textField.text = (self.detailItem.number == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.number intValue]];
            cell.textField.tag = BookNumberRow;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case BookPrintRunRow:
            cell.fieldLabel.text = NSLocalizedString(@"Print Run", @"NewBookViewController printRun data field label.");
            cell.textField.text = (self.detailItem.printRun == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.printRun intValue]];
            cell.textField.tag = BookPrintRunRow;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case BookCommentsRow:
            cell.fieldLabel.text = NSLocalizedString(@"Comments", @"NewBookViewController comments data field label.");
            cell.textField.text = self.detailItem.comments;
            cell.textField.tag = BookCommentsRow;
            break;
        default:
            DLog(@"Invalid NewBookViewController Data section row found: %i.", indexPath.row);
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
