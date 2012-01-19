//
//  SellerViewController.h
//  Titlz
//
//  Created by David Lains on 1/18/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "NewSellerViewController.h"

@protocol SellerSelectedDelegate;

@class Seller;

@interface SellerViewController : UITableViewController <NSFetchedResultsControllerDelegate, NewSellerDelegate>

@property(nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property(nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property(nonatomic, assign) id <SellerSelectedDelegate> delegate;
@property(nonatomic, assign) BOOL selectionMode;

@end

@protocol SellerSelectedDelegate <NSObject>

-(void) sellerViewController:(SellerViewController*)controller didSelectSeller:(Seller*)seller;

@end
