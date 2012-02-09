//
//  ImageViewController.h
//  Titlz
//
//  Created by David Lains on 2/8/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Photo;

@interface ImageViewController : UIViewController

@property(nonatomic, strong) Photo* bookImage;
@property(nonatomic, strong) NSString* bookTitle;
@property(nonatomic, strong) IBOutlet UIImageView* imageView;
@property(nonatomic, assign) BOOL showNavigation;

-(IBAction) imagePressed:(id)sender;

@end
