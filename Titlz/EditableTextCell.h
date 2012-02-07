//
//  EditableTextCell.h
//  Titlz
//
//  Created by David Lains on 12/30/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditableTextCell : UITableViewCell

@property(nonatomic, strong) IBOutlet UILabel* fieldLabel;
@property(nonatomic, strong) IBOutlet UITextField* textField;
@property(nonatomic, strong) NSManagedObjectID* objectId;

@end
