//
//  PublisherViewController.m
//  Titlz
//
//  Created by David Lains on 1/13/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "PublisherViewController.h"
#import "PublisherDetailViewController.h"
#import "Publisher.h"

@interface PublisherViewController ()
-(void) configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
-(NSFetchedResultsController*) fetchedResultsControllerWithPredicate:(NSPredicate*)predicate;
@end

@implementation PublisherViewController

@synthesize publisherDetailViewController = _publisherDetailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize delegate = _delegate;
@synthesize selectionMode = _selectionMode;

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Publishers", @"PublisherViewController header bar title.");
    }
    return self;
}

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
	// Do any additional setup after loading the view, typically from a nib.
    // Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

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
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"PublisherCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if (!self.selectionMode)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
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

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

#pragma mark - Table view delegate

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.selectionMode)
    {
        // Get the selected person and update the correct delegate.
        Publisher* selectedPublisher = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [self.delegate publisherViewController:self didSelectPublisher:selectedPublisher];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        // Selecting a row to get detail info.
        if (!self.publisherDetailViewController)
        {
            self.publisherDetailViewController = [[PublisherDetailViewController alloc] initWithNibName:@"PublisherDetailViewController" bundle:nil];
        }
        Publisher* selectedPublisher = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.publisherDetailViewController.detailItem = selectedPublisher;
        [self.navigationController pushViewController:self.publisherDetailViewController animated:YES];
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
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Publisher" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSString* cacheName = @"Publisher";
    if (predicate)
        cacheName = nil;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstLetterOfName" cacheName:cacheName];
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
    Publisher* publisher = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = publisher.name;
}

#pragma mark - Search delegate

-(BOOL) searchDisplayController:(UISearchDisplayController*)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString];
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:predicate];
    return YES;
}

-(void) searchDisplayControllerWillEndSearch:(UISearchDisplayController*)controller
{
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:nil];
}

#pragma mark - New Publisher Handling

-(void) insertNewObject
{
    NewPublisherViewController* newPublisherViewController = [[NewPublisherViewController alloc] initWithStyle:UITableViewStyleGrouped];
	newPublisherViewController.delegate = self;
	newPublisherViewController.detailItem = [Publisher publisherInManagedObjectContext:self.managedObjectContext];
	
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newPublisherViewController];
	
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) newPublisherViewController:(NewPublisherViewController *)controller didFinishWithSave:(BOOL)save
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
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
