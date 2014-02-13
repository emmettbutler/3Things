//
//  TTShareDay.m
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "TTShareDay.h"
#import "Thing.h"
#import "TTNetManager.h"

@implementation TTShareDay

- (id) init
{
    return [self initWithSharesDictionary:nil];
}

- (id) initWithSharesDictionary:(NSDictionary *)shares
{
    self = [super init];
    if (self) {
        //TTLog(@"Shares: %@", shares);
        self.theThings = [[NSMutableArray alloc] initWithCapacity:3];
        if (shares == nil){
            NSCalendar* myCalendar = [NSCalendar currentCalendar];
            NSDateComponents* components = [myCalendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                         fromDate:[NSDate date]];
            [components setHour: 0];
            [components setMinute: 0];
            [components setSecond: 0];
            self.date = [myCalendar dateFromComponents:components];
            self.time = [NSDate date];
            self._id = nil;
            for (int i = 0; i < 3; i++) {
                [self.theThings addObject:@{@"text": @"", @"localImageURL": @""}];
            }
        } else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
            self.date = [dateFormatter dateFromString:shares[@"date"]];
            self.time = [dateFormatter dateFromString:shares[@"time"]];
            self._id = shares[@"_id"];
            self.commentCount = shares[@"comments_count"];
            for (int i = 0; i < 3; i++){
                [self.theThings addObject:shares[@"things"][i]];
            }
            TTLog(@"Constructed day from dictionary");
        }
    }
    return self;
}

+ (TTShareDay *)shareDayWithShareObject:(ShareDay *)shares {
    TTShareDay *ret = [[TTShareDay alloc] init];
    for (Thing *thing in shares.things){
        NSDictionary *newThing = @{@"text": thing.text, @"localImageURL": thing.localImageURL};
        [ret.theThings replaceObjectAtIndex:[thing.index intValue] withObject:newThing];
    }
    [ret setDate:shares.date];
    [ret setTime:shares.time];
    ret.user = shares.user;
    return ret;
}

@end
