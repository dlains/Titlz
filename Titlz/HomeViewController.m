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
#import "Collection.h"

@interface HomeViewController()

@property(nonatomic, assign) NSUInteger collectionSize;
@property(nonatomic, strong) NSDecimalNumber* collectionValue;
@property(nonatomic, strong) NSDecimalNumber* collectionCost;
@property(nonatomic, assign) NSInteger recentAdditionsPage;
@property(nonatomic, strong) NSArray* collectionList;
@property(nonatomic, assign) BOOL collectionListOpen;
@property(nonatomic, strong) NSString* currentCollection;

-(void) addCollectionItems:(NSArray*)paths;
-(void) removeCollectionItems:(NSArray*)paths;

-(UITableViewCell*) configureRecentAdditionsCell;
-(UITableViewCell*) configureCollectionSizeCellAtIndexPath:(NSIndexPath*)indexPath;
-(UITableViewCell*) configureCollectionValueCell;
-(UITableViewCell*) configureCollectionCostCell;
-(UITableViewCell*) configureCollectionTotalCell;

-(void) searchApp;
-(NSArray*) recentAdditions;
-(void) updateCollectionSize;
-(void) updateCollectionValue;
-(void) updateCollectionCost;
-(void) loadBookDetailView;
-(void) updateCollectionList;

@end

@implementation HomeViewController

@synthesize searchAppViewController = _searchAppViewController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize collectionSize = _collectionSize;
@synthesize collectionValue = _collectionValue;
@synthesize collectionCost = _collectionCost;
@synthesize recentAdditionsPage = _recentAdditionsPage;
@synthesize collectionList = _collectionList;
@synthesize collectionListOpen = _collectionListOpen;
@synthesize currentCollection = _currentCollection;

-(id) initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.title = NSLocalizedString(@"Home", @"HomeViewController header bar title.");
        self.tabBarItem.image = [UIImage imageNamed:@"home"];
        self.collectionListOpen = NO;
        self.currentCollection = [[NSUserDefaults standardUserDefaults] stringForKey:@"currentCollection"];

        // Set the initial data for the collection list.
        self.collectionList = [NSArray arrayWithObject:@"Collection Size"];
    }
    return self;
}

-(void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    numberFormatter = nil;
}

#pragma mark - View lifecycle

-(void) viewDidLoad
{
    [super viewDidLoad];

    //self.tableView.backgroundColor = [UIColor colorWithRed:0.93333 green:0.93333 blue:0.93333 alpha:1.0];
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    self.tableView.separatorColor = [UIColor darkGrayColor];

    UIBarButtonItem* searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchApp)];
    self.navigationItem.rightBarButtonItem = searchButton;
    
    self.collectionListOpen = NO;
    self.recentAdditionsPage = 0;
    [self updateCollectionSize];
    [self updateCollectionValue];
    [self updateCollectionCost];

    if (numberFormatter == nil)
    {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    }
}

-(void) viewDidUnload
{
    [super viewDidUnload];

    numberFormatter = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateCollectionSize];
    [self updateCollectionValue];
    [self updateCollectionCost];
    
    self.collectionListOpen = NO;
    self.recentAdditionsPage = 0;
    
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
            if (self.collectionListOpen)
                return self.collectionList.count;
            else
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
            cell = [self configureCollectionSizeCellAtIndexPath:indexPath];
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
    switch (indexPath.section)
    {
        case HomeRecentAdditionsSection:
        case HomeCollectionValueSection:
        case HomeCollectionCostSection:
        case HomeCollectionTotalSection:
            return nil;
        case HomeCollectionSizeSection:
            return indexPath;
        default:
            return nil;
    };
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case HomeRecentAdditionsSection:
        case HomeCollectionCostSection:
        case HomeCollectionTotalSection:
        case HomeCollectionValueSection:
            cell.backgroundColor = [UIColor whiteColor];
            break;
        case HomeCollectionSizeSection:
            if (indexPath.row == 0)
                cell.backgroundColor = [UIColor whiteColor];
            else
                cell.backgroundColor = [UIColor lightGrayColor];
            break;
        default:
            break;
    }
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self updateCollectionList];

    // Start at index 1 to skip over "Collection Size" name cell name.
    NSMutableArray* paths = [NSMutableArray arrayWithCapacity:self.collectionList.count];
    for (int i = 1; i < self.collectionList.count; i++)
    {
        NSIndexPath* path = [NSIndexPath indexPathForRow:i inSection:HomeCollectionSizeSection];
        [paths addObject:path];
    }
    
    if (indexPath.section == HomeCollectionSizeSection && indexPath.row == 0)
    {
        if (self.collectionListOpen)
        {
            [self.tableView reloadData];
            [self removeCollectionItems:paths];
        }
        else
        {
            [self.tableView reloadData];
            [self addCollectionItems:paths];
        }
    }
    else if (indexPath.section == HomeCollectionSizeSection && indexPath.row > 0)
    {
        // The selected collection name is the new selected collection.
        [[NSUserDefaults standardUserDefaults] setValue:[self.collectionList objectAtIndex:indexPath.row] forKey:@"currentCollection"];
        self.currentCollection = [self.collectionList objectAtIndex:indexPath.row];

        // Update the stats.
        [self updateCollectionSize];
        [self updateCollectionValue];
        [self updateCollectionCost];
        
        [self.tableView reloadData];

        [self removeCollectionItems:paths];
    }
}

