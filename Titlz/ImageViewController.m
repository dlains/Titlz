//
//  ImageViewController.m
//  Titlz
//
//  Created by David Lains on 2/8/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "ImageViewController.h"
#import "Photo.h"
#import "Book.h"

@implementation ImageViewController

@synthesize bookImage = _bookImage;
@synthesize bookTitle = _bookTitle;
@synthesize imageView = _imageView;
@synthesize showNavigation = _showNavigation;

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.showNavigation = NO;
    }
    return self;
}

-(void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

-(void) viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewDidUnload
{
    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.imageView.image = self.bookImage.image;
    self.title = self.bookTitle;
    self.showNavigation = YES;

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Button Processing

-(IBAction) imagePressed:(id)sender
{
    self.showNavigation = !self.showNavigation;
    [self.navigationController setNavigationBarHidden:self.showNavigation animated:YES];
}

@end
