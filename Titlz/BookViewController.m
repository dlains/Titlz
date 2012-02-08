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
#import "AlphaIndexFetchedResultsController.h"

@interface BookViewController ()
-(void) configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
-(NSFetchedResultsController*) fetchedResultsControllerWithPredicate:(NSPredicate*)predicate;
-(void) selectObjects;
@end

@implementation BookViewController

@synthesize bookDetailViewController = _bookDetailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize delegate = _delegate;
@synthesize selectionMode = _selectionMode;
@synthesize personSelectionType = _personSelectionType;

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Books", @"BookViewController header bar title.");
        self.tabBarItem.image = [UIImage imageNamed:@"book"];
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
    }
    else if (self.selectionMode == DetailSelection)
    {
        self.tableView.allowsMultipleSelection = NO;
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }

    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
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
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (self.selectionMode == MultipleSelection)
    {
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:NSLocalizedString(@"Select (%d)", @"BookViewController multiple selection button text"), selectedRows.count];
    }
    else
    {
        if (!self.bookDetailViewController)
        {
            self.bookDetailViewController = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
        }
        Book* selectedBook = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.bookDetailViewController.detailItem = selectedBook;
        [self.navigationController pushViewController:self.bookDetailViewController animated:YES];
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
    
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:nil];
    
    return __fetchedResultsController;
}    

-(NSFetchedResultsController*) fetchedResultsControllerWithPredicate:(NSPredicate*)predicate
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortableTitle" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSString* cacheName = @"Book";
    if (predicate)
        cacheName = nil;

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    AlphaIndexFetchedResultsController* controller = [[AlphaIndexFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstLetterOfTitle" cacheName:cacheName];
    controller.delegate = self;
    self.fetchedResultsController = controller;
    
	NSError* error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    DLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

-(void) controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    [self.tableView beginUpdates];
}

-(void) controller:(NSFetchedResultsController*)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void) controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{
    UITableView* tableView = self.tableView;
    
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
    [self.tableView endUpdates];
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

    cell.detailTextLabel.text = detail;
}

#pragma mark - Search delegate

-(BOOL) searchDisplayController:(UISearchDisplayController*)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchString];
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:predicate];
    return YES;
}

-(void) searchDisplayControllerWillEndSearch:(UISearchDisplayController*)controller
{
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:nil];
}

#pragma mark - New Book Handling

-(void) insertNewObject
{
    NewBookViewController* newBookViewController = [[NewBookViewController alloc] initWithStyle:UITableViewStyleGrouped];
	newBookViewController.delegate = self;
	newBookViewController.detailItem = [Book bookInManagedObjectContext:self.managedObjectContext];
	
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newBookViewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
	
    [self.navigationController presentModalViewController:navController animated:YES];
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
