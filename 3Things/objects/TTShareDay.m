//
//  TTShareDay.m
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "TTShareDay.h"
#import "TTThing.h"
#import "Thing.h"

@implementation TTShareDay

- (id) init
{
    self = [super init];
    if (self) {
        NSCalendar* myCalendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [myCalendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                     fromDate:[NSDate date]];
        [components setHour: 0];
        [components setMinute: 0];
        [components setSecond: 0];
        self.date = [myCalendar dateFromComponents:components];
        
        self.theThings = [[NSMutableArray alloc] initWithCapacity:3];
        
        NSArray *texts = [[NSArray alloc] initWithObjects:
                          @"Ran a personal best in the shamrock shuffle",
                          @"A new french bakery opened",
                          @"Two more days til the weekend",
                          @"Good day at work",
                          @"Good day at school",
                          @"Made a friend",
                          @"Petted some dogs",
                          @"Cookies",
                          @"Visiting friends",
                          @"Played a sport",
                          @"Went to an awesome concert",
                          nil];
        for (int i = 0; i < 3; i++) {
            [self.theThings addObject:@"Share something..."];
        }
    }
    return self;
}

+ (TTShareDay *)shareDayWithShareObject:(ShareDay *)shares {
    TTShareDay *ret = [[TTShareDay alloc] init];
    NSLog(@"In sharedaywithshareobject: %@", shares.thing1);
    if (shares.thing1 != NULL) {
        NSDictionary *thing = @{@"text": shares.thing1.text, @"localImageURL": shares.thing1.localImageURL};
        NSLog(@"loaded 1");
        [ret.theThings replaceObjectAtIndex:0 withObject:thing];
    }
    if (shares.thing2 != NULL) {
        NSLog(@"loaded 2");
        NSDictionary *thing = @{@"text": shares.thing2.text, @"localImageURL": shares.thing2.localImageURL};
        [ret.theThings replaceObjectAtIndex:1 withObject:thing];
    }
    if (shares.thing3 != NULL) {
        NSLog(@"loaded 3");
        NSDictionary *thing = @{@"text": shares.thing3.text, @"localImageURL": shares.thing3.localImageURL};
        [ret.theThings replaceObjectAtIndex:2 withObject:thing];
    }
    [ret setDate:shares.date];
    ret.user = shares.user;
    return ret;
}

@end
