//
//  BottomNavViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "BottomNavViewController.h"
#import "TTNetManager.h"

@interface BottomNavViewController ()

@end

@implementation BottomNavViewController
@synthesize navDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"b2b2b2" opacity:.9];

    UIButton *reviewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reviewButton addTarget:self
                   action:@selector(reviewWasTouched)
         forControlEvents:UIControlEventTouchDown];
    [reviewButton setTitle:@"Review" forState:UIControlStateNormal];
    reviewButton.frame = CGRectMake(130, -3, 80, 60);
    [self.view addSubview:reviewButton];
    
    UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [friendsButton addTarget:self
                     action:@selector(friendsWasTouched)
           forControlEvents:UIControlEventTouchDown];
    [friendsButton setTitle:@"FRIENDS" forState:UIControlStateNormal];
    friendsButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:HEADER_FONT_SIZE];
    [friendsButton setTintColor:[[TTNetManager sharedInstance] colorWithHexString:COLOR_YELLOW]];
    friendsButton.frame = CGRectMake(230, -3, 80, 60);
    [self.view addSubview:friendsButton];
    
    UIButton *calendarButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [calendarButton addTarget:self
                      action:@selector(calendarWasTouched)
            forControlEvents:UIControlEventTouchDown];
    [calendarButton setTitle:@"CALENDAR" forState:UIControlStateNormal];
    calendarButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:HEADER_FONT_SIZE];
    [calendarButton setTintColor:[[TTNetManager sharedInstance] colorWithHexString:@"FFFFFF"]];
    calendarButton.frame = CGRectMake(10, -3, 100, 60);
    [self.view addSubview:calendarButton];
}

- (void)reviewWasTouched{
    [self.navDelegate reviewWasTouched];
}

- (void)friendsWasTouched{
    [self.navDelegate friendsWasTouched];
}

- (void)calendarWasTouched{
    [self.navDelegate calendarWasTouched];
}

@end
