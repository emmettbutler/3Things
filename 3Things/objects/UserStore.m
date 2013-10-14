//
//  UserStore.m
//  3Things
//
//  Created by Emmett Butler on 10/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "UserStore.h"

@implementation UserStore

- (User *)createUser:(NSNumber *)identifier withName:(NSString *)name
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier = %@)", identifier];
    NSArray *result = [self allItems:@"User" withSort:@"identifier" andPredicate:predicate];
    NSLog(@"In createUser: %@", result);
    if (result.count == 0) {
        NSManagedObject *newItem = [self createItem:@"User"];
        ((User *)newItem).identifier = identifier;
        ((User *)newItem).name = name;
        ((User *)newItem).profileImageURL = @"http://www.modernestudio.com/biz-1.jpg";
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
    UserStore *userStore = [[UserStore alloc] init];
    // use actual entered user data here - this should eventually take arguments
    [userStore createUser:[NSNumber numberWithInt:123456] withName:@"Heather Smith"];
    [[NSUserDefaults standardUserDefaults] setObject:@"123456" forKey:@"auth_user_id"];
    [[NSUserDefaults standardUserDefaults] setObject:@"aowe7faboisuebf" forKey:@"user_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
