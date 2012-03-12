//
//  OpenLibraryLookupViewController.m
//  Titlz
//
//  Created by David Lains on 2/14/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "OpenLibraryLookupViewController.h"
#import "OpenLibraryBookDetails.h"
#import "Book.h"
#import "Person.h"
#import "Worker.h"
#import "Publisher.h"
#import "Photo.h"

@interface OpenLibraryLookupViewController ()
-(void) findAuthors:(NSArray*)authors forBook:(Book*)book;
-(void) findPublisher:(NSString*)publisher forBook:(Book*)book;

@property(nonatomic, assign) BOOL searchInProgress;

@end

@implementation OpenLibraryLookupViewController

@synthesize searchTextField = _searchTextField;
@synthesize activityIndicator = _activityIndicator;
@synthesize searchButton = _searchButton;
@synthesize cancelButton = _cancelButton;
@synthesize resultLabel = _resultLabel;
@synthesize searchInProgress = _searchInProgress;

@synthesize delegate = _delegate;
@synthesize managedObjectContext = _managedObjectContext;

@synthesize openLibrarySearch = _openLibrarySearch;

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"Open Library Search", @"Open Library lookup view controller title.");
    
    [self.searchTextField becomeFirstResponder];
}

-(void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Text Field Handling

-(BOOL) textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    if (self.searchInProgress == NO)
    {
        [self searchButtonPressed:textField];
    }
}

#pragma mark - Event Handling

-(IBAction) searchButtonPressed:(id)sender
{
    self.searchInProgress = YES;
    
    [self.searchTextField resignFirstResponder];
    self.cancelButton.enabled = YES;
    self.resultLabel.hidden = YES;
    
    [self.activityIndicator startAnimating];
    
    self.openLibrarySearch = [[OpenLibrarySearch alloc] initWithSearchTerm:self.searchTextField.text andDelegate:self];
    [self.openLibrarySearch startSearch];
}

-(IBAction) cancelButtonPressed:(id)sender
{
    self.searchInProgress = NO;
    self.cancelButton.enabled = NO;
    
    [self.openLibrarySearch stopSearch];
    [self.activityIndicator stopAnimating];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Open Library Search Delegate

-(void) openLibrarySearchDidFinishWithBookDetails:(OpenLibraryBookDetails*)bookDetails
{
    self.searchInProgress = NO;
    [self.activityIndicator stopAnimating];
    
    if (bookDetails != nil)
    {
        if (bookDetails.dataFound == NO)
        {
            self.resultLabel.hidden = NO;
            self.resultLabel.text = NSLocalizedString(@"There was no data found for that ISBN.", @"OpenLibraryLookupViewController:openLibrarySearchDidFinishWithBookDetails: error text.");
            [self.searchTextField becomeFirstResponder];
            return;
        }
        
        if (bookDetails.dataParsed == NO)
        {
            self.resultLabel.hidden = NO;
            self.resultLabel.text = NSLocalizedString(@"There was a problem reading the Open Library book details.", @"OpenLibraryLookupViewController:openLibrarySearchDidFinishWithBookDetails: error text.");
            [self.searchTextField becomeFirstResponder];
            return;
        }

        Book* newBook = [Book bookInManagedObjectContext:self.managedObjectContext];
        newBook.title = bookDetails.title;
        [self findAuthors:bookDetails.authors forBook:newBook];
        newBook.isbn  = bookDetails.isbn;
        newBook.pages = bookDetails.pages;
        newBook.format = NSLocalizedString(@"Hardcover", @"OpenLibraryLookupViewController default format value for new book.");
        newBook.edition = NSLocalizedString(@"First Edition", @"OpenLibraryLookupViewController default edition value for new book.");
        [self findPublisher:bookDetails.publisher forBook:newBook];
        
        // Get the thumbnail image.
        NSData* thumbnailData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:bookDetails.mediumCover]];
        if (thumbnailData != nil)
        {
            UIImage* thumbnailImage = [UIImage imageWithData:thumbnailData];
            NSData* pngThumbnail = UIImagePNGRepresentation(thumbnailImage);
            UIImage* finalThumbnail = [UIImage imageWithData:pngThumbnail];
            newBook.thumbnail = finalThumbnail;
        }
        
        // Get the full size image.
        NSData* photoData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:bookDetails.largeCover]];
        if (photoData != nil)
        {
            UIImage* photoImage = [UIImage imageWithData:photoData];
            NSData* pngPhoto = UIImagePNGRepresentation(photoImage);
            UIImage* finalPhoto = [UIImage imageWithData:pngPhoto];
            Photo* photo = [Photo photoInManagedObjectContext:self.managedObjectContext];
            photo.image = finalPhoto;
            newBook.photo = photo;
        }

        NewBookViewController* newBookViewController = [[NewBookViewController alloc] initWithStyle:UITableViewStyleGrouped];
        newBookViewController.delegate = self;
        newBookViewController.detailItem = newBook;
          
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:newBookViewController];
        navController.navigationBar.barStyle = UIBarStyleBlack;
            
        [self presentViewController:navController animated:YES completion:nil];
    }
}

