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

-(User *)newUserFromDictionary:(NSDictionary *)userDict {
    NSManagedObject *user = [self createItem:@"User"];
    ((User *)user).name = [userDict objectForKey:@"name"];
    ((User *)user).profileImageURL = [userDict objectForKey:@"profileImageID"];
    ((User *)user).facebookID = [userDict objectForKey:@"fbid"];
    return (User *)user;
}

- (User *)createUser:(NSString *)uid withName:(NSString *)name andImgURL:(NSString *)profImgURL
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userID = %@)", uid];
    NSArray *result = [self allItems:@"User" withSort:@"userID" andPredicate:predicate];
    TTLog(@"In createUser: searching for uid %@:  %@", uid, result);
    if (result.count == 0) {
        NSManagedObject *newItem = [self createItem:@"User"];
        ((User *)newItem).name = name;
        ((User *)newItem).profileImageLocalURL = @"";
        ((User *)newItem).profileImageURL = profImgURL;
        ((User *)newItem).userID = uid;
        TTLog(@"Found no user, created %@", (User *)newItem);
        [self saveChanges];
        return (User *)newItem;
    } else {
        return [result objectAtIndex:0];
    }
}

- (User *)createUser:(NSString *)uid withName:(NSString *)name andFBID:(NSString *)facebookID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userID = %@)", uid];
    NSArray *result = [self allItems:@"User" withSort:@"userID" andPredicate:predicate];
    TTLog(@"In createUser: facebook searching for uid %@:  %@", uid, result);
    if (result.count == 0) {
        NSManagedObject *newItem = [self createItem:@"User"];
        ((User *)newItem).name = name;
        ((User *)newItem).facebookID = facebookID;
        ((User *)newItem).userID = uid;
        TTLog(@"Found no user, created %@", (User *)newItem);
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
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d", kAuthUserID]];
    [UserStore initCurrentUserWithImage:NULL andEmail:nil andUserName:nil andPassword:nil andUserID:userID];
}

+(void) initCurrentUserWithImage:(NSString *)imageURL
                        andEmail:(NSString *)email
                     andUserName:(NSString *)uname
                     andPassword:(NSString *)pw
                       andUserID:(NSString *)uid {
    UserStore *userStore = [[UserStore alloc] init];
    [userStore createUser:uid withName:uname andImgURL:imageURL];
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:[NSString stringWithFormat:@"%d", kAuthUserID]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void) initCurrentUserWithUserName:(NSString *)uname andUserID:(NSString *)uid andFBID:(NSString *)facebookID
{
    UserStore *userStore = [[UserStore alloc] init];
    [userStore createUser:uid withName:uname andFBID:facebookID];
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:[NSString stringWithFormat:@"%d", kAuthUserID]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