-(void) addCollectionItems:(NSArray*)paths
{
    self.collectionListOpen = YES;
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

-(void) removeCollectionItems:(NSArray*)paths
{
    self.collectionListOpen = NO;
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
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

-(UITableViewCell*) configureCollectionSizeCellAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"CollectionSize";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.row == 0)
    {
        cell.textLabel.text = [self.collectionList objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", self.collectionSize];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (self.collectionListOpen)
            cell.imageView.image = [UIImage imageNamed:@"disclosure-triangle-down"];
        else
            cell.imageView.image = [UIImage imageNamed:@"disclosure-triangle-right"];
    }
    else
    {
        cell.textLabel.text = [self.collectionList objectAtIndex:indexPath.row];
        cell.imageView.image = nil;
        cell.detailTextLabel.text = nil;
        if ([self.currentCollection compare:cell.textLabel.text] == NSOrderedSame)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(UITableViewCell*) configureCollectionValueCell
{
    static NSString* CellIdentifier = @"CollectionValue";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = NSLocalizedString(@"Collection Value", @"HomeViewController:configureCollectionValueCell cell text.");
    cell.detailTextLabel.text = [numberFormatter stringFromNumber:self.collectionValue];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(UITableViewCell*) configureCollectionCostCell
{
    static NSString* CellIdentifier = @"CollectionCost";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = NSLocalizedString(@"Collection Cost", @"HomeViewController:configureCollectionCostCell cell text.");
    cell.detailTextLabel.text = [numberFormatter stringFromNumber:self.collectionCost];
    cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

-(UITableViewCell*) configureCollectionTotalCell
{
    static NSString* CellIdentifier = @"CollectionTotal";
    
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
        cell.detailTextLabel.text = [numberFormatter stringFromNumber:total];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.19607 green:0.30980 blue:0.52156 alpha:1.0];
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    else
    {
        // Total is less than zero.
        cell.detailTextLabel.text = [numberFormatter stringFromNumber:total];
        cell.detailTextLabel.textColor = [UIColor redColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    // The view loads faster than the initail data is created, so fake the collection size on the first application launch.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"])
    {
        self.collectionSize = 5;
    }
    else
    {
        if ([self.currentCollection compare:@"Entire Library"] == NSOrderedSame)
        {
            NSFetchRequest* request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext]];
            
            NSError* error = nil;
            self.collectionSize = [self.managedObjectContext countForFetchRequest:request error:&error];
        }
        else
        {
            NSFetchRequest* request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:@"Collection" inManagedObjectContext:self.managedObjectContext]];
            [request setPredicate:[NSPredicate predicateWithFormat:@"name = %@", self.currentCollection]];
            
            NSArray* result = [self.managedObjectContext executeFetchRequest:request error:nil];
            Collection* collection = [result lastObject];
            self.collectionSize = collection.books.count;
        }
    }
}

-(void) updateCollectionValue
{
    if ([self.currentCollection compare:@"Entire Library"] == NSOrderedSame)
    {
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext]];
        
        // Specify that the request should return dictionaries.
        [request setResultType:NSDictionaryResultType];
        
        // Create an expression for the key path.
        NSExpression* keyPathExpression = [NSExpression expressionForKeyPath:@"currentValue"];
        
        // Create an expression to represent sum of current values.
        NSExpression* sumExpression = [NSExpression expressionForFunction:@"sum:" arguments:[NSArray arrayWithObject:keyPathExpression]];
        
        // Create an expression description.
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
    else
    {
        Collection* collection = [Collection findCollectionInContext:self.managedObjectContext withName:self.currentCollection];
        
        double value = 0.0;
        if (collection != nil)
        {
            for (Book* book in collection.books)
            {
                value += [book.currentValue doubleValue];
            }
        }
        self.collectionValue = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:value] decimalValue]];
    }
}

-(void) updateCollectionCost
{
    if ([self.currentCollection compare:@"Entire Library"] == NSOrderedSame)
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
    else
    {
        Collection* collection = [Collection findCollectionInContext:self.managedObjectContext withName:self.currentCollection];
        
        double value = 0.0;
        if (collection != nil)
        {
            for (Book* book in collection.books)
            {
                value += [book.pricePaid doubleValue];
            }
        }
        self.collectionCost = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:value] decimalValue]];
    }
}

-(void) updateCollectionList
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Collection" inManagedObjectContext:self.managedObjectContext]];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray* dbNames = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:dbNames.count + 2];
    [result addObject:@"Collection Size"];
    [result addObject:@"Entire Library"];
    
    for (Collection* collection in dbNames)
    {
        [result addObject:collection.name];
    }
    
    self.collectionList = result;
}

-(void) loadBookDetailView
{
    BookDetailViewController* bookDetailView = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
    bookDetailView.detailItem = [self.recentAdditions objectAtIndex:self.recentAdditionsPage];
    [self.navigationController pushViewController:bookDetailView animated:YES];
}

@end