-(void) findAuthors:(NSArray *)authors forBook:(Book *)book
{
    if (authors.count > 0)
    {
        for (NSString* author in authors)
        {
            NSArray* splitName = [author componentsSeparatedByString:@" "];
            
            NSString* firstName = nil;
            NSString* middleName = nil;
            NSString* lastName = nil;

            if (splitName.count == 1)
            {
                // Assume last name.
                lastName = [splitName objectAtIndex:0];
            }
            if (splitName.count == 2)
            {
                if ([[splitName objectAtIndex:0] hasSuffix:@","])
                {
                    // Name is "Last, First" format.
                    lastName = [[splitName objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
                    firstName = [splitName objectAtIndex:1];
                }
                else
                {
                    // Name is "First Last" format.
                    firstName = [splitName objectAtIndex:0];
                    lastName = [splitName objectAtIndex:1];
                }
            }
            if (splitName.count == 3)
            {
                if ([[splitName objectAtIndex:0] hasSuffix:@","])
                {
                    // Name is "Last, First MI" format.
                    lastName = [[splitName objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
                    firstName = [splitName objectAtIndex:1];
                    middleName = [[splitName objectAtIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
                }
                else
                {
                    // Name is "First Middle Last" format.
                    firstName = [splitName objectAtIndex:0];
                    middleName = [[splitName objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
                    lastName = [splitName objectAtIndex:2];
                }
            }
            
            Person* person = [Person findPersonInContext:self.managedObjectContext withFirstName:firstName middleName:middleName andLastName:lastName];
            Worker* worker = [Worker workerInManagedObjectContext:self.managedObjectContext];
            worker.person = person;
            worker.title = @"Author";
            worker.book = book;
            [book addWorkersObject:worker];
        }
    }
}

-(void) findPublisher:(NSString*)publisherName forBook:(Book*)book
{
    Publisher* publisher = [Publisher findPublisherInContext:self.managedObjectContext withName:publisherName];
    book.publisher = publisher;
}

-(void) openLibraryConnectionFailed
{
    [self.activityIndicator stopAnimating];

    [DAlertView showAlertWithTitle:NSLocalizedString(@"Network Error", @"OpenLibraryLookupViewController:openLibraryConnectionFailed error title") message:NSLocalizedString(@"Unable to connect to Open Library.", @"") buttonTitle:NSLocalizedString(@"OK", @"OK")];

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - New Book Delegate

-(void) newBookViewController:(NewBookViewController*)controller didFinishWithSave:(BOOL)save
{
    [self.delegate newBookViewController:controller didFinishWithSave:save];
//    if (save)
//    {
//        if (![ContextUtil saveContext:self.managedObjectContext])
//        {
//            // Didn't save, so don't dismiss the modal view.
//            return;
//        }
//    }
//    else
//    {
//        // Canceled the insert, remove the managed object.
//        [self.managedObjectContext deleteObject:controller.detailItem];
//        [ContextUtil saveContext:self.managedObjectContext];
//    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
