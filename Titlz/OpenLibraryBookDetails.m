//
//  OpenLibraryBookDetails.m
//  Titlz
//
//  Created by David Lains on 2/14/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "OpenLibraryBookDetails.h"

@interface OpenLibraryBookDetails()
-(void) buildCoverURLS:(NSDictionary*)cover;
@end

@implementation OpenLibraryBookDetails

@synthesize rawData = _rawData;
@synthesize dataFound = _dataFound;
@synthesize dataParsed = _dataParsed;
@synthesize searchTerm = _searchTerm;
@synthesize title = _title;
@synthesize authors = _authors;
@synthesize isbn = _isbn;
@synthesize pages = _pages;
@synthesize publisher = _publisher;
@synthesize mediumCover = _mediumCover;
@synthesize largeCover = _largeCover;

-(id) initWithData:(NSMutableData*)data andSearchTerm:(NSString *)searchTerm
{
    self = [super init];
    if (self)
    {
        self.rawData = data;
        self.dataFound = NO;
        self.dataParsed = NO;
        self.searchTerm = searchTerm;
        if (self.rawData != nil)
        {
            [self parseRawData];
        }
    }
    
    return self;
}

-(void) parseRawData
{
    NSError* error = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:self.rawData options:NSJSONReadingAllowFragments error:&error];
    
    if (jsonObject != nil && error == nil)
    {
        if ([jsonObject isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* deserializedDictionary = (NSDictionary*)jsonObject;
            NSDictionary* data = [deserializedDictionary objectForKey:[NSString stringWithFormat:@"%@:%@", @"ISBN", self.searchTerm]];

            if (data != nil)
            {
                self.dataFound = YES;
                
                // Capitalize the title because Open Library only capitalizes the first word.
                NSString* titleValue = (NSString*)[data objectForKey:@"title"];
                self.title = [titleValue capitalizedString];
                
                // Separate the author names into a simple array.
                NSArray* authors = [data objectForKey:@"authors"];
                self.authors = [[NSMutableArray alloc] initWithCapacity:authors.count];
                for (NSDictionary* author in authors)
                {
                    [self.authors addObject:[author objectForKey:@"name"]];
                }
                
                // Assuming the first publisher in the array is the publisher of the first edition.
                // This sucks, but I see no other way of determining which publisher is which.
                NSArray* publishers = [data objectForKey:@"publishers"];
                if (publishers != nil)
                {
                    NSDictionary* firstPublisher = [publishers objectAtIndex:0];
                    self.publisher = [firstPublisher objectForKey:@"name"];
                }
                
                // Use the ISBN provided by the user.
                self.isbn = self.searchTerm;
                
                // The Identifiers dictionary contains the ISBN. Check for ISBN-13 first. If it isn't found
                // Check for ISBN-10.
//                NSDictionary* identifiers = [data objectForKey:@"identifiers"];
//                NSArray* isbnValue = [identifiers objectForKey:@"isbn_13"];
//                if (isbnValue == nil)
//                {
//                    isbnValue = [identifiers objectForKey:@"isbn_10"];
//                }
//                self.isbn = [isbnValue objectAtIndex:0];
                
                // Number of pages is thankfully straightforward.
                self.pages = [data objectForKey:@"number_of_pages"];
                
                // Check for a cover entry and get the resulting small and large cover data.
                [self buildCoverURLS:[data objectForKey:@"cover"]];
                
                self.dataParsed = YES;
            }
        }
    }
    else if (error != nil)
    {
        DLog(@"Error deserializing the JSON data: %@.", error);
        self.dataParsed = NO;
    }
}

-(void) buildCoverURLS:(NSDictionary *)cover
{
    NSString* medium = nil;
    NSString* large = nil;
    
    if (cover != nil)
    {
        medium = [cover objectForKey:@"medium"];
        large = [cover objectForKey:@"large"];
    }
    
    // If the small and large strings are still nil create valid OpenLibrary Cover API strings.
    if (medium == nil)
    {
        medium = [NSString stringWithFormat:@"http://covers.openlibrary.org/b/%@/%@-M.jpg?default=false", @"isbn", self.searchTerm];
    }
    if (large == nil)
    {
        large = [NSString stringWithFormat:@"http://covers.openlibrary.org/b/%@/%@-L.jpg?default=false", @"isbn", self.searchTerm];
    }
    
    self.mediumCover = medium;
    self.largeCover = large;
}

@end
