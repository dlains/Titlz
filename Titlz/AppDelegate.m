//
//  AppDelegate.m
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import "AppDelegate.h"

#import "BookViewController.h"
#import "Lookup.h"

void uncaughtExceptionHandler(NSException* exception);

@interface AppDelegate()
-(void) loadLookupData;
-(void) createEditionValues;
-(void) createFormatValues;
-(void) createConditionValues;
-(void) createCountryValues;
-(void) createStateValues;
-(void) createWorkerValues;
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

    BookViewController* bookViewController = [[BookViewController alloc] initWithNibName:@"BookViewController" bundle:nil];
    UINavigationController* bookNavigationController = [[UINavigationController alloc] initWithRootViewController:bookViewController];
    bookNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    bookViewController.managedObjectContext = self.managedObjectContext;
    bookViewController.selectionMode = DetailSelection;
    
    CollectionViewController* collectionViewController = [[CollectionViewController alloc] initWithNibName:@"CollectionViewController" bundle:nil];
    UINavigationController* collectionNavigationController = [[UINavigationController alloc] initWithRootViewController:collectionViewController];
    collectionNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    collectionViewController.managedObjectContext = self.managedObjectContext;
    
    PersonViewController* personViewController = [[PersonViewController alloc] initWithNibName:@"PersonViewController" bundle:nil];
    UINavigationController* personNavigationController = [[UINavigationController alloc] initWithRootViewController:personViewController];
    personNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    personViewController.managedObjectContext = self.managedObjectContext;
    
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:bookNavigationController, collectionNavigationController, personNavigationController, nil];

    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"])
    {
        [self loadLookupData];
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
    // Initial data has been created at this point, so firstLaunch can be set to NO.
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    
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
    
    return __persistentStoreCoordinator;
}

#pragma mark - Initial Lookup Data

-(void) loadLookupData
{
    DLog(@"Populating lookup table on first application run.");
    
    [self createEditionValues];
    [self createFormatValues];
    [self createConditionValues];
    [self createCountryValues];
    [self createStateValues];
    [self createWorkerValues];
    
    [ContextUtil saveContext:self.managedObjectContext];
}

