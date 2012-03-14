//
//  CollectionDetailViewController.m
//  Titlz
//
//  Created by David Lains on 1/30/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "CollectionDetailViewController.h"
#import "BookViewController.h"
#import "BookDetailViewController.h"
#import "EditableTextCell.h"
#import "Collection.h"
#import "Worker.h"
#import "Person.h"
#import "Book.h"

@interface CollectionDetailViewController ()
-(void) configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
-(Book*) sortedBookFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath;
-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath;
-(void) loadBookView;
-(void) loadBookDetailViewForBookAtIndexPath:(NSIndexPath*)indexPath;
@end

@implementation CollectionDetailViewController

@synthesize detailItem = _detailItem;

#pragma mark - Initialization

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

    self.title = self.detailItem.name;

    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadBookView)];
    self.navigationItem.rightBarButtonItem = addButton;
    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) updateRightBarButtonItemState
{
	// Conditionally enable the right bar button item -- it should only be enabled if the title is in a valid state for saving.
    self.navigationItem.rightBarButtonItem.enabled = [self.detailItem validateForUpdate:NULL];
}


#pragma mark - Table view data source

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.detailItem.books.count;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"BooksCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Table view delegate

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.editing)
        return;
    
    [self loadBookDetailViewForBookAtIndexPath:indexPath];
    /*
    switch (indexPath.section)
    {
        case CollectionDataSection:
            break;
        case CollectionBookSection:
            if (indexPath.row == self.detailItem.books.count)
                [self loadBookView];
            else
                [self loadBookDetailViewForBookAtIndexPath:indexPath];
            break;
        default:
            DLog(@"Invalid CollectionDetailViewController section found: %i.", indexPath.section);
            break;
    }
     */
}

-(void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        switch (indexPath.section)
        {
            case CollectionDataSection:
                // Never delete the data section rows.
                break;
            case CollectionBookSection:
                [self.detailItem removeBooksObject:[self sortedBookFromSet:self.detailItem.books atIndexPath:indexPath]];
                [self deleteRowAtIndexPath:indexPath];
                break;
            default:
                break;
        }
        
        // Save the context.
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
    }   
}

-(BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section)
    {
        case CollectionDataSection:
            return NO;
        default:
            return YES;
    }
}

-(void) configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    Book* book = [self sortedBookFromSet:self.detailItem.books atIndexPath:indexPath];
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

#pragma mark - Book Selection Delegate Method

-(void) bookViewController:(BookViewController *)controller didSelectBook:(Book*)book forPersonType:(PersonType)type
{
    [self.detailItem addBooksObject:book];
    [ContextUtil saveContext:self.detailItem.managedObjectContext];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

-(void) bookViewController:(BookViewController*)controller didSelectBooks:(NSArray*)books
{
    if (books.count > 0)
    {
        for (Book* book in books)
        {
            [self.detailItem addBooksObject:book];
        }
        
        [ContextUtil saveContext:self.detailItem.managedObjectContext];
    }

    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - Local Helper Methods

-(Book*) sortedBookFromSet:(NSSet*)set atIndexPath:(NSIndexPath*)indexPath
{
    if (set.count <= 0 || indexPath.row > set.count - 1)
        return nil;
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sortableTitle" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray* sortedBooks = [set sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedBooks objectAtIndex:indexPath.row];
}

-(void) deleteRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    NSArray* paths = [NSArray arrayWithObjects:path, nil];
    
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
}

-(void) loadBookView
{
    BookViewController* bookViewController = [[BookViewController alloc] initWithManagedObjectContext:self.detailItem.managedObjectContext];
    bookViewController.delegate = self;
    bookViewController.selectionMode = MultipleSelection;
    bookViewController.excludedBooks = self.detailItem.books;
    
	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:bookViewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(void) loadBookDetailViewForBookAtIndexPath:(NSIndexPath*)indexPath
{
    BookDetailViewController* bookDetailViewController = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
    Book* selectedBook = [self sortedBookFromSet:self.detailItem.books atIndexPath:indexPath];
    
    if (selectedBook)
    {
        bookDetailViewController.detailItem = selectedBook;
        [self.navigationController pushViewController:bookDetailViewController animated:YES];
    }
}

@end
