//
//  ShareDayStore.m
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "ShareDayStore.h"
#import "AppDelegate.h"

@implementation ShareDayStore

- (ShareDay *)createShareDay
{
    NSManagedObject *newItem = [self createItem:@"ShareDay"];
    return (ShareDay *)newItem;
}

- (NSArray *)allItems
{
    NSArray *result = [self allItems:@"ShareDay" withSort:@"date" andPredicate:NULL];
    return result;
}

- (ShareDay *)getToday
{
    NSDate *date = [NSDate date];
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date = %@)", dateOnly];
    NSArray *result = [self allItems:@"ShareDay" withSort:@"date" andPredicate:predicate];
    NSLog(@"Today: %@", result);
    return result.count == 0 ? NULL : [result objectAtIndex:0];
}

@end
