//
//  BookDetailViewController.m
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import "BookDetailViewController.h"
#import "PersonViewController.h"
#import "PersonDetailViewController.h"
#import "PublisherViewController.h"
#import "PublisherDetailViewController.h"
#import "SellerDetailViewController.h"
#import "AwardDetailViewController.h"
#import "PointDetailViewController.h"
#import "EditableImageAndTextCell.h"
#import "EditableTextCell.h"
#import "Book.h"
#import "Person.h"
#import "Publisher.h"
#import "Seller.h"
#import "Award.h"
#import "DLPoint.h"
#import "Photo.h"

@interface BookDetailViewController ()
-(UITableViewCell*) configureDataCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureAuthorCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureEditorCellAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell*) configureIllustratorCellAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell*) configureContributorCellAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell*) configureSignatureCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureAwardCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configurePointCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configurePublisherCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureBoughtFromCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureCollectionCell;
-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection;
-(Person*) sortedPersonFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(Award*) sortedAwardFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(DLPoint*) sortedPointFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath;
-(void) loadPersonViewControllerForPersonType:(PersonType)type;
-(void) loadPersonDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath;
-(void) loadPublisherView;
-(void) loadPublisherDetailViewForPublisher:(Publisher*)publisher;
-(void) loadSellerView;
-(void) loadSellerDetailViewForSeller:(Seller*)seller;
-(void) showLookupViewControllerForLookupType:(LookupType)type;
-(void) loadNewAwardView;
-(void) loadAwardDetailViewForAwardAtIndexPath:(NSIndexPath*)indexPath;
-(void) loadNewPointView;
-(void) loadPointDetailViewForPointAtIndexPath:(NSIndexPath*)indexPath;

-(IBAction) thumbnailButtonPressed:(id)sender;

@end

@implementation BookDetailViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;

#pragma mark - Initialization

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Book", @"BookDetailViewController header bar title.");
    }
    return self;
}

