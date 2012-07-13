//
//  InitialData.m
//  Titlz
//
//  Created by David Lains on 2/27/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "InitialData.h"
#import "Collection.h"
#import "Publisher.h"
#import "Person.h"
#import "Book.h"
#import "Lookup.h"
#import "Photo.h"
#import "Worker.h"

@interface InitialData()

@property(nonatomic, weak) NSManagedObjectContext* managedObjectContext;

-(void) createCollections;
-(void) createBooks;
-(NSDate*) dateWithDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;
-(Person*) personWithFirst:(NSString*)first middle:(NSString*)middle last:(NSString*)last;
-(Publisher*) publisherWithName:(NSString*)name parent:(NSString*)parent street:(NSString*)street city:(NSString*)city state:(NSString*)state postalCode:(NSString*)postalCode country:(NSString*)country;
-(void) loadLookupData;
-(void) createEditionValues;
-(void) createFormatValues;
-(void) createConditionValues;
-(void) createCountryValues;
-(void) createStateValues;
-(void) createWorkerValues;
-(void) createLocationValues;
@end


@implementation InitialData

@synthesize managedObjectContext = _managedObjectContext;

-(void) createInManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    NSLog(@"Creating initial data on first application run.");
 
    self.managedObjectContext = managedObjectContext;

    [self createCollections];
    [self createBooks];
    [ContextUtil saveContext:managedObjectContext];

    [self loadLookupData];
    [ContextUtil saveContext:managedObjectContext];

    // Initial data has been created at this point, so firstLaunch can be set to NO.
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
}

#pragma mark - Initial Book Data

-(void) createCollections
{
    Collection* collection = nil;

    collection = [Collection collectionInManagedObjectContext:self.managedObjectContext];
    collection.name = NSLocalizedString(@"My Collection", @"InitialData:createCollections initial collection name.");

    collection = [Collection collectionInManagedObjectContext:self.managedObjectContext];
    collection.name = NSLocalizedString(@"Reading List", @"InitialData:createCollections initial collection name.");
}

