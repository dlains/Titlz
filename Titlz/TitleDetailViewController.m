//
//  TitleDetailViewController.m
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import "TitleDetailViewController.h"
#import "Title.h"

@interface TitleDetailViewController ()
-(void) configureView;
-(void) doneButtonPressed;
-(void) cancelButtonPressed;
-(UITableViewCell*) configureNameCell;
-(UITableViewCell*) configureEditionCells;
@end

@implementation TitleDetailViewController

@synthesize detailItem = _detailItem;
@synthesize editing = _editing;

#pragma mark - Managing the detail item

-(void) setDetailItem:(Title*)detailItem
{
    if(_detailItem != detailItem)
    {
        _detailItem = detailItem;
        
        // Update the view.
        [self configureView];
    }
}

-(void) configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem)
    {
        
    }
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
	// Do any additional setup after loading the view, typically from a nib.
    if (self.editing)
    {
        self.title = @"New Title";
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
        self.navigationItem.rightBarButtonItem = doneButton;
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    else
    {
        self.title = @"Title";
    }
//    self.navigationItem.leftBarButtonItem = ;
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

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Title", @"Title");
    }
    return self;
}

#pragma mark -
#pragma mark Button Processing

-(void) doneButtonPressed
{
    // Save the changes.
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void) cancelButtonPressed
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table View Methods.

// Customize the number of sections in the table view.
-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return TitleDetailSectionCount;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case NameSection:
            return 1;
        case EditionSection:
            return self.detailItem.editions.count;
        case AuthorSection:
            return self.detailItem.authors.count;
        case EditorSection:
            return self.detailItem.editors.count;
        case IllustratorSection:
            return self.detailItem.illustrators.count;
        case ContributorSection:
            return self.detailItem.contributors.count;
        case BookSection:
            return self.detailItem.books.count;
        case CollectionSection:
            return self.detailItem.collections.count;
        default:
            return 0;
    }
}

// Customize the appearance of table view cells.
-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section)
    {
        case NameSection:
            cell = [self configureNameCell];
            break;
        case EditionSection:
            cell = [self configureEditionCells];
            break;
        default:
            break;
    }
    
    return cell;
}

-(UITableViewCell*) configureNameCell
{
    static NSString* CellIdentifier = @"NameCell";
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.editing = TRUE;
    }
    
    cell.textLabel.text = self.detailItem.name;
    return cell;
}

-(UITableViewCell*) configureEditionCells
{
    return nil;
}

@end