#pragma mark - View lifecycle

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.detailItem = nil;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewDidUnload
{
    [super viewDidUnload];

    self.detailItem = nil;
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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

-(NSUndoManager*) undoManager
{
    return self.detailItem.managedObjectContext.undoManager;
}

-(void) undoManagerDidUndo:(NSNotification*)notification
{
    [self.tableView reloadData];
	[self updateRightBarButtonItemState];
}

-(void) undoManagerDidRedo:(NSNotification*)notification
{
    [self.tableView reloadData];
	[self updateRightBarButtonItemState];
}

#pragma mark - Button Processing

-(void) doneButtonPressed
{
    // Save the changes.
    [ContextUtil saveContext:self.detailItem.managedObjectContext];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void) cancelButtonPressed
{
    [self becomeFirstResponder];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidBeginEditing:(UITextField*)textField
{
    // Save the textField for updating when the selection is made.
    lookupTextField = textField;
    
    switch (textField.tag)
    {
        case BookFormatRow:
            [self showLookupViewControllerForLookupType:LookupTypeFormat];
            break;
        case BookEditionRow:
            [self showLookupViewControllerForLookupType:LookupTypeEdition];
            break;
        case BookBookConditionRow:
        case BookJacketConditionRow:
            [self showLookupViewControllerForLookupType:LookupTypeCondition];
            break;
        default:
            break;
    }
}

-(BOOL) textFieldShouldEndEditing:(UITextField*)textField
{
    BOOL valid = YES;
    NSError* error;
    NSString* value = textField.text;
    
    switch (textField.tag)
    {
        case BookTitleRow:
            valid = [self.detailItem validateValue:&value forKey:@"title" error:&error];
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
        case BookTitleRow:
            self.detailItem.title = textField.text;
            break;
        case BookFormatRow:
        case BookEditionRow:
            break;
        case BookPrintingRow:
            self.detailItem.printing = ([textField.text length] > 0) ? [NSNumber numberWithInt:[textField.text intValue]] : nil;
            break;
        case BookIsbnRow:
            self.detailItem.isbn = textField.text;
            break;
        case BookPagesRow:
            self.detailItem.pages = ([textField.text length] > 0) ? [NSNumber numberWithInt:[textField.text intValue]] : nil;
            break;
        case BookReleaseDateRow:
        case BookPurchaseDateRow:
            break;
        case BookOriginalPriceRow:
            self.detailItem.originalPrice = ([textField.text length] > 0) ? [NSDecimalNumber decimalNumberWithString:textField.text] : nil;
            break;
        case BookPricePaidRow:
            self.detailItem.pricePaid = ([textField.text length] > 0) ? [NSDecimalNumber decimalNumberWithString:textField.text] : nil;
            break;
        case BookCurrentValueRow:
            self.detailItem.currentValue = ([textField.text length] > 0) ? [NSDecimalNumber decimalNumberWithString:textField.text] : nil;
            break;
        case BookBookConditionRow:
        case BookJacketConditionRow:
            break;
        case BookNumberRow:
            self.detailItem.number = ([textField.text length] > 0) ? [NSNumber numberWithInt:[textField.text intValue]] : nil;
            break;
        case BookPrintRunRow:
            self.detailItem.printRun = ([textField.text length] > 0) ? [NSNumber numberWithInt:[textField.text intValue]] : nil;
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

-(void) lookupViewController:(LookupViewController *)controller didSelectValue:(NSString *)value withLookupType:(LookupType)type
{
    switch (type)
    {
        case LookupTypeEdition:
            self.detailItem.edition = value;
            break;
        case LookupTypeFormat:
            self.detailItem.format = value;
            break;
        case LookupTypeCondition:
            if (lookupTextField.tag == BookBookConditionRow)
                self.detailItem.bookCondition = value;
            else if (lookupTextField.tag == BookJacketConditionRow)
                self.detailItem.jacketCondition = value;
            else
                DLog(@"Invalid textField.tag found for LookupTypeCondition selection: %i.", lookupTextField.tag);
            break;
        default:
            DLog(@"Invalid LookupType found in NewBookViewController::lookupViewController:didSelectValue:withLookupType: %i.", type);
            break;
    }
    
    lookupTextField.text = value;
}

#pragma mark - Table View Methods.

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
	// Hide the back button when editing starts, and show it again when editing finishes.
    [self.navigationItem setHidesBackButton:editing animated:animated];

    NSIndexPath* author      = [NSIndexPath indexPathForRow:self.detailItem.authors.count inSection:BookAuthorSection];
    NSIndexPath* editor      = [NSIndexPath indexPathForRow:self.detailItem.editors.count inSection:BookEditorSection];
    NSIndexPath* illustrator = [NSIndexPath indexPathForRow:self.detailItem.illustrators.count inSection:BookIllustratorSection];
    NSIndexPath* contributor = [NSIndexPath indexPathForRow:self.detailItem.contributors.count inSection:BookContributorSection];
    NSIndexPath* signature   = [NSIndexPath indexPathForRow:self.detailItem.signatures.count inSection:BookSignatureSection];
    NSIndexPath* award       = [NSIndexPath indexPathForRow:self.detailItem.awards.count inSection:BookAwardSection];
    NSIndexPath* point       = [NSIndexPath indexPathForRow:self.detailItem.points.count inSection:BookPointSection];
    NSInteger publisherRow   = (self.detailItem.publisher != nil) ? 1 : 0;
    NSIndexPath* publisher   = [NSIndexPath indexPathForRow:publisherRow inSection:BookPublisherSection];
    NSInteger boughtFromRow  = (self.detailItem.boughtFrom != nil) ? 1 : 0;
    NSIndexPath* boughtFrom  = [NSIndexPath indexPathForRow:boughtFromRow inSection:BookBoughtFromSection];
    NSIndexPath* collection  = [NSIndexPath indexPathForRow:self.detailItem.collections.count inSection:BookCollectionSection];

    NSArray* paths = [NSArray arrayWithObjects:author, editor, illustrator, contributor, signature, award, point, publisher, boughtFrom, collection, nil];

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
        case BookDataSection:
            return BookDataSectionRowCount;
        case BookAuthorSection:
            return self.detailItem.authors.count + insertionRow;
        case BookEditorSection:
            return self.detailItem.editors.count + insertionRow;
        case BookIllustratorSection:
            return self.detailItem.illustrators.count + insertionRow;
        case BookContributorSection:
            return self.detailItem.contributors.count + insertionRow;
        case BookSignatureSection:
            return self.detailItem.signatures.count + insertionRow;
        case BookAwardSection:
            return self.detailItem.awards.count + insertionRow;
        case BookPointSection:
            return self.detailItem.points.count + insertionRow;
        case BookPublisherSection:
            return ((self.detailItem.publisher != nil) ? 1 : 0) + insertionRow;
        case BookBoughtFromSection:
            return ((self.detailItem.boughtFrom != nil) ? 1 : 0) + insertionRow;
        case BookCollectionSection:
            return self.detailItem.collections.count + insertionRow;
        default:
            DLog(@"Invalid BookDetailViewController section found: %i.", section);
            return 0;
    }
}

// Customize the appearance of table view cells.
-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section)
    {
        case BookDataSection:
            cell = [self configureDataCellAtIndexPath:indexPath];
            break;
        case BookAuthorSection:
            cell = [self configureAuthorCellAtIndexPath:indexPath];
            break;
        case BookEditorSection:
            cell = [self configureEditorCellAtIndexPath:indexPath];
            break;
        case BookIllustratorSection:
            cell = [self configureIllustratorCellAtIndexPath:indexPath];
            break;
        case BookContributorSection:
            cell = [self configureContributorCellAtIndexPath:indexPath];
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
        case BookPublisherSection:
            cell = [self configurePublisherCellAtIndexPath:indexPath];
            break;
        case BookBoughtFromSection:
            cell = [self configureBoughtFromCellAtIndexPath:indexPath];
            break;
        case BookCollectionSection:
            cell = [self configureCollectionCell];
            break;
        default:
            DLog(@"Invalid BookDetailViewController section found: %i.", indexPath.section);
            break;
    }
    
    return cell;
}

