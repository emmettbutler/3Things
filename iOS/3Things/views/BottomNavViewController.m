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
    
    int totalHeight = 65, visibleHeight = 30;
    
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
    friendsButton.frame = CGRectMake(224, (totalHeight-visibleHeight)+10, 80, 30);
    [friendsButton setBackgroundImage:[UIImage imageNamed:@"Friends_bottom_Menu.png"] forState:UIControlStateNormal];
    [friendsButton setBackgroundImage:[UIImage imageNamed:@"Friends_bottom_Menu_depressed.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:friendsButton];
    
    UIButton *calendarButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [calendarButton addTarget:self action:@selector(calendarWasTouched) forControlEvents:UIControlEventTouchUpInside];
    [calendarButton addTarget:self action:@selector(calendarTouchBegan) forControlEvents:UIControlEventTouchDown];
    [calendarButton setTitle:@"" forState:UIControlStateNormal];
    [calendarButton setTintColor:[[TTNetManager sharedInstance] colorWithHexString:@"FFFFFF"]];
    calendarButton.frame = CGRectMake(10, totalHeight-visibleHeight+10, 100, 60);
    UIView *buttonView = [[UIView alloc] init];
    calImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Cal_Icon.png"]];
    calImageView.frame = CGRectMake(75, 10, 20, 10);
    [buttonView addSubview:calImageView];
    calTextView = [[UITextView alloc] init];
    calTextView.frame = CGRectMake(0, 0, 90, 20);
    calTextView.text = @"CALENDAR";
    calTextView.font = [UIFont fontWithName:HEADER_FONT size:12];
    calTextView.textColor = [UIColor colorWithWhite:1 alpha:1];
    calTextView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [buttonView addSubview:calTextView];
    [calendarButton addSubview:buttonView];
    [self.view addSubview:calendarButton];
}

- (void)reviewWasTouched{
    [self.navDelegate reviewWasTouched];
}

- (void)friendsWasTouched{
    [self.navDelegate friendsWasTouched];
}

- (void)calendarTouchBegan
{
    calTextView.textColor = [UIColor colorWithWhite:.5 alpha:1];
    calImageView.image = [UIImage imageNamed:@"Cal_Icon_depressed.png"];
}

- (void)calendarWasTouched{
    calTextView.textColor = [UIColor colorWithWhite:1 alpha:1];
    calImageView.image = [UIImage imageNamed:@"Cal_Icon.png"];
    [self.navDelegate calendarWasTouched];
}

@end
