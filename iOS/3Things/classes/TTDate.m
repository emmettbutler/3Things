//
//  TTDate.m
//  3Things
//
//  Created by Emmett Butler on 11/18/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "TTDate.h"
#import "TTNetManager.h"

@implementation NSDate (TTDateExtensions)

-(NSString *)timeAgo {
    NSDate *todayDate = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    
    double ti = [self timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if (ti < 1) {
        return @"1 second";
    } else if (ti < 60) {
        return @"1 minute";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d hours", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d days", diff];
    } else if (ti < 31556926) {
        int diff = round(ti / 60 / 60 / 24 / 30);
        return [NSString stringWithFormat:@"%d months", diff];
    } else {
        int diff = round(ti / 60 / 60 / 24 / 30 / 12);
        return [NSString stringWithFormat:@"%d years", diff];
    }
}

@end