// Editing styles per row.
-(UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case BookDataSection:
            return UITableViewCellEditingStyleNone;
        case BookAuthorSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.authors];
        case BookEditorSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.editors];
        case BookIllustratorSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.illustrators];
        case BookContributorSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.contributors];
        case BookSignatureSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.signatures];
        case BookAwardSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.awards];
        case BookPointSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.points];
        case BookPublisherSection:
            return (self.detailItem.publisher != nil) ? ((indexPath.row == 1) ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete) : UITableViewCellEditingStyleInsert;
        case BookBoughtFromSection:
            return (self.detailItem.boughtFrom != nil) ? ((indexPath.row == 1) ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete) : UITableViewCellEditingStyleInsert;
        case BookCollectionSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.collections];
        default:
            DLog(@"Invalid BookDetailViewController section found: %i.", indexPath.section);
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

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger publisherInsertionRow = (self.detailItem.publisher != nil) ? 1 : 0;
    NSInteger boughtFromInsertionRow = (self.detailItem.boughtFrom != nil) ? 1 : 0;

    switch (indexPath.section)
    {
        case BookDataSection:
            break;
        case BookAuthorSection:
            if (indexPath.row == self.detailItem.authors.count)
                [self loadPersonViewControllerForPersonType:Author];
            else
                [self loadPersonDetailViewForPersonType:Author atIndexPath:indexPath];
            break;
        case BookEditorSection:
            if (indexPath.row == self.detailItem.editors.count)
                [self loadPersonViewControllerForPersonType:Editor];
            else
                [self loadPersonDetailViewForPersonType:Editor atIndexPath:indexPath];
            break;
        case BookIllustratorSection:
            if (indexPath.row == self.detailItem.illustrators.count)
                [self loadPersonViewControllerForPersonType:Illustrator];
            else
                [self loadPersonDetailViewForPersonType:Illustrator atIndexPath:indexPath];
            break;
        case BookContributorSection:
            if (indexPath.row == self.detailItem.contributors.count)
                [self loadPersonViewControllerForPersonType:Contributor];
            else
                [self loadPersonDetailViewForPersonType:Contributor atIndexPath:indexPath];
            break;
        case BookSignatureSection:
            if (indexPath.row == self.detailItem.signatures.count)
                [self loadPersonViewControllerForPersonType:Signature];
            else
                [self loadPersonDetailViewForPersonType:Signature atIndexPath:indexPath];
            break;
        case BookAwardSection:
            if (indexPath.row == self.detailItem.awards.count)
                [self loadNewAwardView];
            else
                [self loadAwardDetailViewForAwardAtIndexPath:indexPath];
            break;
        case BookPointSection:
            if (indexPath.row == self.detailItem.points.count)
                [self loadNewPointView];
            else
                [self loadPointDetailViewForPointAtIndexPath:indexPath];
            break;
        case BookPublisherSection:
            if (indexPath.row == publisherInsertionRow)
                [self loadPublisherView];
            else
                [self loadPublisherDetailViewForPublisher:self.detailItem.publisher];
            break;
        case BookBoughtFromSection:
            if (indexPath.row == boughtFromInsertionRow)
                [self loadSellerView];
            else
                [self loadSellerDetailViewForSeller:self.detailItem.boughtFrom];
            break;
        case BookCollectionSection:
            break;
        default:
            DLog(@"Invalid BookDetailViewController section found: %i.", indexPath.section);
            break;
    }
}