-(void) createEditionValues
{
    Lookup* lookup = nil;
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:0];
    lookup.name  = NSLocalizedString(@"First Edition", @"Book Edition 'First Edition' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:1];
    lookup.name  = NSLocalizedString(@"First U.K. Edition", @"Book Edition 'First U.K. Edition' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:2];
    lookup.name  = NSLocalizedString(@"First U.S. Edition", @"Book Edition 'First U.S. Edition' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:3];
    lookup.name  = NSLocalizedString(@"First Trade Edition", @"Book Edition 'First Trade Edition' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:4];
    lookup.name  = NSLocalizedString(@"Limited Edition", @"Book Edition 'Limited Edition' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:5];
    lookup.name  = NSLocalizedString(@"Uncorrected Proof", @"Book Edition 'Uncorrected Proof' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeEdition];
    lookup.order = [NSNumber numberWithInt:6];
    lookup.name  = NSLocalizedString(@"Advance Reading Copy", @"Book Edition 'Advance Reading Copy' lookup type");
}

-(void) createFormatValues
{
    Lookup* lookup = nil;
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeFormat];
    lookup.order = [NSNumber numberWithInt:0];
    lookup.name  = NSLocalizedString(@"Hardcover", @"Book Format 'Hardcover' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeFormat];
    lookup.order = [NSNumber numberWithInt:1];
    lookup.name  = NSLocalizedString(@"Paperback", @"Book Format 'Paperback' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeFormat];
    lookup.order = [NSNumber numberWithInt:2];
    lookup.name  = NSLocalizedString(@"Mass Market Paperback", @"Book Format 'Mass Market Paperback' lookup type");
}

-(void) createConditionValues
{
    Lookup* lookup = nil;
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:0];
    lookup.name  = NSLocalizedString(@"New", @"Book Condition 'New' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:1];
    lookup.name  = NSLocalizedString(@"Very Fine", @"Book Condition 'Very Fine' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:2];
    lookup.name  = NSLocalizedString(@"Fine", @"Book Condition 'Fine' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:3];
    lookup.name  = NSLocalizedString(@"Very Good", @"Book Condition 'Very Good' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:4];
    lookup.name  = NSLocalizedString(@"Good", @"Book Condition 'Good' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:5];
    lookup.name  = NSLocalizedString(@"Poor", @"Book Condition 'Poor' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCondition];
    lookup.order = [NSNumber numberWithInt:6];
    lookup.name  = NSLocalizedString(@"Reading Copy", @"Book Condition 'Reading Copy' lookup type");
}

-(void) createCountryValues
{
    Lookup* lookup = nil;
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCountry];
    lookup.order = [NSNumber numberWithInt:0];
    lookup.name  = NSLocalizedString(@"United Kingdom", @"Country 'United Kingdom' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeCountry];
    lookup.order = [NSNumber numberWithInt:1];
    lookup.name  = NSLocalizedString(@"United States", @"Country 'United States' lookup type");
}

-(void) createStateValues
{
    Lookup* lookup = nil;
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:0];
    lookup.name  = NSLocalizedString(@"Alabama", @"State 'Alabama' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:1];
    lookup.name  = NSLocalizedString(@"Alaska", @"State 'Alaska' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:2];
    lookup.name  = NSLocalizedString(@"Arizona", @"State 'Arizona' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:3];
    lookup.name  = NSLocalizedString(@"Arkansas", @"State 'Arkansas' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:4];
    lookup.name  = NSLocalizedString(@"California", @"State 'California' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:5];
    lookup.name  = NSLocalizedString(@"Colorado", @"State 'Colorado' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:6];
    lookup.name  = NSLocalizedString(@"Connecticut", @"State 'Connecticut' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:7];
    lookup.name  = NSLocalizedString(@"Delaware", @"State 'Delaware' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:8];
    lookup.name  = NSLocalizedString(@"Florida", @"State 'Florida' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:9];
    lookup.name  = NSLocalizedString(@"Georgia", @"State 'Georgia' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:10];
    lookup.name  = NSLocalizedString(@"Hawaii", @"State 'Hawaii' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:11];
    lookup.name  = NSLocalizedString(@"Idaho", @"State 'Idaho' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:12];
    lookup.name  = NSLocalizedString(@"Illinois", @"State 'Illinois' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:13];
    lookup.name  = NSLocalizedString(@"Indiana", @"State 'Indiana' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:14];
    lookup.name  = NSLocalizedString(@"Iowa", @"State 'Iowa' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:15];
    lookup.name  = NSLocalizedString(@"Kansas", @"State 'Kansas' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:16];
    lookup.name  = NSLocalizedString(@"Kentucky", @"State 'Kentucky' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:17];
    lookup.name  = NSLocalizedString(@"Louisiana", @"State 'Louisiana' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:18];
    lookup.name  = NSLocalizedString(@"Maine", @"State 'Maine' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:19];
    lookup.name  = NSLocalizedString(@"Maryland", @"State 'Maryland' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:20];
    lookup.name  = NSLocalizedString(@"Massachusetts", @"State 'Massachusetts' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:21];
    lookup.name  = NSLocalizedString(@"Michigan", @"State 'Michigan' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:22];
    lookup.name  = NSLocalizedString(@"Minnesota", @"State 'Minnesota' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:23];
    lookup.name  = NSLocalizedString(@"Mississippi", @"State 'Mississippi' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:24];
    lookup.name  = NSLocalizedString(@"Missouri", @"State 'Missouri' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:25];
    lookup.name  = NSLocalizedString(@"Montana", @"State 'Montana' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:26];
    lookup.name  = NSLocalizedString(@"Nebraska", @"State 'Nebraska' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:27];
    lookup.name  = NSLocalizedString(@"Nevada", @"State 'Nevada' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:28];
    lookup.name  = NSLocalizedString(@"New Hampshire", @"State 'New Hampshire' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:29];
    lookup.name  = NSLocalizedString(@"New Jersey", @"State 'New Jersey' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:30];
    lookup.name  = NSLocalizedString(@"New Mexico", @"State 'New Mexico' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:31];
    lookup.name  = NSLocalizedString(@"New York", @"State 'New York' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:32];
    lookup.name  = NSLocalizedString(@"North Carolina", @"State 'North Carolina' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:33];
    lookup.name  = NSLocalizedString(@"North Dakota", @"State 'North Dakota' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:34];
    lookup.name  = NSLocalizedString(@"Ohio", @"State 'Ohio' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:35];
    lookup.name  = NSLocalizedString(@"Oklahoma", @"State 'Oklahoma' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:36];
    lookup.name  = NSLocalizedString(@"Oregon", @"State 'Oregon' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:37];
    lookup.name  = NSLocalizedString(@"Pennsylvania", @"State 'Pennsylvania' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:38];
    lookup.name  = NSLocalizedString(@"Rhode Island", @"State 'Rhode Island' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:39];
    lookup.name  = NSLocalizedString(@"South Carolina", @"State 'South Carolina' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:40];
    lookup.name  = NSLocalizedString(@"South Dakota", @"State 'South Dakota' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:41];
    lookup.name  = NSLocalizedString(@"Tennessee", @"State 'Tennessee' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:42];
    lookup.name  = NSLocalizedString(@"Texas", @"State 'Texas' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:43];
    lookup.name  = NSLocalizedString(@"Utah", @"State 'Utah' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:44];
    lookup.name  = NSLocalizedString(@"Vermont", @"State 'Vermont' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:45];
    lookup.name  = NSLocalizedString(@"Virginia", @"State 'Virginia' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:46];
    lookup.name  = NSLocalizedString(@"Washington", @"State 'Washington' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:47];
    lookup.name  = NSLocalizedString(@"West Virginia", @"State 'West Virginia' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:48];
    lookup.name  = NSLocalizedString(@"Wisconsin", @"State 'Wisconsin' lookup type");

    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeState];
    lookup.order = [NSNumber numberWithInt:49];
    lookup.name  = NSLocalizedString(@"Wyoming", @"State 'Wyoming' lookup type");
}

-(void) createWorkerValues
{
    Lookup* lookup = nil;
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeWorker];
    lookup.order = [NSNumber numberWithInt:0];
    lookup.name  = NSLocalizedString(@"Author", @"Book Worker 'Author' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeWorker];
    lookup.order = [NSNumber numberWithInt:1];
    lookup.name  = NSLocalizedString(@"Editor", @"Book Worker 'Editor' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeWorker];
    lookup.order = [NSNumber numberWithInt:2];
    lookup.name  = NSLocalizedString(@"Illustrator", @"Book Worker 'Illustrator' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeWorker];
    lookup.order = [NSNumber numberWithInt:3];
    lookup.name  = NSLocalizedString(@"Contributor", @"Book Worker 'Contributor' lookup type");
    
    lookup       = [Lookup lookupInManagedObjectContext:self.managedObjectContext];
    lookup.type  = [NSNumber numberWithInt:LookupTypeWorker];
    lookup.order = [NSNumber numberWithInt:4];
    lookup.name  = NSLocalizedString(@"Translator", @"Book Worker 'Translator' lookup type");
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
