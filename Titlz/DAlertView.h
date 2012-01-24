//
//  DAlertView.h
//  Titlz
//
//  Created by David Lains on 1/22/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DAlertBlock)(void);

@interface DAlertView : UIAlertView

+(void) showAlertWithTitle:(NSString*)title message:(NSString*)message cancelTitle:(NSString*)cancelTitle cancelBlock:(DAlertBlock)cancelBlock otherTitle:(NSString*)otherTitle otherBlock:(DAlertBlock)otherBlock;

+(void) showAlertWithTitle:(NSString*)title message:(NSString*)message buttonTitle:(NSString*)buttonTitle;

@end
