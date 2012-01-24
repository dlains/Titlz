//
//  DAlertView.m
//  Titlz
//
//  Created by David Lains on 1/22/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "DAlertView.h"

@interface DAlertView()

@property(nonatomic, copy) NSString* cancelButtonTitle;
@property(nonatomic, copy) DAlertBlock cancelBlock;
@property(nonatomic, copy) NSString* otherButtonTitle;
@property(nonatomic, copy) DAlertBlock otherBlock;

-(id) initWithTitle:(NSString*)title message:(NSString*)message cancelTitle:(NSString*)cancelTitle cancelBlock:(DAlertBlock)cancelBlock otherTitle:(NSString*)otherTitle otherBlock:(DAlertBlock)otherBlock;

@end

@implementation DAlertView

@synthesize cancelButtonTitle = _cancelButtonTitle;
@synthesize cancelBlock = _cancelBlock;
@synthesize otherButtonTitle = _otherButtonTitle;
@synthesize otherBlock = _otherBlock;

-(id) initWithTitle:(NSString*)title message:(NSString*)message cancelTitle:(NSString*)cancelTitle cancelBlock:(DAlertBlock)cancelBlock otherTitle:(NSString*)otherTitle otherBlock:(DAlertBlock)otherBlock
{
    if (self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:otherTitle, nil])
    {
        if (cancelBlock == nil && otherBlock == nil)
        {
            self.delegate = nil;
        }
        self.cancelButtonTitle = cancelTitle;
        self.cancelBlock = cancelBlock;
        self.otherButtonTitle = otherTitle;
        self.otherBlock = otherBlock;
    }
    return self;
}

+(void) showAlertWithTitle:(NSString*)title message:(NSString*)message cancelTitle:(NSString*)cancelTitle cancelBlock:(DAlertBlock)cancelBlock otherTitle:(NSString*)otherTitle otherBlock:(DAlertBlock)otherBlock
{
    [[[self alloc] initWithTitle:title message:message cancelTitle:cancelTitle cancelBlock:cancelBlock otherTitle:otherTitle otherBlock:otherBlock] show];
}

+(void) showAlertWithTitle:(NSString*)title message:(NSString*)message buttonTitle:(NSString*)buttonTitle
{
    [[[self alloc] initWithTitle:title message:message cancelTitle:buttonTitle cancelBlock:nil otherTitle:nil otherBlock:nil] show];
}

-(void) alertView:(UIAlertView*)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString* buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:self.cancelButtonTitle])
    {
        if (self.cancelBlock)
            self.cancelBlock();
    }
    else if ([buttonTitle isEqualToString:self.otherButtonTitle])
    {
        if (self.otherBlock)
            self.otherBlock();
    }
}

@end
