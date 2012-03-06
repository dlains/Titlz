//
//  HomeViewController.h
//  Titlz
//
//  Created by David Lains on 2/21/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecentAdditionsCell.h"

@class SearchAppViewController;

@interface HomeViewController : UITableViewController <RecentAdditionsPageDelegate>

@property(nonatomic, strong) SearchAppViewController* searchAppViewController;
@property(nonatomic, weak) NSManagedObjectContext* managedObjectContext;

@end
