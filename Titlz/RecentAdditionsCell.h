//
//  RecentAdditionsCell.h
//  Titlz
//
//  Created by David Lains on 2/23/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentAdditionsCell : UITableViewCell <UIScrollViewDelegate>

@property(nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property(nonatomic, strong) IBOutlet UIPageControl* pageControl;
@property(nonatomic, strong) IBOutlet UIImageView* thumbnailView;
@property(nonatomic, strong) IBOutlet UILabel* titleLabel;
@property(nonatomic, strong) IBOutlet UILabel* authorLabel;
@property(nonatomic, strong) IBOutlet UILabel* detailsLabel;

@property(nonatomic, strong) NSArray* recentAdditions;

-(IBAction) userDidPage:(id)sender;

@end
