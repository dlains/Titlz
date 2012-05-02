//
//  main.m
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "AppDelegate_Pad.h"
#import "AppDelegate_Phone.h"

int main(int argc, char *argv[])
{
    @autoreleasepool
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate_Pad class]));
        }
        else
        {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate_Phone class]));
        }
    }
}
