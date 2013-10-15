//
//  LoginEmailViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/14/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "LoginEmailViewController.h"
#import "DayListViewController.h"
#import "My3ThingsViewController.h"
#import "UserStore.h"

@interface LoginEmailViewController ()

@end

@implementation LoginEmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton addTarget:self
                         action:@selector(loginWasTouched)
               forControlEvents:UIControlEventTouchDown];
    [loginButton setTitle:@"Enter details and login" forState:UIControlStateNormal];
    loginButton.frame = CGRectMake(0, 290, screenFrame.size.width, 40.0);
    [self.view addSubview:loginButton];
}

- (void)loginWasTouched {
    NSLog(@"Login selected");
    [UserStore initCurrentUser];
    [self setModalPresentationStyle:UIModalPresentationPageSheet];
    UIViewController *viewController;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"day_complete"] boolValue] == YES) {
        viewController = [[DayListViewController alloc] init];
    } else {
        viewController = [[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] init] andIsCurrent:[NSNumber numberWithBool:YES]];
    }
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
