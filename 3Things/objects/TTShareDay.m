//
//  TTShareDay.m
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "TTShareDay.h"
#import "TTThing.h"

@implementation TTShareDay

- (id) init
{
    self = [super init];
    if (self) {
        self.userFullName = @"Heather Smith";
        self.userName = @"heather";
        
        NSCalendar* myCalendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [myCalendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                     fromDate:[NSDate date]];
        [components setHour: 20];
        [components setMinute: 0];
        [components setSecond: 0];
        self.date = [myCalendar dateFromComponents:components];
        
        self.theThings = [[NSMutableArray alloc] init];
        
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
        for (int i = 0; i < texts.count; i++) {
            //[self.theThings addObject:[[TTThing alloc] initWithText:[texts objectAtIndex:arc4random() % texts.count]]];
        }
    }
    return self;
}

@end
