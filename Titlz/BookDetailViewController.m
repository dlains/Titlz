//
//  BookDetailViewController.m
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import "BookDetailViewController.h"
#import "CollectionViewController.h"
#import "CollectionDetailViewController.h"
#import "PersonViewController.h"
#import "PersonDetailViewController.h"
#import "PublisherViewController.h"
#import "PublisherDetailViewController.h"
#import "SellerDetailViewController.h"
#import "AwardDetailViewController.h"
#import "PointDetailViewController.h"
#import "EditableLookupAndTextCell.h"
#import "EditableImageAndTextCell.h"
#import "EditableTextCell.h"
#import "Book.h"
#import "Person.h"
#import "Publisher.h"
#import "Seller.h"
#import "Award.h"
#import "DLPoint.h"
#import "Photo.h"
#import "Collection.h"
#import "Worker.h"

@interface BookDetailViewController ()
-(UITableViewCell*) configureTitleCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureWorkerCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureDetailsCellAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell*) configureInstanceDetailsCellAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell*) configureSignatureCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureAwardCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configurePointCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureCollectionCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection;
-(Person*) sortedPersonFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(Worker*) sortedWorkerFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(Award*) sortedAwardFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(DLPoint*) sortedPointFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(Collection*) sortedCollectionFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath;
-(void) loadPersonViewForPersonType:(PersonType)type;
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
-(void) loadCollectionView;
-(void) loadCollectionDetailViewForCollectionAtIndexPath:(NSIndexPath*)indexPath;

-(void) addWorkerWithTitle:(NSString*)title andPerson:(Person*)person;
-(void) updateWorkerObject:(NSManagedObjectID*)objectId withTitle:(NSString*)title andPerson:(Person*)person;

-(IBAction) thumbnailButtonPressed:(id)sender;
-(IBAction) lookupButtonPressed:(id)sender;

@end

@implementation BookDetailViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;
@synthesize lookupJustFinished = _lookupJustFinished;

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
    if (self.lookupJustFinished)
    {
        self.lookupJustFinished = NO;
        return;
    }
    
    switch (textField.tag)
    {
        case BookWorkerTag:
            lookupTextField = textField;
            [self loadPersonViewForPersonType:Workers];
            break;
        case BookFormatTag:
            lookupTextField = textField;
            [self showLookupViewControllerForLookupType:LookupTypeFormat];
            break;
        case BookEditionTag:
            lookupTextField = textField;
            [self showLookupViewControllerForLookupType:LookupTypeEdition];
            break;
        case BookBookConditionTag:
        case BookJacketConditionTag:
            lookupTextField = textField;
            [self showLookupViewControllerForLookupType:LookupTypeCondition];
            break;
        case BookPublisherTag:
            lookupTextField = textField;
            [self loadPublisherView];
            break;
        case BookBoughtFromTag:
            lookupTextField = textField;
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
            self.detailItem.comments = textField.text;
            break;
        case BookSignatureTag:
        case BookAwardTag:
        case BookPointTag:
        case BookCollectionTag:
            break;
        default:
            DLog(@"Invalid BookDetailViewController textField.tag value found: %i.", textField.tag);
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
        case BookReleaseDateTag:
            self.detailItem.releaseDate = datePicker.date;
            releaseDateTextField.text = [formatter stringFromDate:datePicker.date];
            break;
        case BookPurchaseDateTag:
            self.detailItem.purchaseDate = datePicker.date;
            purchaseDateTextField.text = [formatter stringFromDate:datePicker.date];
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
            DLog(@"Invalid LookupType found in BookDetailViewController::lookupViewController:didSelectValue:withLookupType: %i.", type);
            break;
    }
}

