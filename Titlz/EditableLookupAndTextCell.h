//
//  EditableLookupAndTextCell.h
//  Titlz
//
//  Created by David Lains on 2/2/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditableLookupAndTextCell : UITableViewCell

@property(nonatomic, strong) IBOutlet UILabel* fieldLabel;
@property(nonatomic, strong) IBOutlet UIButton* lookupButton;
@property(nonatomic, strong) IBOutlet UITextField* textField;
@property(nonatomic, strong) NSManagedObjectID* objectId;

@end
