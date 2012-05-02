//
//  HomeViewController_Pad.h
//  Titlz
//
//  Created by David Lains on 4/24/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "HomeViewController.h"
#import "RecentAdditionsCell.h"

@class BookDetailViewController;

@interface HomeViewController_Pad : HomeViewController <RecentAdditionsPageDelegate>

@property(nonatomic, strong) BookDetailViewController* bookDetailView;

@end