#pragma mark - Table View Methods.

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
	// Hide the back button when editing starts, and show it again when editing finishes.
    [self.navigationItem setHidesBackButton:editing animated:animated];

    NSIndexPath* worker      = [NSIndexPath indexPathForRow:self.detailItem.workers.count inSection:BookWorkersSection];
    NSIndexPath* signature   = [NSIndexPath indexPathForRow:self.detailItem.signatures.count inSection:BookSignatureSection];
    NSIndexPath* award       = [NSIndexPath indexPathForRow:self.detailItem.awards.count inSection:BookAwardSection];
    NSIndexPath* point       = [NSIndexPath indexPathForRow:self.detailItem.points.count inSection:BookPointSection];
    NSIndexPath* collection  = [NSIndexPath indexPathForRow:self.detailItem.collections.count inSection:BookCollectionSection];

    NSArray* paths = [NSArray arrayWithObjects:worker, signature, award, point, collection, nil];

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
        case BookTitleSection:
            return UITableViewCellEditingStyleNone;
        case BookWorkersSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.workers];
        case BookDetailsSection:
            return UITableViewCellEditingStyleNone;
        case BookInstanceDetailsSection:
            return UITableViewCellEditingStyleNone;
        case BookSignatureSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.signatures];
        case BookAwardSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.awards];
        case BookPointSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.points];
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
    if (self.editing)
        return;

    switch (indexPath.section)
    {
        case BookTitleSection:
            break;
        case BookWorkersSection:
            [self loadPersonDetailViewForPersonType:Workers atIndexPath:indexPath];
            break;
        case BookDetailsSection:
            if (indexPath.row == BookPublisherRow)
                [self loadPublisherDetailViewForPublisher:self.detailItem.publisher];
            break;
        case BookInstanceDetailsSection:
            if (indexPath.row == BookBoughtFromRow)
                [self loadSellerDetailViewForSeller:self.detailItem.boughtFrom];
            break;
        case BookSignatureSection:
            [self loadPersonDetailViewForPersonType:Signature atIndexPath:indexPath];
            break;
        case BookAwardSection:
            [self loadAwardDetailViewForAwardAtIndexPath:indexPath];
            break;
        case BookPointSection:
            [self loadPointDetailViewForPointAtIndexPath:indexPath];
            break;
        case BookCollectionSection:
            [self loadCollectionDetailViewForCollectionAtIndexPath:indexPath];
            break;
        default:
            DLog(@"Invalid BookDetailViewController section found: %i.", indexPath.section);
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
            case BookTitleSection:
                // Never delete the data section rows.
                break;
            case BookWorkersSection:
                worker = [self sortedWorkerFromSet:self.detailItem.workers atIndexPath:indexPath];
                [self.detailItem removeWorkersObject:worker];
                [self.detailItem.managedObjectContext deleteObject:worker];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case BookDetailsSection:
            case BookInstanceDetailsSection:
                // Never delete the data section rows.
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
            case BookCollectionSection:
                [self.detailItem removeCollectionsObject:[self sortedCollectionFromSet:self.detailItem.collections atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            default:
                break;
        }
        
        // Save the context.
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
    }   
}

-(NSIndexPath*) tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (!self.editing)
    {
        switch (indexPath.section)
        {
            case BookTitleSection:
                return nil;
            case BookWorkersSection:
            case BookDetailsSection:
            case BookInstanceDetailsSection:
            case BookSignatureSection:
            case BookAwardSection:
            case BookPointSection:
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

-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == BookTitleSection && indexPath.row == BookTitleRow)
    {
        return 130.0f;
    }
    else
    {
        return UITableViewAutomaticDimension;
    }
}

-(BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case BookTitleSection:
        case BookDetailsSection:
        case BookInstanceDetailsSection:
            return NO;
        default:
            return YES;
    }
}

