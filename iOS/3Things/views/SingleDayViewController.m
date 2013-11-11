//
//  SingleDayViewController.m
//  3Things
//
//  Created by Emmett Butler on 11/11/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "SingleDayViewController.h"
#import "UserStore.h"

@interface SingleDayViewController ()

@end

@implementation SingleDayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UserStore *userStore = [[UserStore alloc] init];
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    self.frame = CGRectMake(0, 50+(screenFrame.size.height/2), screenFrame.size.width, 100);
}

@end
