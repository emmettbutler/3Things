//
//  ShareDayStore.m
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "ShareDayStore.h"
#import "AppDelegate.h"
#import "TTNetManager.h"
#import "UserStore.h"

@implementation ShareDayStore

- (ShareDay *)createShareDay
{
    NSManagedObject *newItem = [self createItem:@"ShareDay"];
    return (ShareDay *)newItem;
}

- (NSArray *)allItemsForUser:(User *)user
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(user.userID = %@)", user.userID];
    NSArray *result = [self allItems:@"ShareDay" withSort:@"date" andPredicate:predicate];
    TTLog(@"allItemsForUser count: %d", [result count]);
    return result;
}

- (NSArray *)allItemsForUser:(User *)user andDay:(NSString *)day
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSDate *date = [dateFormatter dateFromString:day];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.userID = %@ AND date = %@", user.userID, date];
    NSArray *result = [self allItems:@"ShareDay" withSort:@"date" andPredicate:predicate];
    TTLog(@"allItemsForUser:andDay count: %d", [result count]);
    return result;
}

- (ShareDay *)getToday
{
    NSDate *date = [NSDate date];
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    
    UserStore *userStore = [[UserStore alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date = %@) AND (user.userID = %@)", dateOnly, [[userStore getAuthenticatedUser] userID]];
    NSArray *result = [self allItems:@"ShareDay" withSort:@"date" andPredicate:predicate];
    ShareDay *ret = result.count == 0 ? NULL : [result objectAtIndex:0];
    return ret;
}

@end
