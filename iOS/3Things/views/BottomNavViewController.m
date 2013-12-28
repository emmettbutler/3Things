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
    
    int totalHeight = 65, visibleHeight = 36;
    
    self.screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    self.frame = CGRectMake(0, self.screenFrame.size.height-totalHeight, self.screenFrame.size.width, totalHeight+30 /* why? */);
    //self.view.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000"];
    
    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0, totalHeight-visibleHeight, self.frame.size.width, visibleHeight+30)];
    bar.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"b2b2b2" opacity:.9];
    [self.view addSubview:bar];

    int buttonWidth = 65;
    
    UIButton *reviewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reviewButton addTarget:self
                   action:@selector(reviewWasTouched)
         forControlEvents:UIControlEventTouchUpInside];
    reviewButton.frame = CGRectMake(self.frame.size.width/2-buttonWidth/2, 0, buttonWidth, buttonWidth);
    [reviewButton setBackgroundImage:[UIImage imageNamed:@"Compose_Icon.png"] forState:UIControlStateNormal];
    [reviewButton setBackgroundImage:[UIImage imageNamed:@"Compose_Icon_depressed.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:reviewButton];
    
    UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [friendsButton addTarget:self
                       action:@selector(friendsWasTouched)
             forControlEvents:UIControlEventTouchUpInside];
    [friendsButton setTitle:@"FRIENDS" forState:UIControlStateNormal];
    friendsButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:HEADER_FONT_SIZE];
    [friendsButton setTintColor:[[TTNetManager sharedInstance] colorWithHexString:@"FFFFFF"]];
    friendsButton.frame = CGRectMake(205, totalHeight-visibleHeight, 100, 60);
    [self.view addSubview:friendsButton];
    
    UIButton *calendarButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [calendarButton addTarget:self
                      action:@selector(calendarWasTouched)
            forControlEvents:UIControlEventTouchUpInside];
    [calendarButton setTitle:@"CALENDAR" forState:UIControlStateNormal];
    calendarButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:HEADER_FONT_SIZE];
    [calendarButton setTintColor:[[TTNetManager sharedInstance] colorWithHexString:@"FFFFFF"]];
    calendarButton.frame = CGRectMake(10, totalHeight-visibleHeight, 100, 60);
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
