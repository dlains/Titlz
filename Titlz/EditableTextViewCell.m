//
//  EditableTextViewCell.m
//  Titlz
//
//  Created by David Lains on 2/8/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "EditableTextViewCell.h"

@implementation EditableTextViewCell

@synthesize fieldLabel = _fieldLabel;
@synthesize textView = _textView;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
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
        self.textView.editable = YES;
    }
    if(state == UITableViewCellStateDefaultMask)
    {
        self.textView.editable = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