-(void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        switch (indexPath.section)
        {
            case BookDataSection:
                // Never delete the data section rows.
                break;
            case BookAuthorSection:
                [self.detailItem removeAuthorsObject:[self sortedPersonFromSet:self.detailItem.authors atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case BookEditorSection:
                [self.detailItem removeEditorsObject:[self sortedPersonFromSet:self.detailItem.editors atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case BookIllustratorSection:
                [self.detailItem removeIllustratorsObject:[self sortedPersonFromSet:self.detailItem.illustrators atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case BookContributorSection:
                [self.detailItem removeContributorsObject:[self sortedPersonFromSet:self.detailItem.contributors atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case BookSignatureSection:
                [self.detailItem removeSignaturesObject:[self sortedPersonFromSet:self.detailItem.signatures atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case BookAwardSection:
                [self.detailItem removeAwardsObject:[self sortedAwardFromSet:self.detailItem.awards atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case BookPointSection:
                [self.detailItem removePointsObject:[self sortedPointFromSet:self.detailItem.points atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case BookPublisherSection:
                self.detailItem.publisher = nil;
                [self deleteRowAtIndexPath:indexPath];
                break;
            case BookBoughtFromSection:
                self.detailItem.boughtFrom = nil;
                [self deleteRowAtIndexPath:indexPath];
                break;
            case BookCollectionSection:
                break;
            default:
                break;
        }
        
        // Save the context.
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
    }   
}

// Section headers.
-(NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* header = nil;
    
    switch (section)
    {
        case BookDataSection:
            break;
        case BookAuthorSection:
            if (self.detailItem.authors.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Authors", @"BookDetailViewController Authors section header.");
            }
            break;
        case BookEditorSection:
            if (self.detailItem.editors.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Editors", @"BookDetailViewController Editors section header.");
            }
            break;
        case BookIllustratorSection:
            if (self.detailItem.illustrators.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Illustrators", @"BookDetailViewController Illustrators section header.");
            }
            break;
        case BookContributorSection:
            if (self.detailItem.contributors.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Contributors", @"BookDetailViewController Contributors section header.");
            }
            break;
        case BookSignatureSection:
            if (self.detailItem.signatures.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Signatures", @"BookDetailViewController Signatures section header.");
            }
            break;
        case BookAwardSection:
            if (self.detailItem.awards.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Awards", @"BookDetailViewController Awards section header.");
            }
            break;
        case BookPointSection:
            if (self.detailItem.points.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Points", @"BookDetailViewController Points section header.");
            }
            break;
        case BookPublisherSection:
            if (self.detailItem.publisher || self.editing)
            {
                header = NSLocalizedString(@"Publisher", @"BookDetailViewController Publisher section header.");
            }
            break;
        case BookBoughtFromSection:
            if (self.detailItem.boughtFrom || self.editing)
            {
                header = NSLocalizedString(@"Bought From", @"BookDetailViewController Bought From section header.");
            }
            break;
        case BookCollectionSection:
            if (self.detailItem.collections.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Collections", @"BookDetailViewController Collections section header.");
            }
            break;
        default:
            DLog(@"Invalid BookDetailViewController section found: %i.", section);
            break;
    }
    
    return header;
}

-(NSIndexPath*) tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (!self.editing)
    {
        switch (indexPath.section)
        {
            case BookDataSection:
                return nil;
            case BookAuthorSection:
            case BookEditorSection:
            case BookIllustratorSection:
            case BookContributorSection:
            case BookSignatureSection:
            case BookAwardSection:
            case BookPointSection:
            case BookPublisherSection:
            case BookBoughtFromSection:
            case BookCollectionSection:
                return indexPath;
            default:
                DLog(@"Invalid BookDetailViewController section found: %i.", indexPath.section);
                return nil;
        }
    }
    else
    {
        return indexPath;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == BookDataSection && indexPath.row == BookTitleRow)
    {
        return 130.0f;
    }
    else
    {
        return 44.0f;
    }
}

-(BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case BookDataSection:
            return NO;
        default:
            return YES;
    }
}

-(UITableViewCell*) configureDataCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* result = nil;
    EditableTextCell* textCell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    EditableImageAndTextCell* imageCell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableImageAndTextCell"];
    
    // Create the date picker to use for the date fields.
    UIDatePicker* datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];

    // Create the date formatter to display the date data.
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    
    // Create a localized currency symbol to use in the price fields.
    NSString* currencySymbol = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    
    if(textCell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        textCell = [topLevelObjects objectAtIndex:0];
        textCell.textField.enabled = NO;
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    textCell.textField.inputView = nil;
    textCell.textField.keyboardType = UIKeyboardTypeDefault;
    textCell.textField.text = @"";

    if(imageCell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableImageAndTextCell" owner:self options:nil];
        imageCell = [topLevelObjects objectAtIndex:0];
        imageCell.textField.enabled = NO;
        imageCell.thumbnailButton.enabled = NO;
    }

    switch (indexPath.row)
    {
        case BookTitleRow:
            if (self.detailItem.thumbnail == nil)
                imageCell.thumbnailView.image = [UIImage imageNamed:@"BookCover-leather-large.jpg"];
            else
                imageCell.thumbnailView.image = self.detailItem.thumbnail;
            [imageCell.thumbnailButton addTarget:self action:@selector(thumbnailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            //imageCell.fieldLabel.text = NSLocalizedString(@"Title", @"BookDetailViewController title data field label.");
            imageCell.textField.text = self.detailItem.title;
            imageCell.textField.tag = BookTitleRow;
            result = imageCell;
            break;
        case BookFormatRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Format", @"BookDetailViewController format data field label.");
            textCell.textField.text = self.detailItem.format;
            textCell.textField.tag = BookFormatRow;
            result = textCell;
            break;
        case BookEditionRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Edition", @"BookDetailViewController edition data field label.");
            textCell.textField.text = self.detailItem.edition;
            textCell.textField.tag = BookEditionRow;
            result = textCell;
            break;
        case BookPrintingRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Printing", @"BookDetailViewController printing data field label.");
            textCell.textField.text = (self.detailItem.printing == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.printing intValue]];
            textCell.textField.tag = BookPrintingRow;
            textCell.textField.keyboardType = UIKeyboardTypeNumberPad;
            result = textCell;
            break;
        case BookIsbnRow:
            textCell.fieldLabel.text = NSLocalizedString(@"ISBN", @"BookDetailViewController isbn data field label.");
            textCell.textField.text = self.detailItem.isbn;
            textCell.textField.tag = BookIsbnRow;
            textCell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            result = textCell;
            break;
        case BookPagesRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Pages", @"BookDetailViewController pages data field label.");
            textCell.textField.text = (self.detailItem.pages == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.pages intValue]];
            textCell.textField.tag = BookPagesRow;
            textCell.textField.keyboardType = UIKeyboardTypeNumberPad;
            result = textCell;
            break;
        case BookReleaseDateRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Released", @"BookDetailViewController releaseDate data field label.");
            releaseDateTextField = textCell.textField;
            textCell.textField.tag = BookReleaseDateRow;
            datePicker.tag = BookReleaseDateRow;
            textCell.textField.inputView = datePicker;
            textCell.textField.text = [formatter stringFromDate:self.detailItem.releaseDate];
            result = textCell;
            break;
        case BookPurchaseDateRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Puchased", @"BookDetailViewController purchaseDate data field label.");
            purchaseDateTextField = textCell.textField;
            textCell.textField.tag = BookPurchaseDateRow;
            datePicker.tag = BookPurchaseDateRow;
            textCell.textField.inputView = datePicker;
            textCell.textField.text = [formatter stringFromDate:self.detailItem.releaseDate];
            result = textCell;
            break;
        case BookOriginalPriceRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Original Price", @"BookDetailViewController originalPrice data field label.");
            textCell.textField.text = (self.detailItem.originalPrice == nil) ? @"" : [NSString stringWithFormat:@"%@%1.2f", currencySymbol, [self.detailItem.originalPrice floatValue]];
            textCell.textField.tag = BookOriginalPriceRow;
            textCell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            result = textCell;
            break;
        case BookPricePaidRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Price Paid", @"BookDetailViewController pricePaid data field label.");
            textCell.textField.text = (self.detailItem.pricePaid == nil) ? @"" : [NSString stringWithFormat:@"%@%1.2f", currencySymbol, [self.detailItem.pricePaid floatValue]];
            textCell.textField.tag = BookPricePaidRow;
            textCell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            result = textCell;
            break;
        case BookCurrentValueRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Current Value", @"BookDetailViewController currentValue data field label.");
            textCell.textField.text = (self.detailItem.currentValue == nil) ? @"" : [NSString stringWithFormat:@"%@%1.2f", currencySymbol, [self.detailItem.currentValue floatValue]];
            textCell.textField.tag = BookCurrentValueRow;
            textCell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            result = textCell;
            break;
        case BookBookConditionRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Book Condition", @"BookDetailViewController bookCondition data field label.");
            textCell.textField.text = self.detailItem.bookCondition;
            textCell.textField.tag = BookBookConditionRow;
            result = textCell;
            break;
        case BookJacketConditionRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Jacket Condition", @"BookDetailViewController jacketCondition data field label.");
            textCell.textField.text = self.detailItem.jacketCondition;
            textCell.textField.tag = BookJacketConditionRow;
            result = textCell;
            break;
        case BookNumberRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Number", @"BookDetailViewController number data field label.");
            textCell.textField.text = (self.detailItem.number == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.number intValue]];
            textCell.textField.tag = BookNumberRow;
            textCell.textField.keyboardType = UIKeyboardTypeNumberPad;
            result = textCell;
            break;
        case BookPrintRunRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Print Run", @"BookDetailViewController printRun data field label.");
            textCell.textField.text = (self.detailItem.printRun == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.printRun intValue]];
            textCell.textField.tag = BookPrintRunRow;
            textCell.textField.keyboardType = UIKeyboardTypeNumberPad;
            result = textCell;
            break;
        case BookCommentsRow:
            textCell.fieldLabel.text = NSLocalizedString(@"Comments", @"BookDetailViewController comments data field label.");
            textCell.textField.text = self.detailItem.comments;
            textCell.textField.tag = BookCommentsRow;
            result = textCell;
            break;
        default:
            DLog(@"Invalid BookDetailViewController Data section row found: %i.", indexPath.row);
            break;
    }
    
    return result;
}

-(UITableViewCell*) configureAuthorCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"AuthorCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.authors.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Author...", @"BookDetailViewController add Author insertion row text.");
    }
    else
    {
        Person* person = [self sortedPersonFromSet:self.detailItem.authors atIndexPath:indexPath];
        cell.textLabel.text = person.fullName;
    }
    
    return cell;
}

-(UITableViewCell*) configureEditorCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"EditorCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.editors.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Editor...", @"BookDetailViewController add Editor insertion row text.");
    }
    else
    {
        Person* person = [self sortedPersonFromSet:self.detailItem.editors atIndexPath:indexPath];
        cell.textLabel.text = person.fullName;
    }
    
    return cell;
}

-(UITableViewCell*) configureIllustratorCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"IllustratorCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.illustrators.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Illustrator...", @"BookDetailViewController add Illustrator insertion row text.");
    }
    else
    {
        Person* person = [self sortedPersonFromSet:self.detailItem.illustrators atIndexPath:indexPath];
        cell.textLabel.text = person.fullName;
    }
    
    return cell;
}

