//
//  HomeViewController.m
//  Titlz
//
//  Created by David Lains on 2/21/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "HomeViewController.h"
#import "SearchAppViewController.h"
#import "RecentAdditionsCell.h"
#import "Book.h"

@interface HomeViewController()
-(void) searchApp;
-(UITableViewCell*) configureRecentAdditionsCell;
@end

@implementation HomeViewController

@synthesize searchAppViewController = _searchAppViewController;
@synthesize managedObjectContext = _managedObjectContext;

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

    self.tableView.backgroundColor = [UIColor darkGrayColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UIBarButtonItem* searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchApp)];
    self.navigationItem.rightBarButtonItem = searchButton;
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
/*
// Override to support conditional editing of the table view.
-(BOOL) tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
-(void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
-(void) tableView:(UITableView*)tableView moveRowAtIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
-(BOOL) tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
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
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.fetchLimit = 5;
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    [cell setRecentAdditions:[self.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
    
    return cell;
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

@end