-(void) createBooks
{
    Book* book = nil;
    Worker* worker = nil;
    Photo* photo = nil;
    UIImage* image = nil;
    
    CGRect thumbnailRect = CGRectMake(0, 0, 175, 260);
    
    // Create a collection for these books.
    Collection* collection = [Collection collectionInManagedObjectContext:self.managedObjectContext];
    collection.name = NSLocalizedString(@"Classic Books", @"InitialData:createBooks initial collection name.");
    
    // Slaughterhouse Five
    book = [Book bookInManagedObjectContext:self.managedObjectContext];
    worker = [Worker workerInManagedObjectContext:self.managedObjectContext];
    photo = [Photo photoInManagedObjectContext:self.managedObjectContext];
    book.title = @"Slaughterhouse-Five";
    worker.person = [self personWithFirst:@"Kurt" middle:nil last:@"Vonnegut"];
    worker.title = @"Author";
    [book addWorkersObject:worker];
    image = [UIImage imageNamed:@"slaughterhouse-five.png"];
    photo.image = image;
    book.photo = photo;
    // Create a thumbnail version of the image for the book object.
	UIGraphicsBeginImageContext(thumbnailRect.size);
	[image drawInRect:thumbnailRect];
	book.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    book.edition = @"First Edition";
    book.format = @"Hardcover";
    book.pages = [NSNumber numberWithInt:186];
    book.isbn = @"0-385-31208-3";
    book.releaseDate = [self dateWithDay:1 month:1 year:1969];
    book.publisher = [self publisherWithName:@"Delacorte" parent:@"Random House" street:@"1745 Broadway" city:@"New York" state:@"New York" postalCode:@"10019" country:@"United States"];
    [collection addBooksObject:book];
    
    // The Grapes of Wrath
    book = [Book bookInManagedObjectContext:self.managedObjectContext];
    worker = [Worker workerInManagedObjectContext:self.managedObjectContext];
    photo = [Photo photoInManagedObjectContext:self.managedObjectContext];
    book.title = @"The Grapes of Wrath";
    worker.person = [self personWithFirst:@"John" middle:nil last:@"Steinbeck"];
    worker.title = @"Author";
    [book addWorkersObject:worker];
    image = [UIImage imageNamed:@"thegrapesofwrath.png"];
    photo.image = image;
    book.photo = photo;
    // Create a thumbnail version of the image for the book object.
	UIGraphicsBeginImageContext(thumbnailRect.size);
	[image drawInRect:thumbnailRect];
	book.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    book.edition = @"First Edition";
    book.format = @"Hardcover";
    book.pages = [NSNumber numberWithInt:619];
    book.releaseDate = [self dateWithDay:1 month:1 year:1939];
    book.publisher = [self publisherWithName:@"Viking" parent:@"The Penguin Group" street:@"375 Hudson Street" city:@"New York" state:@"New York" postalCode:@"10014" country:@"United States"];
    [collection addBooksObject:book];
    
    // The Maltese Falcon
    book = [Book bookInManagedObjectContext:self.managedObjectContext];
    worker = [Worker workerInManagedObjectContext:self.managedObjectContext];
    photo = [Photo photoInManagedObjectContext:self.managedObjectContext];
    book.title = @"The Maltese Falcon";
    worker.person = [self personWithFirst:@"Dashiell" middle:nil last:@"Hammett"];
    worker.title = @"Author";
    [book addWorkersObject:worker];
    image = [UIImage imageNamed:@"themaltesefalcon.png"];
    photo.image = image;
    book.photo = photo;
    // Create a thumbnail version of the image for the book object.
	UIGraphicsBeginImageContext(thumbnailRect.size);
	[image drawInRect:thumbnailRect];
	book.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    book.edition = @"First Edition";
    book.format = @"Hardcover";
    book.releaseDate = [self dateWithDay:1 month:1 year:1930];
    book.publisher = [self publisherWithName:@"Alfred A. Knopf" parent:@"Knopf Doubleday Publishing" street:@"1745 Broadway" city:@"New York" state:@"New York" postalCode:@"10019" country:@"United States"];
    [collection addBooksObject:book];

    // Catch 22
    book = [Book bookInManagedObjectContext:self.managedObjectContext];
    worker = [Worker workerInManagedObjectContext:self.managedObjectContext];
    photo = [Photo photoInManagedObjectContext:self.managedObjectContext];
    book.title = @"Catch-22";
    worker.person = [self personWithFirst:@"Joseph" middle:nil last:@"Heller"];
    worker.title = @"Author";
    [book addWorkersObject:worker];
    image = [UIImage imageNamed:@"catch22.png"];
    photo.image = image;
    book.photo = photo;
    // Create a thumbnail version of the image for the book object.
	UIGraphicsBeginImageContext(thumbnailRect.size);
	[image drawInRect:thumbnailRect];
	book.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    book.edition = @"First Edition";
    book.format = @"Hardcover";
    book.pages = [NSNumber numberWithInt:453];
    book.isbn = @"0-684-83339-5";
    book.releaseDate = [self dateWithDay:11 month:11 year:1961];
    book.publisher = [self publisherWithName:@"Simon & Schuster" parent:nil street:@"1230 Avenue of the Americas" city:@"New York" state:@"New York" postalCode:@"10020" country:@"United States"];
    [collection addBooksObject:book];
    
    // The Great Gatsby
    book = [Book bookInManagedObjectContext:self.managedObjectContext];
    worker = [Worker workerInManagedObjectContext:self.managedObjectContext];
    photo = [Photo photoInManagedObjectContext:self.managedObjectContext];
    book.title = @"The Great Gatsby";
    worker.person = [self personWithFirst:@"F." middle:@"Scott" last:@"Fitzgerald"];
    worker.title = @"Author";
    [book addWorkersObject:worker];
    image = [UIImage imageNamed:@"thegreatgatsby.png"];
    photo.image = image;
    book.photo = photo;
    // Create a thumbnail version of the image for the book object.
	UIGraphicsBeginImageContext(thumbnailRect.size);
	[image drawInRect:thumbnailRect];
	book.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    book.edition = @"First Edition";
    book.format = @"Hardcover";
    book.pages = [NSNumber numberWithInt:218];
    book.releaseDate = [self dateWithDay:10 month:4 year:1925];
    book.publisher = [self publisherWithName:@"Scribner" parent:@"Simon & Schuster" street:@"1230 Avenue of the Americas" city:@"New York" state:@"New York" postalCode:@"10020" country:@"United States"];
    [collection addBooksObject:book];
}

-(Person*) personWithFirst:(NSString*)first middle:(NSString*)middle last:(NSString*)last
{
    Person* person = [Person personInManagedObjectContext:self.managedObjectContext];
    
    person.firstName = first;
    person.middleName = middle;
    person.lastName = last;
    
    return person;
}

-(Publisher*) publisherWithName:(NSString*)name parent:(NSString*)parent street:(NSString*)street city:(NSString*)city state:(NSString*)state postalCode:(NSString*)postalCode country:(NSString*)country
{
    Publisher* publisher = [Publisher publisherInManagedObjectContext:self.managedObjectContext];
    
    publisher.name = name;
    publisher.parent = parent;
    publisher.street = street;
    publisher.city = city;
    publisher.state = state;
    publisher.postalCode = postalCode;
    publisher.country = country;
    
    return publisher;
}

-(NSDate*) dateWithDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year
{
    NSDateComponents* date = [[NSDateComponents alloc] init];
    date.day = 10;
    date.month = 4;
    date.year = 1925;
    return [[NSCalendar currentCalendar] dateFromComponents:date];
}

