//
//  TTSharesAccessor.m
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "TTSharesAccessor.h"

@implementation TTSharesAccessor

- (TTShareDay *)getFriendSharesForDate:(NSDate *)date
{
    TTShareDay *shares = [[TTShareDay alloc] init];
    return shares;
}

- (TTShareDay *)getFriendSharesForDate:(NSDate *)date andUserName:(NSString *)name
{
    TTShareDay *shares = [[TTShareDay alloc] init];
    return shares;
}

- (NSArray *)getHistoryForUser:(NSString *)userName
{
    NSMutableArray *history = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 20; i++) {
        TTShareDay *shares = [[TTShareDay alloc] init];
        [history addObject:shares];
    }
    
    return history;
}

@end
