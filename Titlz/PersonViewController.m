//
//  PersonViewController.m
//  Titlz
//
//  Created by David Lains on 1/4/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "PersonViewController.h"
#import "PersonDetailViewController.h"
#import "Person.h"

@interface PersonViewController ()
-(void) configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
@end

@implementation PersonViewController

@synthesize personDetailViewController = _personDetailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize addingManagedObjectContext = __addingManagedObjectContext;
@synthesize delegate = _delegate;
@synthesize selectionMode = _selectionMode;
@synthesize personSelectionType = _personSelectionType;

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"People", @"People");
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

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    
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
        NSError *error = nil;
        if (![context save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

-(BOOL) tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark - Table view delegate

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.selectionMode)
    {
        // Get the selected person and update the correct delegate.
        Person* selectedPerson = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        switch (self.personSelectionType)
        {
            case Author:
                [self.delegate personViewController:self didSelectAuthor:selectedPerson];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            default:
                break;
        }
    }
    else
    {
        // Selecting a row to get detail info.
        if (!self.personDetailViewController)
        {
            self.personDetailViewController = [[PersonDetailViewController alloc] initWithNibName:@"PersonDetailViewController" bundle:nil];
        }
        Person* selectedPerson = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.personDetailViewController.detailItem = selectedPerson;
        [self.navigationController pushViewController:self.personDetailViewController animated:YES];
    }
}

#pragma mark - Fetched results controller

-(NSFetchedResultsController*) fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    // TODO: Offer option to sort by first name or last name?
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:NO];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Person"];
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
    Person* person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = person.fullName;
}

#pragma mark - New Person Handling

-(void) insertNewObject
{
    // Use a local TitleDetailViewController here to avoid problems with reusing it with the main navigation controller.
    /*
     TitleDetailViewController* titleDetailViewController = [[TitleDetailViewController alloc] initWithPrimaryManagedObjectContext:self.managedObjectContext];
     titleDetailViewController.detailItem = nil;
     titleDetailViewController.newRecord = YES;
     
     UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:titleDetailViewController];
     [self.navigationController presentModalViewController:navigationController animated:YES];
     */
    
    NewPersonViewController* newPersonViewController = [[NewPersonViewController alloc] initWithStyle:UITableViewStyleGrouped];
	newPersonViewController.delegate = self;
	
	// Create a new managed object context for the new title -- set its persistent store coordinator to the same as that from the fetched results controller's context.
	self.addingManagedObjectContext = [[NSManagedObjectContext alloc] init];
	
	[self.addingManagedObjectContext setPersistentStoreCoordinator:[[self.fetchedResultsController managedObjectContext] persistentStoreCoordinator]];
    
	newPersonViewController.detailItem = [Person personInManagedObjectContext:self.addingManagedObjectContext];
	
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
	
    [self.navigationController presentModalViewController:navController animated:YES];
    
}

-(void) newPersonViewController:(NewPersonViewController *)controller didFinishWithSave:(BOOL)save
{
    if (save)
    {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.addingManagedObjectContext];
		
		NSError *error;
		if (![self.addingManagedObjectContext save:&error])
        {
			// Update to handle the error appropriately.
			DLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.addingManagedObjectContext];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

/**
 Notification from the add controller's context's save operation. This is used to update the fetched results controller's managed object context with the new book instead of performing a fetch (which would be a much more computationally expensive operation).
 */
-(void) addControllerContextDidSave:(NSNotification*)saveNotification
{
	NSManagedObjectContext* context = [self.fetchedResultsController managedObjectContext];
	// Merging changes causes the fetched results controller to update its results
	[context mergeChangesFromContextDidSaveNotification:saveNotification];	
}

@end