-(UITableViewCell*) configureContributorCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ContributorCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.contributors.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Contributor...", @"BookDetailViewController add Contributor insertion row text.");
    }
    else
    {
        Person* person = [self sortedPersonFromSet:self.detailItem.contributors atIndexPath:indexPath];
        cell.textLabel.text = person.fullName;
    }
    return cell;
}

-(UITableViewCell*) configureSignatureCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"SignatureCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.signatures.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Signature...", @"BookDetailViewController add Signature insertion row text.");
    }
    else
    {
        Person* person = [self sortedPersonFromSet:self.detailItem.signatures atIndexPath:indexPath];
        cell.textLabel.text = person.fullName;
    }
    return cell;
}

-(UITableViewCell*) configureAwardCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"AwardCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.awards.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Award...", @"BookDetailViewController add Award insertion row text.");
    }
    else
    {
        Award* award = [self sortedAwardFromSet:self.detailItem.awards atIndexPath:indexPath];
        cell.textLabel.text = award.name;
    }
    
    return cell;
}

-(UITableViewCell*) configurePointCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"PointCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.points.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Point...", @"BookDetailViewController add Point insertion row text.");
    }
    else
    {
        DLPoint* point = [self sortedPointFromSet:self.detailItem.points atIndexPath:indexPath];
        cell.textLabel.text = point.issue;
    }
    
    return cell;
}