-(UITableViewCell*) configureTitleCellAtIndexPath:(NSIndexPath*)indexPath
{
    EditableImageAndTextCell* imageCell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableImageAndTextCell"];
    
    if(imageCell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableImageAndTextCell" owner:self options:nil];
        imageCell = [topLevelObjects objectAtIndex:0];
        imageCell.textField.enabled = NO;
        imageCell.thumbnailButton.enabled = NO;
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
            [imageCell.thumbnailButton addTarget:self action:@selector(thumbnailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            imageCell.textField.text = self.detailItem.title;
            imageCell.titleLabel.text = self.detailItem.title;
            imageCell.textField.tag = BookTitleRow;
            break;
        default:
            DLog(@"Invalid BookDetailViewController Title section row found: %i.", indexPath.row);
            break;
    }
    
    return imageCell;
}

-(UITableViewCell*) configureWorkerCellAtIndexPath:(NSIndexPath*)indexPath
{
    EditableLookupAndTextCell* workerCell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableLookupAndTextCell"];
    
    UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];

    if (workerCell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableLookupAndTextCell" owner:self options:nil];
        workerCell = [topLevelObjects objectAtIndex:0];
        [workerCell.lookupButton addTarget:self action:@selector(lookupButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    workerCell.textField.delegate = self;
    workerCell.textField.text = @"";
    workerCell.textField.inputView = dummyView;
    workerCell.textField.tag = BookWorkerTag;
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
    }
    
    return workerCell;
}

-(UITableViewCell*) configureDetailsCellAtIndexPath:(NSIndexPath *)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailsEditableTextCell"];
    
    // Create the date picker to use for the releaseDate field.
    UIDatePicker* datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    
    // A dummy view to keep the keyboard from popping up in the lookup fields.
    UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    
    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.textField.delegate = self;
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
            cell.fieldLabel.text = NSLocalizedString(@"Format", @"BookDetailViewController format data field label.");
            cell.textField.text = self.detailItem.format;
            cell.textField.inputView = dummyView;
            cell.textField.tag = BookFormatTag;
            break;
        case BookEditionRow:
            cell.fieldLabel.text = NSLocalizedString(@"Edition", @"BookDetailViewController edition data field label.");
            cell.textField.text = self.detailItem.edition;
            cell.textField.inputView = dummyView;
            cell.textField.tag = BookEditionTag;
            break;
        case BookPrintingRow:
            cell.fieldLabel.text = NSLocalizedString(@"Printing", @"BookDetailViewController printing data field label.");
            cell.textField.text = (self.detailItem.printing == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.printing intValue]];
            cell.textField.tag = BookPrintingTag;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case BookPagesRow:
            cell.fieldLabel.text = NSLocalizedString(@"Pages", @"BookDetailViewController pages data field label.");
            cell.textField.text = (self.detailItem.pages == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.pages intValue]];
            cell.textField.tag = BookPagesTag;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case BookIsbnRow:
            cell.fieldLabel.text = NSLocalizedString(@"ISBN", @"BookDetailViewController isbn data field label.");
            cell.textField.text = self.detailItem.isbn;
            cell.textField.tag = BookIsbnTag;
            cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        case BookOriginalPriceRow:
            cell.fieldLabel.text = NSLocalizedString(@"Original Price", @"BookDetailViewController originalPrice data field label.");
            cell.textField.text = (self.detailItem.originalPrice == nil) ? @"" : [NSString stringWithFormat:@"%1.2f", [self.detailItem.originalPrice floatValue]];
            cell.textField.tag = BookOriginalPriceTag;
            cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case BookReleaseDateRow:
            cell.fieldLabel.text = NSLocalizedString(@"Released", @"BookDetailViewController releaseDate data field label.");
            releaseDateTextField = cell.textField;
            cell.textField.tag = BookReleaseDateTag;
            datePicker.tag = BookReleaseDateTag;
            cell.textField.inputView = datePicker;
            cell.textField.text = [formatter stringFromDate:self.detailItem.releaseDate];
            break;
        case BookPublisherRow:
            cell.fieldLabel.text = NSLocalizedString(@"Publisher", @"BookDetailViewController publisher data field label.");
            if (self.detailItem.publisher != nil)
                cell.textField.text = self.detailItem.publisher.name;
            cell.textField.inputView = dummyView;
            cell.textField.tag = BookPublisherTag;
            break;
        default:
            DLog(@"Invalid BookDetailViewController Data section row found: %i.", indexPath.row);
            break;
    }
    
    return cell;
}

