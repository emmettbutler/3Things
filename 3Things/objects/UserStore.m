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
        ((User *)newItem).profileImageURL = @"http://studio757photography.files.wordpress.com/2008/03/copy-of-3617-500x300.jpg";
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

@end
