//
//  TitleDetailViewController.h
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleDetailViewController : UIViewController

@property(nonatomic, strong) id detailItem;

@property(nonatomic, strong) IBOutlet UILabel* detailDescriptionLabel;

@end
