//
//  EditableTextCell.m
//  Titlz
//
//  Created by David Lains on 12/30/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import "EditableTextCell.h"

@implementation EditableTextCell

@synthesize textField = _textField;
@synthesize fieldLabel = _fieldLabel;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

-(void) didTransitionToState:(UITableViewCellStateMask)state
{
    [super didTransitionToState:state];
    if(state == UITableViewCellStateEditingMask)
    {
        self.textField.enabled = YES;
    }
    if(state == UITableViewCellStateDefaultMask)
    {
        self.textField.enabled = NO;
    }
}

-(void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