-(UITableViewCell*) configureInstanceDetailsCellAtIndexPath:(NSIndexPath *)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"InstanceEditableTextCell"];
    
    // Create the date picker to use for the releaseDate field.
    UIDatePicker* datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    
    // A dummy view to keep the keyboard from popping up in the lookup fields.
    UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    
    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.textField.delegate = self;
    cell.textField.inputView = nil;
    cell.textField.keyboardType = UIKeyboardTypeDefault;
    cell.textField.text = @"";
    if (self.editing)
        cell.textField.enabled = YES;
    else
        cell.textField.enabled = NO;
    
    switch (indexPath.row)
    {
        case BookBookConditionRow:
            cell.fieldLabel.text = NSLocalizedString(@"Book Cond.", @"BookDetailViewController bookCondition data field label.");
            cell.textField.text = self.detailItem.bookCondition;
            cell.textField.inputView = dummyView;
            cell.textField.tag = BookBookConditionTag;
            break;
        case BookJacketConditionRow:
            cell.fieldLabel.text = NSLocalizedString(@"Jacket Cond.", @"BookDetailViewController jacketCondition data field label.");
            cell.textField.text = self.detailItem.jacketCondition;
            cell.textField.inputView = dummyView;
            cell.textField.tag = BookJacketConditionTag;
            break;
        case BookPurchaseDateRow:
            cell.fieldLabel.text = NSLocalizedString(@"Puchased", @"BookDetailViewController purchaseDate data field label.");
            purchaseDateTextField = cell.textField;
            cell.textField.tag = BookPurchaseDateTag;
            datePicker.tag = BookPurchaseDateTag;
            cell.textField.inputView = datePicker;
            cell.textField.text = [formatter stringFromDate:self.detailItem.purchaseDate];
            break;
        case BookPricePaidRow:
            cell.fieldLabel.text = NSLocalizedString(@"Price Paid", @"BookDetailViewController pricePaid data field label.");
            cell.textField.text = (self.detailItem.pricePaid == nil) ? @"" : [NSString stringWithFormat:@"%1.2f", [self.detailItem.pricePaid floatValue]];
            cell.textField.tag = BookPricePaidTag;
            cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case BookCurrentValueRow:
            cell.fieldLabel.text = NSLocalizedString(@"Current Value", @"BookDetailViewController currentValue data field label.");
            cell.textField.text = (self.detailItem.currentValue == nil) ? @"" : [NSString stringWithFormat:@"%1.2f", [self.detailItem.currentValue floatValue]];
            cell.textField.tag = BookCurrentValueTag;
            cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case BookNumberRow:
            cell.fieldLabel.text = NSLocalizedString(@"Number", @"BookDetailViewController number data field label.");
            cell.textField.text = (self.detailItem.number == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.number intValue]];
            cell.textField.tag = BookNumberTag;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case BookPrintRunRow:
            cell.fieldLabel.text = NSLocalizedString(@"Print Run", @"BookDetailViewController printRun data field label.");
            cell.textField.text = (self.detailItem.printRun == nil) ? @"" : [NSString stringWithFormat:@"%i", [self.detailItem.printRun intValue]];
            cell.textField.tag = BookPrintRunTag;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case BookBoughtFromRow:
            cell.fieldLabel.text = NSLocalizedString(@"Seller", @"BookDetailViewController boughtFrom data field label.");
            if (self.detailItem.boughtFrom != nil)
                cell.textField.text = self.detailItem.boughtFrom.name;
            cell.textField.inputView = dummyView;
            cell.textField.tag = BookBoughtFromTag;
            break;
        case BookCommentsRow:
            cell.fieldLabel.text = NSLocalizedString(@"Comments", @"BookDetailViewController comments data field label.");
            cell.textField.text = self.detailItem.comments;
            cell.textField.tag = BookCommentsRow;
            break;
        default:
            DLog(@"Invalid BookDetailViewController Data section row found: %i.", indexPath.row);
            break;
    }
    
    return cell;
}

