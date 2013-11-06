//
//  UserStore.m
//  3Things
//
//  Created by Emmett Butler on 10/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "UserStore.h"
#import "TTNetManager.h"

@implementation UserStore

- (User *)createUser:(NSString *)uid withName:(NSString *)name andLocalImgURL:(NSString *)localProfImgURL
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userID = %@)", uid];
    NSArray *result = [self allItems:@"User" withSort:@"userID" andPredicate:predicate];
    NSLog(@"In createUser: %@", result);
    if (result.count == 0) {
        NSManagedObject *newItem = [self createItem:@"User"];
        ((User *)newItem).name = name;
        ((User *)newItem).profileImageLocalURL = localProfImgURL;
        ((User *)newItem).profileImageURL = @"";
        ((User *)newItem).userID = uid;
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
    NSNumber *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d", kAuthUserID]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userID = %@)", identifier];
    NSArray *result = [self allItems:@"User" withSort:@"userID" andPredicate:predicate];
    return result.count == 0 ? NULL : [result objectAtIndex:0];
}

+(void) initCurrentUser {
    [UserStore initCurrentUserWithImage:NULL andEmail:nil andUserName:nil andPassword:nil andUserID:nil];
}

+(void) initCurrentUserWithImage:(NSString *)imageURL
                        andEmail:(NSString *)email
                     andUserName:(NSString *)uname
                     andPassword:(NSString *)pw
                       andUserID:(NSString *)uid {
    UserStore *userStore = [[UserStore alloc] init];
    NSLog(@"image url: %@", imageURL);
    // use actual entered user data here - this should eventually take arguments
    [userStore createUser:uid withName:uname andLocalImgURL:imageURL];
    if (imageURL != NULL) {
        [[NSUserDefaults standardUserDefaults] setObject:imageURL forKey:@"cur_user_prof_pic"];
    }
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:[NSString stringWithFormat:@"%d", kAuthUserID]];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"cur_user_email"];
    [[NSUserDefaults standardUserDefaults] setObject:uname forKey:@"cur_user_uname"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // publish to web
}

@end
