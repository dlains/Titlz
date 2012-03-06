//
//  HomeViewController.m
//  Titlz
//
//  Created by David Lains on 2/21/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "HomeViewController.h"
#import "SearchAppViewController.h"
#import "BookDetailViewController.h"
#import "Book.h"

@interface HomeViewController()

@property(nonatomic, assign) NSUInteger collectionSize;
@property(nonatomic, strong) NSDecimalNumber* collectionValue;
@property(nonatomic, strong) NSDecimalNumber* collectionCost;
@property(nonatomic, assign) NSInteger recentAdditionsPage;

-(UITableViewCell*) configureRecentAdditionsCell;
-(UITableViewCell*) configureCollectionSizeCell;
-(UITableViewCell*) configureCollectionValueCell;
-(UITableViewCell*) configureCollectionCostCell;
-(UITableViewCell*) configureCollectionTotalCell;

-(void) searchApp;
-(NSArray*) recentAdditions;
-(void) updateCollectionSize;
-(void) updateCollectionValue;
-(void) updateCollectionCost;
-(void) loadBookDetailView;
@end

@implementation HomeViewController

@synthesize searchAppViewController = _searchAppViewController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize collectionSize = _collectionSize;
@synthesize collectionValue = _collectionValue;
@synthesize collectionCost = _collectionCost;
@synthesize recentAdditionsPage = _recentAdditionsPage;

-(id) initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.title = NSLocalizedString(@"Home", @"HomeViewController header bar title.");
        self.tabBarItem.image = [UIImage imageNamed:@"home"];
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

    self.tableView.backgroundColor = [UIColor colorWithRed:0.93333 green:0.93333 blue:0.93333 alpha:1.0];

    UIBarButtonItem* searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchApp)];
    self.navigationItem.rightBarButtonItem = searchButton;
    
    self.recentAdditionsPage = 0;
    [self updateCollectionSize];
    [self updateCollectionValue];
    [self updateCollectionCost];
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
    
    [self updateCollectionSize];
    [self updateCollectionValue];
    [self updateCollectionCost];
    
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
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
    return HomeSectionCount;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case HomeRecentAdditionsSection:
            return 1;
        case HomeCollectionSizeSection:
            return 1;
        case HomeCollectionValueSection:
            return 1;
        case HomeCollectionCostSection:
            return 1;
        case HomeCollectionTotalSection:
            return 1;
        default:
            break;
    }
    return 0;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section)
    {
        case HomeRecentAdditionsSection:
            cell = [self configureRecentAdditionsCell];
            break;
        case HomeCollectionSizeSection:
            cell = [self configureCollectionSizeCell];
            break;
        case HomeCollectionValueSection:
            cell = [self configureCollectionValueCell];
            break;
        case HomeCollectionCostSection:
            cell = [self configureCollectionCostCell];
            break;
        case HomeCollectionTotalSection:
            cell = [self configureCollectionTotalCell];
            break;
        default:
            DLog(@"Invalid HomeViewController section found: %i.", indexPath.section);
            break;
    }
    
    return cell;
}

-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == HomeRecentAdditionsSection)
    {
        return 150.0f;
    }
    else
    {
        return UITableViewAutomaticDimension;
    }
}

-(BOOL) tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return NO;
}

-(BOOL) tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
    return NO;
}

#pragma mark - Table view delegate

-(NSIndexPath*) tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    return nil;
}

-(UITableViewCell*) configureRecentAdditionsCell
{
    RecentAdditionsCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"RecentAdditionsCell"];
    
    if(cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"RecentAdditionsCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.delegate = self;
    [cell setRecentAdditions:[self recentAdditions]];
    
    return cell;
}

-(UITableViewCell*) configureCollectionSizeCell
{
    static NSString* CellIdentifier = @"CollectionCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = NSLocalizedString(@"Collection Size", @"HomeViewController:configureCollectionSizeCell cell text.");
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", self.collectionSize];
    
    return cell;
}

-(UITableViewCell*) configureCollectionValueCell
{
    static NSString* CellIdentifier = @"CollectionCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = NSLocalizedString(@"Collection Value", @"HomeViewController:configureCollectionValueCell cell text.");
    cell.detailTextLabel.text = [NSString stringWithFormat:@"$%@", self.collectionValue];
    
    return cell;
}

-(UITableViewCell*) configureCollectionCostCell
{
    static NSString* CellIdentifier = @"CollectionCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = NSLocalizedString(@"Collection Cost", @"HomeViewController:configureCollectionCostCell cell text.");
    cell.detailTextLabel.text = [NSString stringWithFormat:@"$%@", self.collectionCost];
    
    return cell;
}

