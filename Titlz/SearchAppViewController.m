//
//  SearchAppViewController.m
//  Titlz
//
//  Created by David Lains on 2/21/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "SearchAppViewController.h"
#import "BookDetailViewController.h"
#import "PersonDetailViewController.h"
#import "CollectionDetailViewController.h"
#import "Book.h"
#import "Person.h"
#import "Collection.h"

@interface SearchAppViewController()
-(void) findBooksMatching:(NSString*)searchTerm;
-(void) findPeopleMatching:(NSString*)searchTerm;
-(void) findCollectionsMatching:(NSString*)searchTerm;
@end


@implementation SearchAppViewController

@synthesize searchBar = _searchBar;
@synthesize foundBooks = _foundBooks;
@synthesize foundPeople = _foundPeople;
@synthesize foundCollections = _foundCollections;
@synthesize tableData = _tableData;
@synthesize sectionTitles = _sectionTitles;

@synthesize managedObjectContext = _managedObjectContext;

-(id) initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

-(void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    self.foundBooks = nil;
    self.foundPeople = nil;
    self.foundCollections = nil;
    self.tableData = nil;
    self.sectionTitles = nil;
}

#pragma mark - View lifecycle

-(void) viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor colorWithRed:0.93333 green:0.93333 blue:0.93333 alpha:1.0];

    self.searchBar = [[UISearchBar alloc] initWithFrame:self.tableView.bounds];
    [self.searchBar sizeToFit];
    self.searchBar.delegate = self;
    self.searchBar.tintColor = [UIColor blackColor];
    self.searchBar.placeholder = NSLocalizedString(@"Search Titlz", @"SearchAppViewController:viewDidLoad search bar placeholder text.");
    self.navigationItem.titleView = self.searchBar;
    [self.searchBar becomeFirstResponder];
}

-(void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
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
    return YES;
}

#pragma mark - Search Bar Delegate

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (self.tableData == nil)
    {
        self.tableData = [[NSMutableArray alloc] initWithCapacity:3];
    }
    [self.tableData removeAllObjects];
    
    if (self.sectionTitles == nil)
    {
        self.sectionTitles = [[NSMutableArray alloc] initWithCapacity:3];
    }
    [self.sectionTitles removeAllObjects];
    [self.sectionTitles addObject:@""];
    
    [self.tableView reloadData];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    
    NSString* searchString = searchBar.text;

    [self.tableData removeAllObjects];
    [self.sectionTitles removeAllObjects];
    
    [self findBooksMatching:searchString];
    if (self.foundBooks.count > 0)
    {
        [self.tableData addObject:self.foundBooks];
        [self.sectionTitles addObject:NSLocalizedString(@"Found Books", @"SearchAppViewController:searchBarSearchButtonClicked books section title.")];
    }
    
    [self findPeopleMatching:searchString];
    if (self.foundPeople.count > 0)
    {
        [self.tableData addObject:self.foundPeople];
        [self.sectionTitles addObject:NSLocalizedString(@"Found People", @"SearchAppViewController:searchBarSearchButtonClicked people section title.")];
    }
    
    [self findCollectionsMatching:searchString];
    if (self.foundCollections.count > 0)
    {
        [self.tableData addObject:self.foundCollections];
        [self.sectionTitles addObject:NSLocalizedString(@"Found Collections", @"SearchAppViewController:searchBarSearchButtonClicked collection section title.")];
    }

    if (self.tableData.count == 0 && self.sectionTitles.count == 0)
    {
        // Nothing was found for the given search term. Show a section header title to that affect.
        [self.sectionTitles addObject:NSLocalizedString(@"      Your search had no results.", @"SearchAppViewController:searchBarSearchButtonClicked nothing found title.")];
    }

    [self.tableView reloadData];
}

-(void) findBooksMatching:(NSString*)searchTerm
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.fetchBatchSize = 10;
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchTerm];
    fetchRequest.predicate = predicate;

    self.foundBooks = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
}

-(void) findPeopleMatching:(NSString*)searchTerm
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.fetchBatchSize = 10;
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"firstName CONTAINS[cd] %@ OR middleName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", searchTerm, searchTerm, searchTerm];
    fetchRequest.predicate = predicate;

    self.foundPeople = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
}

-(void) findCollectionsMatching:(NSString*)searchTerm
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Collection" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.fetchBatchSize = 10;
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchTerm];
    fetchRequest.predicate = predicate;

    self.foundCollections = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
}

#pragma mark - Table view data source

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    if (self.tableData.count == 0)
    {
        // If no data was found we still need one section to display the 'nothing found' message.
        return 1;
    }
    
    return self.tableData.count;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableData.count == 0)
    {
        return 0;
    }
    
    NSMutableArray* array = [self.tableData objectAtIndex:section];
    return array.count;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"SearchCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSMutableArray* sectionArray = [self.tableData objectAtIndex:indexPath.section];
    id value = [sectionArray objectAtIndex:indexPath.row];
    
    if ([value isKindOfClass:[Book class]])
    {
        Book* book = (Book*)value;
        cell.textLabel.text = book.title;
    }
    if ([value isKindOfClass:[Person class]])
    {
        Person* person = (Person*)value;
        cell.textLabel.text = person.fullName;
    }
    if ([value isKindOfClass:[Collection class]])
    {
        Collection* collection = (Collection*)value;
        cell.textLabel.text = collection.name;
    }
    
    return cell;
}


-(BOOL) tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return NO;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionTitles objectAtIndex:section];
}

#pragma mark - Table view delegate

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSMutableArray* sectionArray = [self.tableData objectAtIndex:indexPath.section];
    id value = [sectionArray objectAtIndex:indexPath.row];
    
    if ([value isKindOfClass:[Book class]])
    {
        Book* book = (Book*)value;
        BookDetailViewController* controller = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
        controller.detailItem = book;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    if ([value isKindOfClass:[Person class]])
    {
        Person* person = (Person*)value;
        PersonDetailViewController* controller = [[PersonDetailViewController alloc] initWithNibName:@"PersonDetailViewController" bundle:nil];
        controller.detailItem = person;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }

    if ([value isKindOfClass:[Collection class]])
    {
        Collection* collection = (Collection*)value;
        CollectionDetailViewController* controller = [[CollectionDetailViewController alloc] initWithNibName:@"CollectionDetailViewController" bundle:nil];
        controller.detailItem = collection;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
}

@end
