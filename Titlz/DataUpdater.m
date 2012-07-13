//
//  DataUpdater.m
//  Titlz
//
//  Created by David Lains on 7/12/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "DataUpdater.h"
#import "Book.h"

@implementation DataUpdater

-(void) fixSortableTitlesInContext:(NSManagedObjectContext*)context
{
    NSLog(@"Updating the sortable titles for existing records.");

    // Get all the books.
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSError* error = nil;
    NSArray* books = [context executeFetchRequest:request error:&error];

    // Reset all of the sortableTitle fields.
    if (books != nil)
    {
        for (Book* book in books)
        {
            book.sortableTitle = book.title;
        }
    }
    
    // Save the context.
    [ContextUtil saveContext:context];
}

@end
