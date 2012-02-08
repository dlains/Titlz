//
//  EditableImageAndTextCell.h
//  Titlz
//
//  Created by David Lains on 1/24/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditableImageAndTextCell : UITableViewCell

@property(nonatomic, strong) IBOutlet UIImageView* thumbnailView;
@property(nonatomic, strong) IBOutlet UIButton* thumbnailButton;
@property(nonatomic, strong) IBOutlet UITextField* textField;
@property(nonatomic, strong) IBOutlet UILabel* titleLabel;

@end
