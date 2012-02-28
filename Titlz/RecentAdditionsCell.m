//
//  RecentAdditionsCell.m
//  Titlz
//
//  Created by David Lains on 2/23/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RecentAdditionsCell.h"
#import "Book.h"
#import "Worker.h"
#import "Person.h"

@implementation RecentAdditionsCell

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize thumbnailView = _thumbnailView;
@synthesize titleLabel = _titleLabel;
@synthesize authorLabel = _authorLabel;
@synthesize detailsLabel = _detailsLabel;

@synthesize recentAdditions = _recentAdditions;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self.contentView setBackgroundColor:[UIColor blackColor]];
        [self.thumbnailView.layer setMasksToBounds:YES];
        [self.thumbnailView.layer setCornerRadius:3.0f];
        [self.thumbnailView.layer setBorderWidth:1.0f];
        [self.thumbnailView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    }
    return self;
}

-(void) awakeFromNib
{
    [self.contentView setBackgroundColor:[UIColor blackColor]];
    [self.thumbnailView.layer setMasksToBounds:YES];
    [self.thumbnailView.layer setCornerRadius:3.0f];
    [self.thumbnailView.layer setBorderWidth:1.0f];
    [self.thumbnailView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
}

-(void) setRecentAdditions:(NSArray *)recentAdditions
{
    _recentAdditions = recentAdditions;
    
    self.pageControl.numberOfPages = _recentAdditions.count;
    
    NSInteger pageNumber = 0;
    for (Book* book in _recentAdditions)
    {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"BookPageView" owner:self options:nil];
        UIView* v = [nib objectAtIndex:0];

        if (book.thumbnail == nil)
            self.thumbnailView.image = [UIImage imageNamed:@"BookCover-leather-large.jpg"];
        else
            self.thumbnailView.image = book.thumbnail;

        self.titleLabel.text = book.title;
        Worker* worker = [book.workers anyObject];
        if (worker != nil)
        {
            self.authorLabel.text = worker.person.fullName;
        }
        self.detailsLabel.text = [NSString stringWithFormat:@"%@ - %@", book.edition, book.format];
        
        [v setFrame:CGRectMake(self.scrollView.bounds.size.width * pageNumber, self.scrollView.bounds.origin.y, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * (pageNumber + 1), self.scrollView.bounds.size.height)];
        [self.scrollView addSubview:v];
        pageNumber++;
    }
}

-(void) scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    CGFloat x = self.scrollView.contentOffset.x;
    CGFloat w = self.scrollView.bounds.size.width;
    self.pageControl.currentPage = x/w;
}

-(IBAction) userDidPage:(id)sender
{
    NSInteger p = self.pageControl.currentPage;
    CGFloat w = self.scrollView.bounds.size.width;
    [self.scrollView setContentOffset:CGPointMake(p*w, 0) animated:YES];
}

-(void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end