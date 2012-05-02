//
//  AppDelegate_Pad.m
//  Titlz
//
//  Created by David Lains on 5/1/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "AppDelegate_Pad.h"
#import "HomeViewController_Pad.h"
#import "BookViewController.h"
#import "BookDetailViewController.h"
#import "CollectionDetailViewController.h"
#import "PublisherViewController.h"
#import "SellerViewController.h"
#import "InitialData.h"

@implementation AppDelegate_Pad

@synthesize splitView = _splitView;

-(BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    self.splitView = [[UISplitViewController alloc] init];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.delegate = self;
    
    BookDetailViewController* bookDetailViewController = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
    UINavigationController* detailNavigationController = [[UINavigationController alloc] initWithRootViewController:bookDetailViewController];
    detailNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    HomeViewController_Pad* homeViewController = [[HomeViewController_Pad alloc] initWithStyle:UITableViewStylePlain];
    homeViewController.managedObjectContext = self.managedObjectContext;
    homeViewController.bookDetailView = bookDetailViewController;
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
    
    self.splitView.viewControllers = [NSArray arrayWithObjects:self.tabBarController, detailNavigationController, nil];
    
    self.window.rootViewController = self.splitView;
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

#pragma mark - UITabBarController Delegate

-(void) tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        switch (tabBarController.selectedIndex)
        {
            case HomeTab:
            {
                // Setup the BookDetailViewController.
                BookDetailViewController* bookDetailViewController = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
                UINavigationController* detailNavigationController = [[UINavigationController alloc] initWithRootViewController:bookDetailViewController];
                detailNavigationController.navigationBar.barStyle = UIBarStyleBlack;
                UINavigationController* nav = (UINavigationController*)self.tabBarController.selectedViewController;
                HomeViewController_Pad* view = (HomeViewController_Pad*)nav.topViewController;
                view.bookDetailView = bookDetailViewController;
                self.splitView.viewControllers = [NSArray arrayWithObjects:self.tabBarController, detailNavigationController, nil];
                break;
            }
            case BookTab:
            {
                // Setup the BookDetailViewController.
                BookDetailViewController* bookDetailViewController = [[BookDetailViewController alloc] initWithNibName:@"BookDetailViewController" bundle:nil];
                UINavigationController* detailNavigationController = [[UINavigationController alloc] initWithRootViewController:bookDetailViewController];
                detailNavigationController.navigationBar.barStyle = UIBarStyleBlack;
                //BookViewController* view = (BookViewController*)self.tabBarController.selectedViewController;
                //view.bookDetailView = bookDetailViewController;
                self.splitView.viewControllers = [NSArray arrayWithObjects:self.tabBarController, detailNavigationController, nil];
                break;
            }
            case CollectionTab:
            {
                // Setup the CollectionDetailViewController.
                CollectionDetailViewController* collectionDetailViewController = [[CollectionDetailViewController alloc] initWithNibName:@"CollectionDetailViewController" bundle:nil];
                UINavigationController* detailNavigationController = [[UINavigationController alloc] initWithRootViewController:collectionDetailViewController];
                detailNavigationController.navigationBar.barStyle = UIBarStyleBlack;
                self.splitView.viewControllers = [NSArray arrayWithObjects:self.tabBarController, detailNavigationController, nil];
                break;
            }
            case PersonTab:
                // Setup the PersonDetailViewController.
                break;
            case PublisherTab:
                // Setup the PublisherDetailViewController.
                break;
            case SellerTab:
                // Setup the SellerDetailViewController.
                break;
            default:
                DLog(@"Invalid selectedIndex sent to AppDelegate::didSelectViewController: %i.", tabBarController.selectedIndex);
                break;
        }
    }
}

@end
