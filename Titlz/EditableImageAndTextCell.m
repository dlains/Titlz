//
//  EditableImageAndTextCell.m
//  Titlz
//
//  Created by David Lains on 1/24/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "EditableImageAndTextCell.h"

@implementation EditableImageAndTextCell

@synthesize thumbnailView = _thumbnailView;
@synthesize thumbnailButton = _thumbnailButton;
@synthesize textField = _textField;
@synthesize titleLabel = _titleLabel;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) didTransitionToState:(UITableViewCellStateMask)state
{
    [super didTransitionToState:state];
    if(state == UITableViewCellStateEditingMask)
    {
        self.thumbnailButton.enabled = YES;
        self.textField.hidden = NO;
        self.textField.enabled = YES;
        self.titleLabel.hidden = YES;
        [self.thumbnailButton setImage:[UIImage imageNamed:@"edit-image-overlay.png"] forState:UIControlStateNormal];
    }
    if(state == UITableViewCellStateDefaultMask)
    {
        self.thumbnailButton.enabled = YES;
        self.textField.hidden = YES;
        self.textField.enabled = NO;
        self.titleLabel.hidden = NO;
        [self.thumbnailButton setImage:[UIImage imageNamed:@"blank-image-overlay.png"] forState:UIControlStateNormal];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


@end
