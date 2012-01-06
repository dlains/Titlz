//
//  TitleDetailViewController.h
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonViewController.h"

@class Title;

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

@interface TitleDetailViewController : UITableViewController <PersonSelectedDelegate>

@property(nonatomic, strong) Title* detailItem;
@property(nonatomic, strong) NSUndoManager* undoManager;
@property(nonatomic, strong) NSManagedObjectContext* managedObjectContext;

-(void) setUpUndoManager;
-(void) cleanUpUndoManager;
-(void) updateRightBarButtonItemState;

@end
