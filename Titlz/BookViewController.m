//
//  BookViewController.m
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import "BookViewController.h"
#import "BookDetailViewController.h"
#import "Book.h"
#import "Photo.h"
#import "Person.h"
#import "Worker.h"
#import "OpenLibraryLookupViewController.h"

@interface BookViewController ()
-(void) configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
-(NSFetchedResultsController*) fetchedResultsControllerWithPredicate:(NSPredicate*)predicate;
-(void) selectObjects;

-(void) insertNewObject;
-(void) cancelSelect;
-(void) cancelMultiSelect;

-(void) loadNewBookView;
-(void) loadOpenLibraryLookupView;

@end

@implementation BookViewController

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize delegate = _delegate;
@synthesize selectionMode = _selectionMode;
@synthesize personSelectionType = _personSelectionType;
@synthesize excludedBooks = _excludedBooks;

-(id) initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    self = [super initWithNibName:@"BookViewController" bundle:nil];
    if (self)
    {
        self.title = NSLocalizedString(@"Books", @"BookViewController header bar title.");
        self.tabBarItem.image = [UIImage imageNamed:@"book"];
        self.managedObjectContext = context;
    }
    
    return self;
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    if (self.selectionMode == MultipleSelection)
    {
        self.tableView.allowsMultipleSelection = YES;
        UIBarButtonItem* selectButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select (0)", @"BookViewController multiple selection button text") style:UIBarButtonItemStyleBordered target:self action:@selector(selectObjects)];
        self.navigationItem.leftBarButtonItem = selectButton;

        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"BookViewController cancel button text.") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelMultiSelect)];
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
    else if (self.selectionMode == DetailSelection)
    {
        self.tableView.allowsMultipleSelection = NO;
        self.navigationItem.leftBarButtonItem = self.editButtonItem;

        UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
    else if (self.selectionMode == SingleSelection)
    {
        self.tableView.allowsMultipleSelection = NO;
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"BookViewController cancel button text.") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelSelect)];
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
}

-(void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// Customize the number of sections in the table view.
-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return [[self.fetchedResultsController sections] count];
}

-(NSArray*) sectionIndexTitlesForTableView:(UITableView*)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

-(NSInteger) tableView:(UITableView*)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    // Check for the magnifying glass first.
    if ([title isEqualToString:UITableViewIndexSearch])
    {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:NO];
        return -1;
    }
    
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

// Customize the appearance of table view cells.
-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"BooksCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

-(void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the managed object for the given index path
        NSManagedObjectContext* context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        [ContextUtil saveContext:context];
    }   
}

-(BOOL) tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

-(void) tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.selectionMode == MultipleSelection)
    {
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:NSLocalizedString(@"Select (%d)", @"BookViewController multiple selection button text"), selectedRows.count];
    }
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.selectionMode == SingleSelection)
    {
        // Get the selected book and update the correct delegate.
        Book* selectedBook = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [self.delegate bookViewController:self didSelectBook:selectedBook forPersonType:self.personSelectionType];
    }
    else if (self.selectionMode == MultipleSelection)
    {
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:NSLocalizedString(@"Select (%d)", @"BookViewController multiple selection button text"), selectedRows.count];
    }
    else
    {
        BookDetailViewController* bookDetailViewController = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
        Book* selectedBook = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        bookDetailViewController.detailItem = selectedBook;
        [self.navigationController pushViewController:bookDetailViewController animated:YES];
    }
}

-(NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

#pragma mark - Fetched results controller

-(NSFetchedResultsController*) fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    if (self.selectionMode == MultipleSelection && self.excludedBooks != nil)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"NOT (self IN %@)", self.excludedBooks];

        self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:predicate];
    }
    else
        self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:nil];
    
    return __fetchedResultsController;
}    

-(NSFetchedResultsController*) fetchedResultsControllerWithPredicate:(NSPredicate*)predicate
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortableTitle" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];

    fetchRequest.fetchBatchSize = 20;
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = sortDescriptors;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"title", @"edition", @"format", nil];
    fetchRequest.relationshipKeyPathsForPrefetching = [NSArray arrayWithObjects:@"worker", nil];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstLetterOfTitle" cacheName:nil];
    controller.delegate = self;
    self.fetchedResultsController = controller;
    
	NSError* error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

-(void) controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    if (self.searchDisplayController.isActive)
    {
        [self.searchDisplayController.searchResultsTableView beginUpdates];
    }
    else
    {
        [self.tableView beginUpdates];
    }
}

