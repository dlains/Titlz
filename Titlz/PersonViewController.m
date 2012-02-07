//
//  PersonViewController.m
//  Titlz
//
//  Created by David Lains on 1/4/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "PersonViewController.h"
#import "PersonDetailViewController.h"
#import "AlphaIndexFetchedResultsController.h"
#import "Person.h"

@interface PersonViewController ()
-(void) configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
-(NSFetchedResultsController*) fetchedResultsControllerWithPredicate:(NSPredicate*)predicate;
-(NSPredicate*) predicateForSearchString:(NSString*)searchString;
-(NSPredicate*) predicateForSearchComponents:(NSArray*)stringComponents;
@end

@implementation PersonViewController

@synthesize personDetailViewController = _personDetailViewController;
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
        self.title = NSLocalizedString(@"People", @"PersonViewController header bar title.");
        self.tabBarItem.image = [UIImage imageNamed:@"user"];
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
    // Check for the magnifying glass first.
    if ([title isEqualToString:UITableViewIndexSearch])
    {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:NO];
        return -1;
    }
    
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"PersonCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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

#pragma mark - Table view delegate

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.selectionMode)
    {
        // Get the selected person and update the correct delegate.
        Person* selectedPerson = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [self.delegate personViewController:self didSelectPerson:selectedPerson withPersonType:self.personSelectionType];
        [self.navigationController popViewControllerAnimated:YES];
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
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setPredicate:predicate];

    // Edit the sort key as appropriate.
    // TODO: Offer option to sort by first name or last name?
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSString* cacheName = @"Person";
    if (predicate)
        cacheName = nil;

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    AlphaIndexFetchedResultsController* controller = [[AlphaIndexFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstLetterOfName" cacheName:cacheName];
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

#pragma mark - Search delegate

-(BOOL) searchDisplayController:(UISearchDisplayController*)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSPredicate* predicate = [self predicateForSearchString:searchString];
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:predicate];
    return YES;
}

-(void) searchDisplayControllerWillEndSearch:(UISearchDisplayController*)controller
{
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:nil];
}

-(NSPredicate*) predicateForSearchString:(NSString*)searchString
{
    searchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray* stringComponents = [searchString componentsSeparatedByString:@" "];
    if ([stringComponents count] > 1)
    {
        return [self predicateForSearchComponents:stringComponents];
    }
    else
    {
        return [NSPredicate predicateWithFormat:@"firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", searchString, searchString];
    }
}

-(NSPredicate*) predicateForSearchComponents:(NSArray*)stringComponents
{
    if ([stringComponents count] < 1)
        return nil;

    NSString* firstComponent = [stringComponents objectAtIndex:0];
    NSString* lastComponent = [stringComponents lastObject];
    
    NSPredicate* firstAndLastInOrderPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"firstName CONTAINS[cd] %@", firstComponent], [NSPredicate predicateWithFormat:@"lastName CONTAINS[cd] %@", lastComponent], nil]];
    
    NSPredicate* firstAndLastInReverseOrderPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"firstName CONTAINS[cd] %@", lastComponent], [NSPredicate predicateWithFormat:@"lastName CONTAINS[cd] %@", firstComponent], nil]];
    
    return [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:firstAndLastInOrderPredicate, firstAndLastInReverseOrderPredicate, nil]];
}

#pragma mark - New Person Handling

-(void) insertNewObject
{
    NewPersonViewController* newPersonViewController = [[NewPersonViewController alloc] initWithStyle:UITableViewStyleGrouped];
	newPersonViewController.delegate = self;
	newPersonViewController.detailItem = [Person personInManagedObjectContext:self.managedObjectContext];
	
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
	
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) newPersonViewController:(NewPersonViewController *)controller didFinishWithSave:(BOOL)save
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
    
    [self.tableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
}

@end