-(UITableViewCell*) configureCollectionTotalCell
{
    static NSString* CellIdentifier = @"CollectionCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = NSLocalizedString(@"Collection Total", @"HomeViewController:configureCollectionTotalCell cell text.");
    
    NSDecimalNumber* total = [self.collectionValue decimalNumberBySubtracting:self.collectionCost];
    
    NSComparisonResult result = [total compare:[NSDecimalNumber zero]];
    if (result == NSOrderedDescending || result == NSOrderedSame)
    {
        // Total is greater than or equal to zero.
        cell.detailTextLabel.text = [NSString stringWithFormat:@"$%@", total];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.19607 green:0.30980 blue:0.52156 alpha:1.0];
    }
    else
    {
        // Total is less than zero.
        cell.detailTextLabel.text = [NSString stringWithFormat:@"$(%@)", total];
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}

#pragma mark - Recent Additions Page Delegate

-(void) didUpdateCurrentPageTo:(NSInteger)page
{
    self.recentAdditionsPage = page;
}

-(void) didSelectCurrentPage
{
    [self loadBookDetailView];
}

#pragma mark - Local Methods

-(void) searchApp
{
    // Open the search view.
    if (self.searchAppViewController == nil)
    {
        self.searchAppViewController = [[SearchAppViewController alloc] initWithStyle:UITableViewStyleGrouped];
    }
    self.searchAppViewController.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:self.searchAppViewController animated:YES];
}

-(NSArray*) recentAdditions
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.fetchLimit = 5;
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

-(void) updateCollectionSize
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext]];
    
    NSError* error = nil;
    self.collectionSize = [self.managedObjectContext countForFetchRequest:request error:&error];
}

-(void) updateCollectionValue
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext]];
    
    // Specify that the request should return dictionaries.
    [request setResultType:NSDictionaryResultType];
    
    // Create an expression for the key path.
    NSExpression* keyPathExpression = [NSExpression expressionForKeyPath:@"currentValue"];
    
    // Create an expression to represent the minimum value at the key path 'creationDate'
    NSExpression* sumExpression = [NSExpression expressionForFunction:@"sum:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    // Create an expression description using the minExpression and returning a date.
    NSExpressionDescription* expressionDescription = [[NSExpressionDescription alloc] init];
    
    // The name is the key that will be used in the dictionary for the return value.
    [expressionDescription setName:@"collectionValue"];
    [expressionDescription setExpression:sumExpression];
    [expressionDescription setExpressionResultType:NSDecimalAttributeType];
    
    // Set the request's properties to fetch just the property represented by the expressions.
    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    
    // Execute the fetch.
    NSError* error = nil;
    NSArray* objects = [self.managedObjectContext executeFetchRequest:request error:&error];

    if (objects.count > 0)
    {
        self.collectionValue = [[objects objectAtIndex:0] valueForKey:@"collectionValue"];
    }
    else
    {
        self.collectionValue = [NSDecimalNumber zero];
    }
}

-(void) updateCollectionCost
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext]];
    
    // Specify that the request should return dictionaries.
    [request setResultType:NSDictionaryResultType];
    
    // Create an expression for the key path.
    NSExpression* keyPathExpression = [NSExpression expressionForKeyPath:@"pricePaid"];
    
    // Create an expression to represent the minimum value at the key path 'creationDate'
    NSExpression* sumExpression = [NSExpression expressionForFunction:@"sum:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    // Create an expression description using the minExpression and returning a date.
    NSExpressionDescription* expressionDescription = [[NSExpressionDescription alloc] init];
    
    // The name is the key that will be used in the dictionary for the return value.
    [expressionDescription setName:@"collectionCost"];
    [expressionDescription setExpression:sumExpression];
    [expressionDescription setExpressionResultType:NSDecimalAttributeType];
    
    // Set the request's properties to fetch just the property represented by the expressions.
    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    
    // Execute the fetch.
    NSError* error = nil;
    NSArray* objects = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (objects.count > 0)
    {
        self.collectionCost = [[objects objectAtIndex:0] valueForKey:@"collectionCost"];
    }
    else
    {
        self.collectionCost = [NSDecimalNumber zero];
    }
}

-(void) loadBookDetailView
{
    BookDetailViewController* bookDetailView = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
    bookDetailView.detailItem = [self.recentAdditions objectAtIndex:self.recentAdditionsPage];
    [self.navigationController pushViewController:bookDetailView animated:YES];
}

@end
