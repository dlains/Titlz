//
//  AlphaIndexFetchedResultsController.m
//  Titlz
//
//  Created by David Lains on 1/26/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "AlphaIndexFetchedResultsController.h"

@implementation AlphaIndexFetchedResultsController

-(NSString*) sectionIndexTitleForSectionName:(NSString*)sectionName
{
    return sectionName;
}

-(NSArray*) sectionIndexTitles
{
    return [NSArray arrayWithObjects:UITableViewIndexSearch, @"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
}

-(NSInteger) sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex
{
    NSArray* sectionsArray = [self sections];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", title];
    
    NSArray* filteredArray = [sectionsArray filteredArrayUsingPredicate:predicate];
    
    if ([filteredArray count] > 0)
    {
        return [sectionsArray indexOfObject:[filteredArray objectAtIndex:0]];
    }
    else
        return -1;
}

@end