-(UITableViewCell*) configureSignatureCellAtIndexPath:(NSIndexPath*)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"SignatureEditableTextCell"];
    
    // A dummy view to keep the keyboard from popping up in the lookup fields.
    UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    
    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.fieldLabel.text = NSLocalizedString(@"Signed by", @"BookDetailViewController signature cell field label text.");
    cell.textField.delegate = self;
    cell.textField.text = @"";
    cell.textField.inputView = dummyView;
    cell.textField.tag = BookSignatureTag;
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
    UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    
    if (cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.fieldLabel.text = NSLocalizedString(@"Award", @"BookDetailViewController award cell field label text.");
    cell.textField.delegate = self;
    cell.textField.text = @"";
    cell.textField.inputView = dummyView;
    cell.textField.tag = BookAwardTag;
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

-(UITableViewCell*) configurePointCellAtIndexPath:(NSIndexPath *)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"PointEditableTextCell"];
    
    // A dummy view to keep the keyboard from popping up in the lookup fields.
    UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    
    if (cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.fieldLabel.text = NSLocalizedString(@"Point", @"BookDetailViewController point cell field label text.");
    cell.textField.delegate = self;
    cell.textField.text = @"";
    cell.textField.inputView = dummyView;
    cell.textField.tag = BookPointTag;
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

-(UITableViewCell*) configureCollectionCellAtIndexPath:(NSIndexPath *)indexPath
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"CollectionEditableTextCell"];
    
    // A dummy view to keep the keyboard from popping up in the lookup fields.
    UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    
    if (cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    // Reset default values for the cell. Make sure some values set below are not carried over to other cells.
    cell.textField.text = @"";
    cell.textField.delegate = self;
    cell.textField.inputView = dummyView;
    cell.fieldLabel.text = NSLocalizedString(@"Collection", @"BookDetailViewController collection cell field label text.");
    cell.textField.tag = BookCollectionTag;
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
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - Publisher Selection Delegate Method

-(void) publisherViewController:(PublisherViewController *)controller didSelectPublisher:(Publisher *)publisher
{
    self.detailItem.publisher = publisher;
    [ContextUtil saveContext:self.detailItem.managedObjectContext];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - Seller Selection Delegate Method

-(void) sellerViewController:(SellerViewController *)controller didSelectSeller:(Seller*)seller
{
    self.detailItem.boughtFrom = seller;
    [ContextUtil saveContext:self.detailItem.managedObjectContext];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - Collection Selection Delegate Method

-(void) collectionViewController:(CollectionViewController *)controller didSelectCollection:(Collection *)collection
{
    [self.detailItem addCollectionsObject:collection];
    [ContextUtil saveContext:self.detailItem.managedObjectContext];
    
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

-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    NSArray* paths = [NSArray arrayWithObjects:path, nil];
    
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
}

-(void) loadPersonViewForPersonType:(PersonType)type
{
    self.lookupJustFinished = YES;
    
    PersonViewController* personViewController = [[PersonViewController alloc] initWithNibName:@"PersonViewController" bundle:nil];
    personViewController.managedObjectContext = self.detailItem.managedObjectContext;
    personViewController.delegate = self;
    personViewController.selectionMode = TRUE;
    personViewController.personSelectionType = type;
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:personViewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadPersonDetailViewForPersonType:(PersonType)type atIndexPath:(NSIndexPath*)indexPath
{
    PersonDetailViewController* personDetailViewController = [[PersonDetailViewController alloc] initWithNibName:@"PersonDetailViewController" bundle:nil];
    Person* selectedPerson = nil;
    Worker* worker = nil;
    
    switch (type)
    {
        case Workers:
            worker = [self sortedWorkerFromSet:self.detailItem.workers atIndexPath:indexPath];
            selectedPerson = worker.person;
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
    self.lookupJustFinished = YES;
    
    PublisherViewController* publisherViewController = [[PublisherViewController alloc] initWithNibName:@"PublisherViewController" bundle:nil];
    publisherViewController.managedObjectContext = self.detailItem.managedObjectContext;
    publisherViewController.delegate = self;
    publisherViewController.selectionMode = TRUE;
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:publisherViewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController presentModalViewController:navController animated:YES];
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
    self.lookupJustFinished = YES;
    
    SellerViewController* sellerViewController = [[SellerViewController alloc] initWithNibName:@"SellerViewController" bundle:nil];
    sellerViewController.managedObjectContext = self.detailItem.managedObjectContext;
    sellerViewController.delegate = self;
    sellerViewController.selectionMode = TRUE;
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:sellerViewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController presentModalViewController:navController animated:YES];
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

-(void) loadNewAwardView
{
    self.lookupJustFinished = YES;
    
    NewAwardViewController* newAwardViewController = [[NewAwardViewController alloc] initWithStyle:UITableViewStyleGrouped];
	newAwardViewController.delegate = self;
	newAwardViewController.detailItem = [Award awardInManagedObjectContext:self.detailItem.managedObjectContext];
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newAwardViewController];
	navController.navigationBar.barStyle = UIBarStyleBlack;
    
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
    self.lookupJustFinished = YES;
    
    NewPointViewController* newPointViewController = [[NewPointViewController alloc] initWithStyle:UITableViewStyleGrouped];
	newPointViewController.delegate = self;
	newPointViewController.detailItem = [DLPoint pointInManagedObjectContext:self.detailItem.managedObjectContext];
	
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newPointViewController];
	navController.navigationBar.barStyle = UIBarStyleBlack;
	
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

-(void) loadCollectionView
{
    self.lookupJustFinished = YES;
    
    CollectionViewController* collectionViewController = [[CollectionViewController alloc] initWithNibName:@"CollectionViewController" bundle:nil];
    collectionViewController.managedObjectContext = self.detailItem.managedObjectContext;
	collectionViewController.delegate = self;
    collectionViewController.selectionMode = TRUE;
	
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:collectionViewController];
	navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadCollectionDetailViewForCollectionAtIndexPath:(NSIndexPath*)indexPath
{
    CollectionDetailViewController* collectionDetailViewController = [[CollectionDetailViewController alloc] initWithNibName:@"CollectionDetailViewController" bundle:nil];
    Collection* selectedCollection = [self sortedCollectionFromSet:self.detailItem.collections atIndexPath:indexPath];
    
    if (selectedCollection)
    {
        collectionDetailViewController.detailItem = selectedCollection;
        [self.navigationController pushViewController:collectionDetailViewController animated:YES];
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

#pragma mark - Image Handling

-(void) thumbnailButtonPressed:(id)sender
{
    UIButton* button = sender;
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

        [actionSheet showFromTabBar:self.tabBarController.tabBar];
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
        [self presentModalViewController:picker animated:YES];
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:choose])
    {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:picker animated:YES];
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
