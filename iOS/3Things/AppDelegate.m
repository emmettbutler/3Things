//
//  AppDelegate.m
//  3Things
//
//  Created by Emmett Butler on 9/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginTypePickerViewController.h"
#import "My3ThingsViewController.h"
#import "FriendFeedViewController.h"
#import "UserStore.h"
#import "User.h"
#import "TTNetManager.h"

//NSString *const SCSessionStateChangedNotification = @"com.facebook.ThreeThings:FBSessionStateChangedNotification";

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [TTNetManager sharedInstance];
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            UITextAttributeTextColor: [[TTNetManager sharedInstance] colorWithHexString:HEADER_TEXT_COLOR],
                                                            UITextAttributeFont: [UIFont fontWithName:HEADER_FONT size:HEADER_FONT_SIZE]
                                                            }];

    if ([[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%d", kAccessToken]] != NULL ||
     FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            TTLog(@"Facebook session found");
        }
        // get the stored access token from defauls, put it in TTNetManager's memory, re-save it
        [[TTNetManager sharedInstance] loginToken:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d", kAccessToken]]];
        self.viewController = [[FriendFeedViewController alloc] init];
        UIViewController *viewController = self.viewController;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        self.window.rootViewController = navController;
    } else {
        self.viewController = [[LoginTypePickerViewController alloc] init];
        self.window.rootViewController = self.viewController;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            TTLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"3Things" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"3Things.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        TTLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)dataWasReceived:(NSURLResponse *)res withData:(NSData *)data andError:(NSError *)error andOriginURL:(NSURL *)url
{
    TTLog(@"Data received from %@", url);
    if([url.path isEqualToString:@"/fblogin"]){
        if([((NSHTTPURLResponse *)res) statusCode] == 200){
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                  error:&jsonError];
            TTLog(@"json response: %@", json);
            NSString *uid = [[json objectForKey:@"data"] objectForKey:@"uid"];
            NSString *name = [[json objectForKey:@"data"] objectForKey:@"name"];
            NSString *fbid = [[json objectForKey:@"data"] objectForKey:@"fbid"];
            [[TTNetManager sharedInstance] loginToken:[[json objectForKey:@"data"] objectForKey:@"access_token"]];
            [UserStore initCurrentUserWithUserName:name andUserID:uid andFBID:fbid];
            
            UserStore *userStore = [[UserStore alloc] init];
            // TODO - go to compose view if the user has no posts
            self.viewController = [[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] init] andIsCurrent:[NSNumber numberWithBool:YES] andUser:[userStore getAuthenticatedUser]];
            UIViewController *viewController = self.viewController;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            self.window.rootViewController = navController;
            TTLog(@"Facebook login successful");
        }
    }
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                 if (!error) {
                     TTLog(@"user name: %@, id: %@", user.name, user.id);
                     [TTNetManager sharedInstance].netDelegate = self;
                     [[TTNetManager sharedInstance] registerUserWithFacebookID:user.id andName:user.name];
                 }
            }];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            TTLog(@"Facebook login failed");
            break;
        default:
            break;
    }
    
    /*[[NSNotificationCenter defaultCenter]
     postNotificationName:SCSessionStateChangedNotification
     object:session];
    */
     
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)openSession
{
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

@end
