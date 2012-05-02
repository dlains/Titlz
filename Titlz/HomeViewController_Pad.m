//
//  HomeViewController_Pad.m
//  Titlz
//
//  Created by David Lains on 4/24/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "HomeViewController_Pad.h"
#import "BookDetailViewController.h"

@interface HomeViewController_Pad ()
-(void) updateBookDetailView;
@end

@implementation HomeViewController_Pad

@synthesize bookDetailView = _bookDetailView;

#pragma mark - Recent Additions Page Delegate

-(void) didUpdateCurrentPageTo:(NSInteger)page
{
    self.recentAdditionsPage = page;
}

-(void) didSelectCurrentPage
{
    [self updateBookDetailView];
}

-(void) updateBookDetailView
{
    if (self.bookDetailView != nil)
    {
        self.bookDetailView.detailItem = [self.recentAdditions objectAtIndex:self.recentAdditionsPage];
        [self.bookDetailView.tableView reloadData];
    }
}


@end
