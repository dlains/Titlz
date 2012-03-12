//
//  OpenLibraryBookDetails.h
//  Titlz
//
//  Created by David Lains on 2/14/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenLibraryBookDetails : NSObject

@property(nonatomic, strong) NSMutableData* rawData;
@property(nonatomic, assign) BOOL dataFound;
@property(nonatomic, assign) BOOL dataParsed;
@property(nonatomic, strong) NSString* searchTerm;
@property(nonatomic, retain) NSString* title;
@property(nonatomic, retain) NSMutableArray* authors;
@property(nonatomic, retain) NSString* isbn;
@property(nonatomic, retain) NSNumber* pages;
@property(nonatomic, retain) NSString* publisher;
@property(nonatomic, strong) NSString* mediumCover;
@property(nonatomic, strong) NSString* largeCover;

-(id) initWithData:(NSMutableData*)data andSearchTerm:(NSString*)searchTerm;

-(void) parseRawData;

@end
