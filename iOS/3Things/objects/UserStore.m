//
//  UserStore.m
//  3Things
//
//  Created by Emmett Butler on 10/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "UserStore.h"

@implementation UserStore

- (User *)createUser:(NSNumber *)identifier withName:(NSString *)name andLocalImgURL:(NSString *)localProfImgURL
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier = %@)", identifier];
    NSArray *result = [self allItems:@"User" withSort:@"identifier" andPredicate:predicate];
    NSLog(@"In createUser: %@", result);
    if (result.count == 0) {
        NSManagedObject *newItem = [self createItem:@"User"];
        ((User *)newItem).identifier = identifier;
        ((User *)newItem).name = name;
        ((User *)newItem).profileImageLocalURL = localProfImgURL;
        ((User *)newItem).profileImageURL = @"";
        NSLog(@"Found no user, created %@", (User *)newItem);
        [self saveChanges];
        return (User *)newItem;
    } else {
        return [result objectAtIndex:0];
    }
}

- (NSArray *)allUsers
{
    NSArray *result = [self allItems:@"User" withSort:NULL andPredicate:NULL];
    return result;
}

- (User *)getAuthenticatedUser
{
    NSNumber *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_user_id"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier = %@)", identifier];
    NSArray *result = [self allItems:@"User" withSort:@"identifier" andPredicate:predicate];
    return result.count == 0 ? NULL : [result objectAtIndex:0];
}

+(void) initCurrentUser {
    [UserStore initCurrentUserWithImage:NULL andEmail:nil andUserName:nil andPassword:nil];
}

+(void) initCurrentUserWithImage:(NSString *)imageURL andEmail:(NSString *)email andUserName:(NSString *)uname andPassword:(NSString *)pw {
    UserStore *userStore = [[UserStore alloc] init];
    NSLog(@"image url: %@", imageURL);
    // use actual entered user data here - this should eventually take arguments
    [userStore createUser:[NSNumber numberWithInt:123456] withName:uname andLocalImgURL:imageURL];
    if (imageURL != NULL) {
        [[NSUserDefaults standardUserDefaults] setObject:imageURL forKey:@"cur_user_prof_pic"];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@"123456" forKey:@"auth_user_id"];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"cur_user_email"];
    [[NSUserDefaults standardUserDefaults] setObject:uname forKey:@"cur_user_uname"];
    [[NSUserDefaults standardUserDefaults] setObject:@"aowe7faboisuebf" forKey:@"user_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // publish to web
}

@end
