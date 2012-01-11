//
//  PersonDetailViewController.h
//  Titlz
//
//  Created by David Lains on 1/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleViewController.h"

@class Person;

enum PersonDetailSections
{
    DataSection = 0,
    AliasSection,
    AliasOfSection,
    AuthoredSection,
    EditedSection,
    IllustratedSection,
    ContributedSection,
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

@interface PersonDetailViewController : UITableViewController <TitleSelectedDelegate, PersonSelectedDelegate>
{
    UITextField* bornTextField;
    UITextField* diedTextField;
}

@property(nonatomic, strong) Person* detailItem;
@property(nonatomic, assign) NSInteger personTypeBeingAdded;
@property(nonatomic, strong) NSUndoManager* undoManager;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(void) updateRightBarButtonItemState;

@end
