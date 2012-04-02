//
//  CollectionDetailViewController.h
//  Titlz
//
//  Created by David Lains on 1/30/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewController.h"

@class Collection;

@interface CollectionDetailViewController : UITableViewController <BookSelectedDelegate>

@property(nonatomic, strong) Collection* detailItem;
@property(nonatomic, assign) BOOL allowDrilldown;

@end
