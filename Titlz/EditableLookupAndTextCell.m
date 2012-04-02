//
//  EditableLookupAndTextCell.m
//  Titlz
//
//  Created by David Lains on 2/2/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "EditableLookupAndTextCell.h"

@implementation EditableLookupAndTextCell

@synthesize fieldLabel = _fieldLabel;
@synthesize lookupButton = _lookupButton;
@synthesize textField = _textField;
@synthesize objectId = _objectId;

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
        self.lookupButton.enabled = YES;
        self.textField.enabled = YES;
        UIImage* image = [UIImage imageNamed:@"worker-button-border.png"];
        [self.lookupButton setBackgroundImage:image forState:UIControlStateNormal];
    }
    if(state == UITableViewCellStateDefaultMask)
    {
        self.lookupButton.enabled = NO;
        self.textField.enabled = NO;
        [self.lookupButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
}

-(void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
