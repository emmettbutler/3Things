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
        if (shares == nil){
            NSCalendar* myCalendar = [NSCalendar currentCalendar];
            NSDateComponents* components = [myCalendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                         fromDate:[NSDate date]];
            [components setHour: 0];
            [components setMinute: 0];
            [components setSecond: 0];
            self.date = [myCalendar dateFromComponents:components];
            self.theThings = [[NSMutableArray alloc] initWithCapacity:3];
            for (int i = 0; i < 3; i++) {
                [self.theThings addObject:@{@"text": @"", @"localImageURL": @""}];
            }
        } else {
            //self.date = /* parse date from shares */;
            for (int i = 0; i < 3; i++){
                // add each list item to self.theThings, after some munging
            }
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
    ret.user = shares.user;
    return ret;
}

@end
