//
//  OpenLibrarySearch.m
//  Titlz
//
//  Created by David Lains on 2/16/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "OpenLibrarySearch.h"
#import "OpenLibraryBookDetails.h"

@implementation OpenLibrarySearch

@synthesize searchType = _searchType;
@synthesize searchTerm = _searchTerm;
@synthesize delegate = _delegate;
@synthesize bookDetails = _bookDetails;
@synthesize connection = _connection;

-(id) initWithSearchType:(OpenLibrarySearchType)type searchTerm:(NSString *)searchTerm andDelegate:(id<OpenLibrarySearchDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.searchType = type;
        self.searchTerm = [searchTerm uppercaseString];
        self.delegate = delegate;
    }
    
    return self;
}

-(void) startSearch
{
    // Clear out old details.
    if (self.bookDetails != nil)
        self.bookDetails = nil;

    NSString* searchType = nil;
    
    switch (self.searchType)
    {
        case SearchTypeISBN:
            searchType = NSLocalizedString(@"ISBN", @"Open Library lookup view controller ISBN search type.");
            break;
        case SearchTypeLCCN:
            searchType = NSLocalizedString(@"LCCN", @"Open Library lookup view controller LCCN search type.");
            break;
        case SearchTypeOCLC:
            searchType = NSLocalizedString(@"OCLC", @"Open Library lookup view controller OCLC search type.");
            break;
        default:
            break;
    }
    
    NSString* key = [NSString stringWithFormat:@"%@:%@", searchType, self.searchTerm];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://openlibrary.org/api/books?bibkeys=%@&format=json&jscmd=data", key]];
    
    DConnectionCompletionBlock completion = ^(DConnection* connection, NSError* error)
    {
        if (error)
        {
            [self.delegate openLibraryConnectionFailed];
        }
        else
        {
            self.bookDetails = [[OpenLibraryBookDetails alloc] initWithData:connection.downloadData andSearchKey:searchType andSearchTerm:self.searchTerm];
            [self.delegate openLibrarySearchDidFinishWithBookDetails:self.bookDetails];
        }
    };

    self.connection = [DConnection connectionWithURL:url progressBlock:nil completionBlock:completion];
    [self.connection start];
}

-(void) stopSearch
{
    [self.connection stop];
}

@end
