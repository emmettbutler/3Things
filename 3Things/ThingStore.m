//
//  ShareDayStore.m
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "ThingStore.h"
#import "AppDelegate.h"

@implementation ThingStore

- (Thing *)createThing
{
    NSManagedObject *newItem = [self createItem:@"Thing"];
    return (Thing *)newItem;
}

- (NSArray *)allItems
{
    NSArray *result = [self allItems:@"Thing" withSort:@"date"];
    return result;
}

@end
