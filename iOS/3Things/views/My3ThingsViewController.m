//
//  My3ThingsViewController.m
//  3Things
//
//  Created by Emmett Butler on 9/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "My3ThingsViewController.h"
#import "EditThingViewController.h"
#import "TTShareDay.h"
#import "ShareDayStore.h"
#import "UserHistoryViewController.h"
#import "UserStore.h"
#import "ThingDetailViewController.h"
#import "ErrorPromptViewController.h"
#import "TTNetManager.h"
#import "Thing.h"
#import "SingleDayViewController.h"

@interface My3ThingsViewController ()

@end

@implementation My3ThingsViewController

- (id)initWithIsCurrent:(NSNumber *)isCurrent {
    return [self initWithShareDay:NULL andIsCurrent:isCurrent];
}

- (id)initWithShareDay:(TTShareDay *)shares {
    return [self initWithShareDay:shares andIsCurrent:[NSNumber numberWithBool:NO]];
}

-(id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent
{
    self = [super init];
    if (self) {
        self.isCurrent = [isCurrent boolValue];
        self.completedThings = [NSNumber numberWithInt:self.isCurrent ? 0 : 3];
        
        ShareDayStore *itemStore = [[ShareDayStore alloc] init];
        ShareDay *today = [itemStore getToday];
        if (!self.isCurrent) {
            TTLog(@"Got sent a day in the past");
            self.shares = shares;
        } else if (today == NULL) {
            TTLog(@"Found nothing");
            self.shares = [[TTShareDay alloc] init];
        } else {
            TTLog(@"Found an entry");
            for (Thing *thing in today.things){
                TTLog(@"%@", thing.text);
            }
            self.shares = [TTShareDay shareDayWithShareObject:today];
        }
        TTLog(@"Entering 3things view: %@", self.shares.theThings);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UserStore *userStore = [[UserStore alloc] init];
	
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];

    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backWasTouched)];
	[[self navigationItem] setLeftBarButtonItem:button];
    if (self.isCurrent) {
        [[self navigationItem] setTitle:@"Review your three things"];
    }
    
	self.screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:self.screenFrame];
	CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = CGSizeMake(self.screenFrame.size.width, 60);
	[navBar setFrame:frame];
	[navBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[navBar setItems:[NSArray arrayWithObject:self.navigationItem]];
	[self.view addSubview:navBar];
    
    float mainButtonHeight = 65;
    
    CGRect scrollFrame = CGRectMake(frame.size.width*.05, frame.size.height+mainButtonHeight+40, frame.size.width*.9, self.screenFrame.size.height-frame.size.height-mainButtonHeight-80);
    self.tableHeight = [NSNumber numberWithFloat:scrollFrame.size.height];
    
    SingleDayViewController *dayView = [[SingleDayViewController alloc] initWithShareDay:self.shares andIsCurrent:[NSNumber numberWithBool:self.isCurrent]];
    [self addChildViewController:dayView];
    [self.view addSubview:dayView.view];
    dayView.view.frame = CGRectMake(18, 90, dayView.frame.size.width, dayView.frame.size.height);
    [dayView didMoveToParentViewController:self];

    if (self.isCurrent){
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [shareButton addTarget:self
                        action:@selector(shareWasTouched)
              forControlEvents:UIControlEventTouchDown];
        [shareButton setTitle:@"Share" forState:UIControlStateNormal];
        shareButton.frame = CGRectMake(80.0, self.screenFrame.size.height-40, 160.0, 40.0);
        [self.view addSubview:shareButton];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)backWasTouched {
    if (!self.errViewIsShown){
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)shareWasTouched {
    UserStore *userStore = [[UserStore alloc] init];
    if ([self.completedThings intValue] == 3) {
        [TTNetManager sharedInstance].netDelegate = (id<TTNetManagerDelegate>)self;
        [[TTNetManager sharedInstance] postShareDay:self.shares forUser:[[userStore getAuthenticatedUser] userID]];
        [[self navigationController] pushViewController:
         [[UserHistoryViewController alloc] init] animated:YES];
    } else {
        if (!self.errViewIsShown){
            self.errViewIsShown = YES;
            TTLog(@"Error: 3 things not completed for the day. Must complete 3 things before sharing.");
            ErrorPromptViewController *errViewController = [[ErrorPromptViewController alloc] initWithPromptText:@"Enter your 3 things before sharing"];
            [self addChildViewController:errViewController];
            [self.view addSubview:errViewController.view];
            errViewController.errDelegate = self;
            errViewController.view.frame = errViewController.frame;
            [errViewController didMoveToParentViewController:self];
        }
    }
}

- (BOOL)hasEnteredAllThings {
    if (self.shares.theThings.count == 0) return NO;
    for (int i = 0; i < 3; i++){
        if ([self.shares.theThings objectAtIndex:i] == NULL) {
            return NO;
        }
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
