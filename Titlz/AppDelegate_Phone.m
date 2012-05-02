//
//  AppDelegate_Phone.m
//  Titlz
//
//  Created by David Lains on 5/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "AppDelegate_Phone.h"
#import "HomeViewController_Phone.h"
#import "BookViewController.h"
#import "BookDetailViewController.h"
#import "CollectionDetailViewController.h"
#import "PublisherViewController.h"
#import "SellerViewController.h"
#import "InitialData.h"

@implementation AppDelegate_Phone

-(BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];

    self.tabBarController = [[UITabBarController alloc] init];
    
    HomeViewController_Phone* homeViewController = [[HomeViewController_Phone alloc] initWithStyle:UITableViewStylePlain];
    homeViewController.managedObjectContext = self.managedObjectContext;
    UINavigationController* homeNavigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    homeNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    BookViewController* bookViewController = [[BookViewController alloc] initWithManagedObjectContext:self.managedObjectContext];
    UINavigationController* bookNavigationController = [[UINavigationController alloc] initWithRootViewController:bookViewController];
    bookNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    bookViewController.selectionMode = DetailSelection;
    
    CollectionViewController* collectionViewController = [[CollectionViewController alloc] initWithNibName:@"CollectionViewController" bundle:nil];
    UINavigationController* collectionNavigationController = [[UINavigationController alloc] initWithRootViewController:collectionViewController];
    collectionNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    collectionViewController.managedObjectContext = self.managedObjectContext;
    
    PersonViewController* personViewController = [[PersonViewController alloc] initWithNibName:@"PersonViewController" bundle:nil];
    UINavigationController* personNavigationController = [[UINavigationController alloc] initWithRootViewController:personViewController];
    personNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    personViewController.managedObjectContext = self.managedObjectContext;
    
    PublisherViewController* publisherViewController = [[PublisherViewController alloc] initWithNibName:@"PublisherViewController" bundle:nil];
    UINavigationController* publisherNavigationController = [[UINavigationController alloc] initWithRootViewController:publisherViewController];
    publisherNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    publisherViewController.managedObjectContext = self.managedObjectContext;
    
    SellerViewController* sellerViewController = [[SellerViewController alloc] initWithNibName:@"SellerViewController" bundle:nil];
    UINavigationController* sellerNavigationController = [[UINavigationController alloc] initWithRootViewController:sellerViewController];
    sellerNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    sellerViewController.managedObjectContext = self.managedObjectContext;
    
    self.tabBarController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:homeNavigationController, bookNavigationController, collectionNavigationController, personNavigationController, publisherNavigationController, sellerNavigationController, nil];
    self.tabBarController.customizableViewControllers = nil;
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];

    // Initialize application on first launch.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"])
    {
        // Set the current collection default.
        [[NSUserDefaults standardUserDefaults] setValue:@"Entire Library" forKey:@"currentCollection"];
        
        // Create the initial database records.
        InitialData* initialData = [[InitialData alloc] init];
        [initialData createInManagedObjectContext:self.managedObjectContext];
    }
    
    return YES;
}

@end
