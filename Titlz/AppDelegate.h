//
//  AppDelegate.h
//  Titlz
//
//  Created by David Lains on 12/26/11.
//  Copyright (c) 2011 Dagger Lake Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) UIWindow* window;
@property(strong, nonatomic) UITabBarController *tabBarController;

@property(readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property(readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property(readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

-(void) saveContext;
-(NSURL*) applicationDocumentsDirectory;


@end
