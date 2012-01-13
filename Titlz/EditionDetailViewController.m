//
//  EditionDetailViewController.m
//  Titlz
//
//  Created by David Lains on 1/11/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "EditionDetailViewController.h"
#import "EditableTextCell.h"
#import "Edition.h"
#import "Publisher.h"
#import "DLPoint.h"
#import "Book.h"

@interface EditionDetailViewController ()
-(UITableViewCell*) configureDataCellForRow:(NSInteger)row;
-(UITableViewCell*) configurePublisherCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configurePointsCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureBooksCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCellEditingStyle) editingStyleForRow:(NSInteger)row inCollection:(NSSet*)collection;
@end

@implementation EditionDetailViewController

@synthesize detailItem = _detailItem;
@synthesize undoManager = _undoManager;

#pragma mark - Initialization

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Edition", @"EditionDetailViewController header bar title.");
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

#pragma mark - Table view data source

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
	// Hide the back button when editing starts, and show it again when editing finishes.
    [self.navigationItem setHidesBackButton:editing animated:animated];
    
    NSInteger publisherRow = (self.detailItem.publisher != nil) ? 1 : 0;
    NSIndexPath* publishers    = [NSIndexPath indexPathForRow:publisherRow inSection:EditionPublisherSection];
    NSIndexPath* points        = [NSIndexPath indexPathForRow:self.detailItem.points.count inSection:EditionPointsSection];
    NSIndexPath* books         = [NSIndexPath indexPathForRow:self.detailItem.books.count inSection:EditionBooksSection];
    
    NSArray* paths = [NSArray arrayWithObjects:publishers, points, books, nil];
    
    if (editing)
    {
        [self setUpUndoManager];
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationRight];
    }
    else
    {
		[self cleanUpUndoManager];
		// Save the changes.
		NSError* error;
		if (![self.detailItem.managedObjectContext save:&error])
        {
			// Update to handle the error appropriately.
			DLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
        [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return EditionDetailSectionCount;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger insertionRow = 0;
    
    // If the table is in editing mode add one row for inserting new records to most of the sections.
    if(self.editing)
        insertionRow = 1;
    
    switch (section)
    {
        case EditionDataSection:
            return EditionDataSectionRowCount;
        case EditionPublisherSection:
            return ((self.detailItem.publisher != nil) ? 1 : 0) + insertionRow;
        case EditionPointsSection:
            return self.detailItem.points.count + insertionRow;
        case EditionBooksSection:
            return self.detailItem.books.count + insertionRow;
        default:
            return 0;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section)
    {
        case EditionDataSection:
            cell = [self configureDataCellForRow:indexPath.row];
            break;
        case EditionPublisherSection:
            cell = [self configurePublisherCellAtIndexPath:indexPath];
            break;
        case EditionPointsSection:
            cell = [self configurePointsCellAtIndexPath:indexPath];
            break;
        case EditionBooksSection:
            cell = [self configureBooksCellAtIndexPath:indexPath];
            break;
        default:
            DLog(@"Invalid EditionDetailViewController section found: %i.", indexPath.section);
            break;
    }
    
    return cell;
}

// Editing styles per row.
-(UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case EditionDataSection:
            return UITableViewCellEditingStyleNone;
        case EditionPublisherSection:
            return (self.detailItem.publisher != nil) ? ((indexPath.row == 1) ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete) : UITableViewCellEditingStyleInsert;
        case EditionPointsSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.points];
        case EditionBooksSection:
            return [self editingStyleForRow:indexPath.row inCollection:self.detailItem.books];
        default:
            DLog(@"Invalid EditionDetailViewController section found: %i.", indexPath.section);
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
    switch (indexPath.section)
    {
        case EditionDataSection:
            break;
        case EditionPublisherSection:
            // [self loadPublisherDetailViewForPublisher:self.detailItem.publisher];
            break;
        case EditionPointsSection:
            //if (indexPath.row == self.detailItem.points.count)
            //    [self loadPointsView];
            //else
            //    [self loadPointsDetailView];
            break;
        case EditionBooksSection:
            //if (indexPath.row == self.detailItem.books.count)
            //    [self loadBookView];
            //else
            //    [self loadBookDetailView];
            break;
        default:
            DLog(@"Invalid TitleDetailViewController section found: %i.", indexPath.section);
            break;
    }
}

-(void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    // TODO: Finish this when the subviews are done.
    /*
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        switch (indexPath.section)
        {
            case EditionDataSection:
                // Never delete the data section rows.
                break;
            case EditionPublisherSection:
                self.detailItem.publisher = nil;
                [self deleteRowAtIndexPath:indexPath];
                break;
            case EditionPointsSection:
                [self.detailItem removePointsObject:[self sortedPointFromSet:self.detailItem.points atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            case EditionBooksSection:
                [self.detailItem removeBooksObject:[self sortedBookFromSet:self.detailItem.books atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            default:
                break;
        }
        
        // Save the context.
        NSError *error = nil;
        if (![self.detailItem.managedObjectContext save:&error])
        {
            //Replace this implementation with code to handle the error appropriately.
             
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
    */
}

// Section headers.
-(NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* header = nil;
    
    switch (section)
    {
        case EditionDataSection:
            break;
        case EditionPublisherSection:
            if (self.detailItem.publisher || self.editing)
            {
                header = NSLocalizedString(@"Publisher", @"EditionDetailViewController Publisher section header.");
            }
            break;
        case EditionPointsSection:
            if (self.detailItem.points.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Points", @"EditionDetailViewController Points section header.");
            }
            break;
        case EditionBooksSection:
            if (self.detailItem.books.count > 0 || self.editing)
            {
                header = NSLocalizedString(@"Books", @"BooksDetailViewController Books Of section header.");
            }
            break;
        default:
            DLog(@"Invalid EditionDetailViewController section found: %i.", section);
            break;
    }
    
    return header;
}

-(UITableViewCell*) configureDataCellForRow:(NSInteger)row
{
    EditableTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableTextCell"];
    
    // Create the date picker to use for the releaseDate field.
    UIDatePicker* datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    
    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableTextCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.textField.enabled = NO;
    }
    
    switch (row)
    {
        case EditionNameRow:
            cell.fieldLabel.text = NSLocalizedString(@"Name", @"EditionDetailViewController name data field label.");
            cell.textField.text = self.detailItem.name;
            cell.textField.tag = EditionNameRow;
            break;
        case EditionFormatRow:
            cell.fieldLabel.text = NSLocalizedString(@"Format", @"EditionDetailViewController format data field label.");
            cell.textField.text = self.detailItem.format;
            cell.textField.tag = EditionFormatRow;
            break;
        case EditionIsbn10Row:
            cell.fieldLabel.text = NSLocalizedString(@"ISBN-10", @"EditionDetailViewController isbn10 data field label.");
            cell.textField.text = self.detailItem.isbn10;
            cell.textField.tag = EditionIsbn10Row;
            break;
        case EditionIsbn13Row:
            cell.fieldLabel.text = NSLocalizedString(@"ISBN-13", @"EditionDetailViewController isbn13 data field label.");
            cell.textField.text = self.detailItem.isbn13;
            cell.textField.tag = EditionIsbn13Row;
            break;
        case EditionPagesRow:
            cell.fieldLabel.text = NSLocalizedString(@"Pages", @"EditionDetailViewController pages data field label.");
            cell.textField.text = self.detailItem.pages;
            cell.textField.tag = EditionPagesRow;
            break;
        case EditionPrintRunRow:
            cell.fieldLabel.text = NSLocalizedString(@"Print Run", @"EditionDetailViewController printRun data field label.");
            cell.textField.text = self.detailItem.printRun;
            cell.textField.tag = EditionPrintRunRow;
            break;
        case EditionReleaseDateRow:
            cell.fieldLabel.text = NSLocalizedString(@"Released", @"EditionDetailViewController releaseDate data field label.");
            releaseDateTextField = cell.textField;
            cell.textField.tag = EditionReleaseDateRow;
            datePicker.tag = EditionReleaseDateRow;
            cell.textField.inputView = datePicker;
            cell.textField.text = [formatter stringFromDate:self.detailItem.releaseDate];
            break;
        default:
            DLog(@"Invalid EditionDetailViewController Data section row found: %i.", row);
            break;
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
        cell.textLabel.text = NSLocalizedString(@"Add Publisher...", @"EditionDetailViewController add Publisher insertion row text.");
    }
    else
    {
        //cell.textLabel.text = self.detailItem.publisher.name;
    }
    
    return cell;
}

-(UITableViewCell*) configurePointsCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"PointsCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(self.editing && indexPath.row == self.detailItem.points.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Point...", @"EditionDetailViewController add Point insertion row text.");
    }
    else
    {
        //DLPoint* point = [self sortedPointFromSet:self.detailItem.points atIndexPath:indexPath];
        //cell.textLabel.text = point;
    }
    
    return cell;
}

-(UITableViewCell*) configureBooksCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"BookCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(self.editing && indexPath.row == self.detailItem.books.count)
    {
        cell.textLabel.text = NSLocalizedString(@"Add Book...", @"EditionDetailViewController add Book insertion row text.");
    }
    else
    {
        //Book* book = [self sortedBookFromSet:self.detailItem.books atIndexPath:indexPath];
        //cell.textLabel.text = book;
    }
    
    return cell;
}

@end
