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
#import "BackgroundLayer.h"
#import "SingleDayViewController.h"

@interface My3ThingsViewController ()

@end

@implementation My3ThingsViewController

- (id)initWithIsCurrent:(NSNumber *)isCurrent {
    UserStore *userStore = [[UserStore alloc] init];
    return [self initWithShareDay:NULL andIsCurrent:isCurrent andUser:[userStore getAuthenticatedUser]];
}

- (id)initWithShareDay:(TTShareDay *)shares {
    UserStore *userStore = [[UserStore alloc] init];
    return [self initWithShareDay:shares andIsCurrent:@(NO) andUser:[userStore getAuthenticatedUser]];
}

- (id) initWithShareDay:(TTShareDay *)shares andIsEdited:(NSNumber *)isEdited {
    self = [self initWithShareDay:shares andIsCurrent:@(YES) andUser:nil andIsEdited:isEdited];
    return self;
}

-(id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent andUser:(User *)user {
    return [self initWithShareDay:shares andIsCurrent:isCurrent andUser:user andIsEdited:@(NO)];
}

-(id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent andUser:(User *)user andIsEdited:(NSNumber *)isEdited
{
    self = [super init];
    if (self) {
        self.isCurrent = [isCurrent boolValue];
        self.user = user;
        if (self.user == nil){
            UserStore *userStore = [[UserStore alloc] init];
            self.user = [userStore getAuthenticatedUser];
        }
        self.isEdited = [isEdited boolValue];
        
        ShareDayStore *itemStore = [[ShareDayStore alloc] init];
        ShareDay *today = [itemStore getToday];
        if (!self.isCurrent || self.isEdited) {
            self.shares = shares;
        } else if (today == NULL) {
            self.shares = [[TTShareDay alloc] init];
        } else {
            self.shares = [TTShareDay shareDayWithShareObject:today];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_YELLOW];
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    CAGradientLayer *bgLayer = [BackgroundLayer greyGradient];
    bgLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    if (self.isCurrent) {
        [[self navigationItem] setTitle:@"REVIEW YOUR THREE THINGS"];
    } else {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backWasTouched)];
        [[self navigationItem] setLeftBarButtonItem:button];
        [[UIBarButtonItem appearance] setTintColor:[[TTNetManager sharedInstance] colorWithHexString:HEADER_TEXT_COLOR]];
    }
    
	self.screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:self.screenFrame];
	CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = CGSizeMake(self.screenFrame.size.width, 60);
	[navBar setFrame:frame];
	[navBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[navBar setItems:@[self.navigationItem]];
    self.navigationItem.hidesBackButton = YES;
	[self.view addSubview:navBar];
    
    UIView *titleView = [[UIView alloc] init];
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(-65, -20, 120, 40)];
    [logoView setImage:[UIImage imageNamed:@"Three_Things_logo.png"]];
    [titleView addSubview:logoView];
    self.navigationItem.titleView = titleView;
    
    if (self.isCurrent) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"SHARE" style:UIBarButtonItemStylePlain target:self action:@selector(shareWasTouched)];
        [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [[TTNetManager sharedInstance] colorWithHexString:HEADER_TEXT_COLOR],
                                                              UITextAttributeTextColor,
                                                              [UIFont fontWithName:HEADER_FONT size:14.0],
                                                              UITextAttributeFont,
                                                              nil] forState:UIControlStateNormal];
    }
    
    float mainButtonHeight = 65;
    
    CGRect scrollFrame = CGRectMake(frame.size.width*.05, frame.size.height+mainButtonHeight+40, frame.size.width*.9, self.screenFrame.size.height-frame.size.height-mainButtonHeight-80);
    self.tableHeight = @(scrollFrame.size.height);
    
    self.dayView = [[SingleDayViewController alloc] initWithShareDay:self.shares andIsCurrent:@(self.isCurrent) andUser:self.user andIsEdited:@(self.isEdited)];
    [self addChildViewController:self.dayView];
    [self.view addSubview:self.dayView.view];
    self.dayView.view.frame = CGRectMake(9, 65, self.dayView.frame.size.width, self.dayView.frame.size.height);
    [self.dayView didMoveToParentViewController:self];
}

- (void)backWasTouched {
    if (!self.errViewIsShown){
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)shareWasTouched {
    UserStore *userStore = [[UserStore alloc] init];
    if ([self.dayView.completedThings intValue] == 3) {
        [TTNetManager sharedInstance].netDelegate = (id<TTNetManagerDelegate>)self;
        [[TTNetManager sharedInstance] postShareDay:self.shares forUser:[[userStore getAuthenticatedUser] userID]];
        [[self navigationController] pushViewController:
         [[UserHistoryViewController alloc] init] animated:YES];
    } else {
        if (!self.errViewIsShown){
            self.errViewIsShown = YES;
            ErrorPromptViewController *errViewController = [[ErrorPromptViewController alloc] initWithPromptText:@"YOU DIDN'T FILL IN ALL THE FIELDS"];
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
        if (self.shares.theThings[i] == NULL) {
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