-(UITableViewCell*) configurePublisherCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"PublisherCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSInteger insertionRow = (self.detailItem.publisher != nil) ? 1 : 0;
    
    if (self.editing && indexPath.row == insertionRow)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Add Publisher...", @"BookDetailViewController add Publisher insertion row text.");
        }
        else
        {
            cell.textLabel.text = NSLocalizedString(@"Replace Publisher...", @"BookDetailViewController replace Publisher insertion row text.");
        }
    }
    else
    {
        cell.textLabel.text = self.detailItem.publisher.name;
    }
    
    return cell;
}

-(UITableViewCell*) configureBoughtFromCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"BoughtFromCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSInteger insertionRow = (self.detailItem.boughtFrom != nil) ? 1 : 0;
    
    if (self.editing && indexPath.row == insertionRow)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Add Seller...", @"BookDetailViewController add Seller insertion row text.");
        }
        else
        {
            cell.textLabel.text = NSLocalizedString(@"Replace Seller...", @"BookDetailViewController replace Seller insertion row text.");
        }
    }
    else
    {
        cell.textLabel.text = self.detailItem.boughtFrom.name;
    }
    
    return cell;
}

-(UITableViewCell*) configureCollectionCell
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing)
        cell.textLabel.text = NSLocalizedString(@"Add Collection...", @"TitleDetailViewController add Collection insertion row text.");
    
    return cell;
}

