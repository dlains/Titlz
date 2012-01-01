//
//  TitleDetailViewController.h
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Title;

// TitleDetailSections
enum TitleDetailSections
{
    NameSection = 0,
    EditionSection,
    AuthorSection,
    EditorSection,
    IllustratorSection,
    ContributorSection,
    BookSection,
    CollectionSection,
    TitleDetailSectionCount
};

@interface TitleDetailViewController : UITableViewController

@property(nonatomic, strong) NSManagedObjectContext* editingContext;
@property(nonatomic, strong) Title* detailItem;

-(id) initWithPrimaryManagedObjectContext:(NSManagedObjectContext*)primaryManagedObjectContext;

@end
