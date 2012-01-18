//
//  LookupViewController.m
//  Titlz
//
//  Created by David Lains on 1/18/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "LookupViewController.h"
#import "Lookup.h"

@interface LookupViewController ()
-(void) configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
@end

@implementation LookupViewController

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize delegate = _delegate;
@synthesize selectedLookupType = _selectedLookupType;

-(id) initWithLookupType:(LookupType)type
{
    self = [super initWithNibName:@"LookupViewController" bundle:nil];
    
    if (self)
    {
        self.selectedLookupType = type;

        switch (self.selectedLookupType)
        {
            case LookupTypeEdition:
                self.title = NSLocalizedString(@"Edition", @"LookupViewController Edition header bar title.");
                break;
            case LookupTypeFormat:
                self.title = NSLocalizedString(@"Format", @"LookupViewController Format header bar title.");
                break;
            case LookupTypeCondition:
                self.title = NSLocalizedString(@"Condition", @"LookupViewController Condition header bar title.");
                break;
            case LookupTypeCountry:
                self.title = NSLocalizedString(@"Country", @"LookupViewController Country header bar title.");
                break;
            case LookupTypeState:
                self.title = NSLocalizedString(@"State", @"LookupViewController State header bar title.");
                break;
            case LookupTypeNone:
            default:
                DLog(@"Invalid LookupType found in LookupViewController init: %i.", self.selectedLookupType);
                break;
        }
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
    static NSString* CellIdentifier = @"LookupCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

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
    // Get the selected person and update the correct delegate.
    Lookup* selectedLookup = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [self.delegate lookupViewController:self didSelectValue:selectedLookup.value withLookupType:self.selectedLookupType];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - Fetched results controller

-(NSFetchedResultsController*) fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Lookup" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type == %i", self.selectedLookupType];
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSString* cacheName = @"Lookup";
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];
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
    Lookup* lookup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = lookup.value;
}

#pragma mark - New Lookup Handling

-(void) insertNewObject
{
    NewLookupViewController* newLookupViewController = [[NewLookupViewController alloc] initWithStyle:UITableViewStyleGrouped];
	newLookupViewController.delegate = self;
    newLookupViewController.selectedLookupType = self.selectedLookupType;
	newLookupViewController.detailItem = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
	
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newLookupViewController];
	
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) newLookupViewController:(NewLookupViewController*)controller didFinishWithSave:(BOOL)save
{
    if (save)
    {
		NSError *error;
		if (![self.managedObjectContext save:&error])
        {
			// Update to handle the error appropriately.
			DLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
