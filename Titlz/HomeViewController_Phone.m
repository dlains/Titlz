//
//  HomeViewController_Phone.m
//  Titlz
//
//  Created by David Lains on 4/24/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "HomeViewController_Phone.h"
#import "BookDetailViewController.h"

@interface HomeViewController_Phone ()
-(void) loadBookDetailView;
@end

@implementation HomeViewController_Phone

#pragma mark - Recent Additions Page Delegate

-(void) didUpdateCurrentPageTo:(NSInteger)page
{
    self.recentAdditionsPage = page;
}

-(void) didSelectCurrentPage
{
    [self loadBookDetailView];
}

-(void) loadBookDetailView
{
    BookDetailViewController* bookDetailView = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
    bookDetailView.detailItem = [self.recentAdditions objectAtIndex:self.recentAdditionsPage];
    [self.navigationController pushViewController:bookDetailView animated:YES];
}


@end