#pragma mark - Initial Lookup Data

-(void) loadLookupData
{
    [self createEditionValues];
    [self createFormatValues];
    [self createConditionValues];
    [self createCountryValues];
    [self createStateValues];
    [self createWorkerValues];
    [self createLocationValues];
}

-(void) createEditionValues
{
    Lookup* lookup = nil;
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:0];
    lookup.name  = NSLocalizedString(@"First Edition", @"Book Edition 'First Edition' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:1];
    lookup.name  = NSLocalizedString(@"First U.K. Edition", @"Book Edition 'First U.K. Edition' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:2];
    lookup.name  = NSLocalizedString(@"First U.S. Edition", @"Book Edition 'First U.S. Edition' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:3];
    lookup.name  = NSLocalizedString(@"First Trade Edition", @"Book Edition 'First Trade Edition' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:4];
    lookup.name  = NSLocalizedString(@"Limited Edition", @"Book Edition 'Limited Edition' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:5];
    lookup.name  = NSLocalizedString(@"Uncorrected Proof", @"Book Edition 'Uncorrected Proof' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:6];
    lookup.name  = NSLocalizedString(@"Advance Reading Copy", @"Book Edition 'Advance Reading Copy' lookup type");
}

-(void) createFormatValues
{
    Lookup* lookup = nil;
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeFormat];
    lookup.order = [NSNumber numberWithInt:0];
    lookup.name  = NSLocalizedString(@"Hardcover", @"Book Format 'Hardcover' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeFormat];
    lookup.order = [NSNumber numberWithInt:1];
    lookup.name  = NSLocalizedString(@"Paperback", @"Book Format 'Paperback' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeFormat];
    lookup.order = [NSNumber numberWithInt:2];
    lookup.name  = NSLocalizedString(@"Mass Market Paperback", @"Book Format 'Mass Market Paperback' lookup type");
}

-(void) createConditionValues
{
    Lookup* lookup = nil;
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:0];
    lookup.name  = NSLocalizedString(@"New", @"Book Condition 'New' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:1];
    lookup.name  = NSLocalizedString(@"Very Fine", @"Book Condition 'Very Fine' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:2];
    lookup.name  = NSLocalizedString(@"Fine", @"Book Condition 'Fine' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:3];
    lookup.name  = NSLocalizedString(@"Very Good", @"Book Condition 'Very Good' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:4];
    lookup.name  = NSLocalizedString(@"Good", @"Book Condition 'Good' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:5];
    lookup.name  = NSLocalizedString(@"Poor", @"Book Condition 'Poor' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:6];
    lookup.name  = NSLocalizedString(@"Reading Copy", @"Book Condition 'Reading Copy' lookup type");
}

-(void) createCountryValues
{
    Lookup* lookup = nil;
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCountry];
    lookup.order = [NSNumber numberWithInt:0];
    lookup.name  = NSLocalizedString(@"United Kingdom", @"Country 'United Kingdom' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCountry];
    lookup.order = [NSNumber numberWithInt:1];
    lookup.name  = NSLocalizedString(@"United States", @"Country 'United States' lookup type");
}

-(void) createStateValues
{
    Lookup* lookup = nil;
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:0];
    lookup.name  = NSLocalizedString(@"Alabama", @"State 'Alabama' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:1];
    lookup.name  = NSLocalizedString(@"Alaska", @"State 'Alaska' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:2];
    lookup.name  = NSLocalizedString(@"Arizona", @"State 'Arizona' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:3];
    lookup.name  = NSLocalizedString(@"Arkansas", @"State 'Arkansas' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:4];
    lookup.name  = NSLocalizedString(@"California", @"State 'California' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:5];
    lookup.name  = NSLocalizedString(@"Colorado", @"State 'Colorado' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:6];
    lookup.name  = NSLocalizedString(@"Connecticut", @"State 'Connecticut' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:7];
    lookup.name  = NSLocalizedString(@"Delaware", @"State 'Delaware' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:8];
    lookup.name  = NSLocalizedString(@"Florida", @"State 'Florida' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:9];
    lookup.name  = NSLocalizedString(@"Georgia", @"State 'Georgia' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:10];
    lookup.name  = NSLocalizedString(@"Hawaii", @"State 'Hawaii' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:11];
    lookup.name  = NSLocalizedString(@"Idaho", @"State 'Idaho' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:12];
    lookup.name  = NSLocalizedString(@"Illinois", @"State 'Illinois' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:13];
    lookup.name  = NSLocalizedString(@"Indiana", @"State 'Indiana' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:14];
    lookup.name  = NSLocalizedString(@"Iowa", @"State 'Iowa' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:15];
    lookup.name  = NSLocalizedString(@"Kansas", @"State 'Kansas' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:16];
    lookup.name  = NSLocalizedString(@"Kentucky", @"State 'Kentucky' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:17];
    lookup.name  = NSLocalizedString(@"Louisiana", @"State 'Louisiana' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:18];
    lookup.name  = NSLocalizedString(@"Maine", @"State 'Maine' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:19];
    lookup.name  = NSLocalizedString(@"Maryland", @"State 'Maryland' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:20];
    lookup.name  = NSLocalizedString(@"Massachusetts", @"State 'Massachusetts' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:21];
    lookup.name  = NSLocalizedString(@"Michigan", @"State 'Michigan' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:22];
    lookup.name  = NSLocalizedString(@"Minnesota", @"State 'Minnesota' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:23];
    lookup.name  = NSLocalizedString(@"Mississippi", @"State 'Mississippi' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:24];
    lookup.name  = NSLocalizedString(@"Missouri", @"State 'Missouri' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:25];
    lookup.name  = NSLocalizedString(@"Montana", @"State 'Montana' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:26];
    lookup.name  = NSLocalizedString(@"Nebraska", @"State 'Nebraska' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:27];
    lookup.name  = NSLocalizedString(@"Nevada", @"State 'Nevada' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:28];
    lookup.name  = NSLocalizedString(@"New Hampshire", @"State 'New Hampshire' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:29];
    lookup.name  = NSLocalizedString(@"New Jersey", @"State 'New Jersey' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:30];
    lookup.name  = NSLocalizedString(@"New Mexico", @"State 'New Mexico' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:31];
    lookup.name  = NSLocalizedString(@"New York", @"State 'New York' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:32];
    lookup.name  = NSLocalizedString(@"North Carolina", @"State 'North Carolina' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:33];
    lookup.name  = NSLocalizedString(@"North Dakota", @"State 'North Dakota' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:34];
    lookup.name  = NSLocalizedString(@"Ohio", @"State 'Ohio' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:35];
    lookup.name  = NSLocalizedString(@"Oklahoma", @"State 'Oklahoma' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:36];
    lookup.name  = NSLocalizedString(@"Oregon", @"State 'Oregon' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:37];
    lookup.name  = NSLocalizedString(@"Pennsylvania", @"State 'Pennsylvania' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:38];
    lookup.name  = NSLocalizedString(@"Rhode Island", @"State 'Rhode Island' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:39];
    lookup.name  = NSLocalizedString(@"South Carolina", @"State 'South Carolina' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:40];
    lookup.name  = NSLocalizedString(@"South Dakota", @"State 'South Dakota' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:41];
    lookup.name  = NSLocalizedString(@"Tennessee", @"State 'Tennessee' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:42];
    lookup.name  = NSLocalizedString(@"Texas", @"State 'Texas' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:43];
    lookup.name  = NSLocalizedString(@"Utah", @"State 'Utah' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:44];
    lookup.name  = NSLocalizedString(@"Vermont", @"State 'Vermont' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:45];
    lookup.name  = NSLocalizedString(@"Virginia", @"State 'Virginia' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:46];
    lookup.name  = NSLocalizedString(@"Washington", @"State 'Washington' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:47];
    lookup.name  = NSLocalizedString(@"West Virginia", @"State 'West Virginia' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:48];
    lookup.name  = NSLocalizedString(@"Wisconsin", @"State 'Wisconsin' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:49];
    lookup.name  = NSLocalizedString(@"Wyoming", @"State 'Wyoming' lookup type");
}

-(void) createWorkerValues
{
    Lookup* lookup = nil;
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeWorker];
    lookup.order = [NSNumber numberWithInt:0];
    lookup.name  = NSLocalizedString(@"Author", @"Book Worker 'Author' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeWorker];
    lookup.order = [NSNumber numberWithInt:1];
    lookup.name  = NSLocalizedString(@"Editor", @"Book Worker 'Editor' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeWorker];
    lookup.order = [NSNumber numberWithInt:2];
    lookup.name  = NSLocalizedString(@"Illustrator", @"Book Worker 'Illustrator' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeWorker];
    lookup.order = [NSNumber numberWithInt:3];
    lookup.name  = NSLocalizedString(@"Contributor", @"Book Worker 'Contributor' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeWorker];
    lookup.order = [NSNumber numberWithInt:4];
    lookup.name  = NSLocalizedString(@"Translator", @"Book Worker 'Translator' lookup type");
}

-(void) createLocationValues
{
    Lookup* lookup = nil;
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeLocation];
    lookup.order = [NSNumber numberWithInt:0];
    lookup.name  = NSLocalizedString(@"Library Bookshelf", @"Book Location 'Library Bookshelf' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeLocation];
    lookup.order = [NSNumber numberWithInt:1];
    lookup.name  = NSLocalizedString(@"Storage Box 1", @"Book Location 'Storage Box 1' lookup type");
}

@end
