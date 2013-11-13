//
//  BottomNavViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "BottomNavViewController.h"

@interface BottomNavViewController ()

@end

@implementation BottomNavViewController
@synthesize navDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1];
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    CGRect popupFrame = CGRectMake(0, screenFrame.size.height-30, screenFrame.size.width, 50);
    
    UIButton *reviewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reviewButton addTarget:self
                   action:@selector(reviewWasTouched)
         forControlEvents:UIControlEventTouchDown];
    [reviewButton setTitle:@"Review" forState:UIControlStateNormal];
    reviewButton.frame = CGRectMake(100, 0, 80, 60);
    [self.view addSubview:reviewButton];
    
    UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [friendsButton addTarget:self
                     action:@selector(friendsWasTouched)
           forControlEvents:UIControlEventTouchDown];
    [friendsButton setTitle:@"Friends" forState:UIControlStateNormal];
    friendsButton.frame = CGRectMake(200, 0, 80, 60);
    [self.view addSubview:friendsButton];
}

- (void)reviewWasTouched{
    [self.navDelegate reviewWasTouched];
}

- (void)friendsWasTouched{
    [self.navDelegate friendsWasTouched];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
