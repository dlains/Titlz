//
//  AppDelegate.m
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import "AppDelegate.h"

#import "BookViewController.h"
#import "HomeViewController.h"
#import "PublisherViewController.h"
#import "SellerViewController.h"
#import "InitialData.h"

void uncaughtExceptionHandler(NSException* exception);

@interface AppDelegate()
-(BOOL) addSkipBackupAttributeToItemAtURL:(NSURL*)URL;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

void uncaughtExceptionHandler(NSException* exception)
{
    DLog(@"CRASH: %@", exception);
    DLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

-(BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    // Get a better view of crash data.
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    // Register the firstLaunch user default so we can detect when to load the lookup table.
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"firstLaunch",nil]];
    
    application.applicationSupportsShakeToEdit = YES;
    application.statusBarStyle = UIStatusBarStyleBlackOpaque;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.tabBarController = [[UITabBarController alloc] init];

    HomeViewController* homeViewController = [[HomeViewController alloc] initWithStyle:UITableViewStylePlain];
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

-(void) applicationWillResignActive:(UIApplication*)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

-(void) applicationDidBecomeActive:(UIApplication*)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

-(void) applicationWillTerminate:(UIApplication*)application
{
    // Stop responding to notifications.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

-(void) saveContext
{
    [ContextUtil saveContext:self.managedObjectContext];
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
-(NSManagedObjectContext*) managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
-(NSManagedObjectModel*) managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:@"Titlz" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
-(NSPersistentStoreCoordinator*) persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL* storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Titlz.sqlite"];
    
    NSError* error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    

    [self addSkipBackupAttributeToItemAtURL:storeURL];
    return __persistentStoreCoordinator;
}

// TODO: Had to add this to pass review. Switch to iCloud backup as soon as you can.
-(BOOL) addSkipBackupAttributeToItemAtURL:(NSURL*)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success)
    {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
-(NSURL*) applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
