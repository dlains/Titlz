//
//  PersonDetailViewController.h
//  Titlz
//
//  Created by David Lains on 1/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Person;

enum PersonDetailSections
{
    DataSection = 0,
    AliasSection,
    AuthoredSection,
    EditedSection,
    IllustratedSection,
    ContributedToSection,
    PersonDetailSectionCount
};

enum PersonDataSectionRows
{
    FirstNameRow = 0,
    MiddleNameRow,
    LastNameRow,
    BornRow,
    DiedRow,
    PersonDataSectionRowCount
};

@interface PersonDetailViewController : UITableViewController

@property(nonatomic, strong) NSManagedObjectContext* editingContext;
@property(nonatomic, strong) Person* detailItem;
@property(nonatomic, assign) BOOL editMode;
@property(nonatomic, assign) BOOL newRecord;

-(id) initWithPrimaryManagedObjectContext:(NSManagedObjectContext*)primaryManagedObjectContext;

@end
