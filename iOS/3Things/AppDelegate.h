//
//  AppDelegate.h
//  3Things
//
//  Created by Emmett Butler on 9/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "TTNetManager.h"
#import <FacebookSDK/FacebookSDK.h>

@class SplashViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, TTNetManagerDelegate>

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)openSession;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;

@end
