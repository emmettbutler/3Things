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
    NSArray *result = [self allItems:@"ShareDay" withSort:@"date"];
    return result;
}

@end
