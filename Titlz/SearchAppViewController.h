//
//  SearchAppViewController.h
//  Titlz
//
//  Created by David Lains on 2/21/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchAppViewController : UITableViewController <UISearchBarDelegate>

@property(nonatomic, strong) UISearchBar* searchBar;
@property(nonatomic, strong) NSMutableArray* foundBooks;
@property(nonatomic, strong) NSMutableArray* foundPeople;
@property(nonatomic, strong) NSMutableArray* foundCollections;
@property(nonatomic, strong) NSMutableArray* tableData;
@property(nonatomic, strong) NSMutableArray* sectionTitles;

@property(nonatomic, weak) NSManagedObjectContext* managedObjectContext;

@end