#pragma mark - Person Selection Delegate Method

-(void) personViewController:(PersonViewController *)controller didSelectPerson:(Person *)person withPersonType:(PersonType)type
{
    switch (type)
    {
        case Author:
            [self.detailItem addAuthorsObject:person];
            break;
        case Editor:
            [self.detailItem addEditorsObject:person];
            break;
        case Illustrator:
            [self.detailItem addIllustratorsObject:person];
            break;
        case Contributor:
            [self.detailItem addContributorsObject:person];
            break;
        case Signature:
            [self.detailItem addSignaturesObject:person];
            break;
        default:
            DLog(@"Invalid PersonType found in TitleDetailViewController: %i.", type);
            break;
    }
    
    [ContextUtil saveContext:self.detailItem.managedObjectContext];

    [self.tableView reloadData];
}

#pragma mark - Publisher Selection Delegate Method

-(void) publisherViewController:(PublisherViewController *)controller didSelectPublisher:(Publisher *)publisher
{
    self.detailItem.publisher = publisher;
    [ContextUtil saveContext:self.detailItem.managedObjectContext];
    
    [self.tableView reloadData];
}

#pragma mark - Seller Selection Delegate Method

-(void) sellerViewController:(SellerViewController *)controller didSelectSeller:(Seller*)seller
{
    self.detailItem.boughtFrom = seller;
    [ContextUtil saveContext:self.detailItem.managedObjectContext];
    
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

    [self.tableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
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
    
    [self.tableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Local Helper Methods

-(Person*) sortedPersonFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedPeople = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedPeople objectAtIndex:indexPath.row];
}

-(Award*) sortedAwardFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedAwards = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedAwards objectAtIndex:indexPath.row];
}

-(DLPoint*) sortedPointFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"issue" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedPoints = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedPoints objectAtIndex:indexPath.row];
}

-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    NSArray* paths = [NSArray arrayWithObjects:path, nil];
    
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
}

-(void) loadPersonViewControllerForPersonType:(PersonType)type
{
    PersonViewController* personViewController = [[PersonViewController alloc] initWithNibName:@"PersonViewController" bundle:nil];
    personViewController.delegate = self;
    personViewController.managedObjectContext = self.detailItem.managedObjectContext;
    personViewController.selectionMode = TRUE;
    personViewController.personSelectionType = type;
    
    [self.navigationController pushViewController:personViewController animated:YES];
}

-(void) loadPersonDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath
{
    PersonDetailViewController* personDetailViewController = [[PersonDetailViewController alloc] initWithNibName:@"PersonDetailViewController" bundle:nil];
    Person* selectedPerson = nil;
    
    switch (type)
    {
        case Author:
            selectedPerson = [self sortedPersonFromSet:self.detailItem.authors atIndexPath:indexPath];
            break;
        case Editor:
            selectedPerson = [self sortedPersonFromSet:self.detailItem.editors atIndexPath:indexPath];
            break;
        case Illustrator:
            selectedPerson = [self sortedPersonFromSet:self.detailItem.illustrators atIndexPath:indexPath];
            break;
        case Contributor:
            selectedPerson = [self sortedPersonFromSet:self.detailItem.contributors atIndexPath:indexPath];
            break;
        case Signature:
            selectedPerson = [self sortedPersonFromSet:self.detailItem.signatures atIndexPath:indexPath];
            break;
        default:
            break;
    }
    
    if (selectedPerson)
    {
        personDetailViewController.detailItem = selectedPerson;
        [self.navigationController pushViewController:personDetailViewController animated:YES];
    }
}

-(void) loadPublisherView
{
    PublisherViewController* publisherViewController = [[PublisherViewController alloc] initWithNibName:@"PublisherViewController" bundle:nil];
    publisherViewController.delegate = self;
    publisherViewController.managedObjectContext = self.detailItem.managedObjectContext;
    publisherViewController.selectionMode = TRUE;
    
    [self.navigationController pushViewController:publisherViewController animated:YES];
}