-(void) controller:(NSFetchedResultsController*)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView* tableView = self.tableView;
    
    if (self.searchDisplayController.isActive)
    {
        tableView = self.searchDisplayController.searchResultsTableView;
    }
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void) controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{
    UITableView* tableView = self.tableView;

    if (self.searchDisplayController.isActive)
    {
        tableView = self.searchDisplayController.searchResultsTableView;
    }
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void) controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    if (self.searchDisplayController.isActive)
    {
        [self.searchDisplayController.searchResultsTableView endUpdates];
    }
    else
    {
        [self.tableView endUpdates];
    }
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

-(void) configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    Book* book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = book.title;
    
    NSMutableString* detail = [NSMutableString stringWithCapacity:10];

    // Try book workers for the detail line first.
    if (book.workers.count > 0)
    {
        int count = 0;
        for (Worker* worker in book.workers)
        {
            if (count > 0)
            {
                [detail appendString:@", "];
            }
            [detail appendString:worker.person.fullName];
            count++;
        }
    }
    else // Get the edition and format.
    {
        if (book.edition.length > 0)
        {
            [detail appendString:book.edition];
        }
        
        if (book.format.length > 0)
        {
            if (detail.length > 0)
            {
                [detail appendString:@" - "];
                [detail appendString:book.format];
            }
            else
            {
                [detail appendString:book.format];
            }
        }
    }

    cell.detailTextLabel.text = detail;
}

#pragma mark - Search delegate

-(BOOL) searchDisplayController:(UISearchDisplayController*)controller shouldReloadTableForSearchString:(NSString*)searchString
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchString];
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:predicate];
    return YES;
}

-(void) searchDisplayControllerWillEndSearch:(UISearchDisplayController*)controller
{
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:nil];
    [self.tableView reloadData];
}

#pragma mark - New Book Handling

-(void) insertNewObject
{
    NSString* title  = NSLocalizedString(@"Get book details via:", @"BookViewController new book action sheet title.");
    NSString* cancel = NSLocalizedString(@"Cancel", @"BookViewController new book action sheet cancel button title.");
    NSString* manual = NSLocalizedString(@"Manual Entry", @"BookViewController new book action sheet manual button title.");
    NSString* search = NSLocalizedString(@"Open Library", @"BookViewController new book action sheet open library button title.");
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:cancel destructiveButtonTitle:nil otherButtonTitles:manual, search, nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

-(void) cancelSelect
{
    [self.delegate bookViewController:self didSelectBook:nil forPersonType:Workers];
}

-(void) cancelMultiSelect
{
    [self.delegate bookViewController:self didSelectBooks:nil];
}

-(void) actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* cancel = NSLocalizedString(@"Cancel", @"BookViewController new book action sheet cancel button title.");
    NSString* manual = NSLocalizedString(@"Manual Entry", @"BookViewController new book action sheet manual button title.");
    NSString* search = NSLocalizedString(@"Open Library", @"BookViewController new book action sheet open library button title.");

    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:cancel])
    {
        return;
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:manual])
    {
        [self loadNewBookView];
        [TestFlight passCheckpoint:@"Manual Book Entry Selected"];

    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:search])
    {
        [self loadOpenLibraryLookupView];
        [TestFlight passCheckpoint:@"Open Library Book Entry Selected"];
    }
}

-(void) loadNewBookView
{
    NewBookViewController* newBookViewController = [[NewBookViewController alloc] initWithStyle:UITableViewStyleGrouped];
	newBookViewController.delegate = self;
	newBookViewController.detailItem = [Book bookInManagedObjectContext:self.managedObjectContext];

	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newBookViewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
	
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadOpenLibraryLookupView
{
    OpenLibraryLookupViewController* lookupController = [[OpenLibraryLookupViewController alloc] initWithNibName:@"OpenLibraryLookupViewController" bundle:nil];
    lookupController.managedObjectContext = self.managedObjectContext;
    lookupController.delegate = self;
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:lookupController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
	
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

-(void) newBookViewController:(NewBookViewController*)controller didFinishWithSave:(BOOL)save
{
    if (save)
    {
        if (![ContextUtil saveContext:self.managedObjectContext])
        {
            // Didn't save, so don't dismiss the modal view.
            return;
        }
    }
    else
    {
        // Canceled the insert, remove the managed object.
        [self.managedObjectContext deleteObject:controller.detailItem];
        [ContextUtil saveContext:self.managedObjectContext];
    }
    
    [self.tableView reloadData];
    NSIndexPath* indexPath = [self.fetchedResultsController indexPathForObject:controller.detailItem];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

-(void) selectObjects
{
    // Get the selected books and update the correct delegate.
    NSArray* indexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray* selectedBooks = [NSMutableArray arrayWithCapacity:indexPaths.count];
    
    for (NSIndexPath* indexPath in indexPaths)
    {
        Book* selectedBook = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [selectedBooks addObject:selectedBook];
    }
    
    [self.delegate bookViewController:self didSelectBooks:selectedBooks];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
