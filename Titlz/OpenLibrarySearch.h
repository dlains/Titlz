//
//  OpenLibrarySearch.h
//  Titlz
//
//  Created by David Lains on 2/16/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OpenLibrarySearchDelegate;

@class OpenLibraryBookDetails;

@interface OpenLibrarySearch : NSObject

@property(nonatomic, strong) NSString* searchTerm;
@property(nonatomic, assign) id<OpenLibrarySearchDelegate> delegate;
@property(nonatomic, strong) OpenLibraryBookDetails* bookDetails;
@property(nonatomic, strong) DConnection* connection;

-(id) initWithSearchTerm:(NSString*)searchTerm andDelegate:(id<OpenLibrarySearchDelegate>)delegate;

-(void) startSearch;
-(void) stopSearch;

@end

@protocol OpenLibrarySearchDelegate <NSObject>

-(void) openLibrarySearchDidFinishWithBookDetails:(OpenLibraryBookDetails*)bookDetails;
-(void) openLibraryConnectionFailed;

@end