-(void) loadPublisherDetailViewForPublisher:(Publisher*)publisher
{
    if (publisher)
    {
        PublisherDetailViewController* publisherDetailViewController = [[PublisherDetailViewController alloc] initWithNibName:@"PublisherDetailViewController" bundle:nil];
        publisherDetailViewController.detailItem = publisher;
        [self.navigationController pushViewController:publisherDetailViewController animated:YES];
    }
}

-(void) loadSellerView
{
    SellerViewController* sellerViewController = [[SellerViewController alloc] initWithNibName:@"SellerViewController" bundle:nil];
    sellerViewController.delegate = self;
    sellerViewController.managedObjectContext = self.detailItem.managedObjectContext;
    sellerViewController.selectionMode = TRUE;
    
    [self.navigationController pushViewController:sellerViewController animated:YES];
}

-(void) loadSellerDetailViewForSeller:(Seller*)seller
{
    if (seller)
    {
        SellerDetailViewController* sellerDetailViewController = [[SellerDetailViewController alloc] initWithNibName:@"SellerDetailViewController" bundle:nil];
        sellerDetailViewController.detailItem = seller;
        [self.navigationController pushViewController:sellerDetailViewController animated:YES];
    }
}

-(void) showLookupViewControllerForLookupType:(LookupType)type
{
    LookupViewController* controller = [[LookupViewController alloc] initWithLookupType:type];
    controller.delegate = self;
    controller.managedObjectContext = self.detailItem.managedObjectContext;
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadNewAwardView
{
    NewAwardViewController* newAwardViewController = [[NewAwardViewController alloc] initWithStyle:UITableViewStyleGrouped];
	newAwardViewController.delegate = self;
	newAwardViewController.detailItem = [Award awardInManagedObjectContext:self.detailItem.managedObjectContext];
	
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newAwardViewController];
	
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadAwardDetailViewForAwardAtIndexPath:(NSIndexPath*)indexPath
{
    AwardDetailViewController* awardDetailViewController = [[AwardDetailViewController alloc] initWithNibName:@"AwardDetailViewController" bundle:nil];
    Award* selectedAward = [self sortedAwardFromSet:self.detailItem.awards atIndexPath:indexPath];
    
    if (selectedAward)
    {
        awardDetailViewController.detailItem = selectedAward;
        [self.navigationController pushViewController:awardDetailViewController animated:YES];
    }
}

-(void) loadNewPointView
{
    NewPointViewController* newPointViewController = [[NewPointViewController alloc] initWithStyle:UITableViewStyleGrouped];
	newPointViewController.delegate = self;
	newPointViewController.detailItem = [DLPoint pointInManagedObjectContext:self.detailItem.managedObjectContext];
	
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newPointViewController];
	
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadPointDetailViewForPointAtIndexPath:(NSIndexPath*)indexPath
{
    PointDetailViewController* pointDetailViewController = [[PointDetailViewController alloc] initWithNibName:@"PointDetailViewController" bundle:nil];
    DLPoint* selectedPoint = [self sortedPointFromSet:self.detailItem.points atIndexPath:indexPath];
    
    if (selectedPoint)
    {
        pointDetailViewController.detailItem = selectedPoint;
        [self.navigationController pushViewController:pointDetailViewController animated:YES];
    }
}
#pragma mark - Image handling

-(void) thumbnailButtonPressed:(id)sender
{
    UIButton* button = sender;
    UIActionSheet* actionSheet;
    
    NSString* cancel = NSLocalizedString(@"Cancel", @"EditableImageAndTextCell action sheet cancel button title.");
    NSString* delete = NSLocalizedString(@"Delete Photo", @"EditableImageAndTextCell action sheet delete photo button title.");
    NSString* take   = NSLocalizedString(@"Take Photo", @"EditableImageAndTextCell action sheet take photo button title.");
    NSString* choose = NSLocalizedString(@"Choose Photo", @"EditableImageAndTextCell action sheet choose photo button title.");
//    NSString* edit   = NSLocalizedString(@"Edit Photo", @"EditableImageAndTextCell action sheet edit photo button title.");
    
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
//    NSString* edit   = NSLocalizedString(@"Edit Photo", @"EditableImageAndTextCell action sheet edit photo button title.");
    
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
        [self presentModalViewController:picker animated:YES];
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:choose])
    {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:picker animated:YES];
    }

    /*
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:edit])
    {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        [self presentModalViewController:picker animated:YES];
    }
     */
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
