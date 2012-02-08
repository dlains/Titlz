//
//  EditableTextViewCell.h
//  Titlz
//
//  Created by David Lains on 2/8/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditableTextViewCell : UITableViewCell

@property(nonatomic, strong) IBOutlet UILabel* fieldLabel;
@property(nonatomic, strong) IBOutlet UITextView* textView;

@end
