//
//  SplashViewController.m
//  3Things
//
//  Created by Emmett Butler on 9/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "SplashViewController.h"
#import "SignupCodeViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(loginWasTouched)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Login" forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 110.0, 160.0, 40.0);
    [self.view addSubview:button];
    
    CGRect firstNameFieldFrame = CGRectMake(20.0f, screenRect.size.height/2, 280.0f, 31.0f);
    UITextField *firstNameField = [[UITextField alloc] initWithFrame:firstNameFieldFrame];
    firstNameField.placeholder = @"First Name";
    firstNameField.borderStyle = UITextBorderStyleRoundedRect;
    firstNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:firstNameField];
    
    CGRect lastNameFieldFrame = CGRectMake(20.0f, screenRect.size.height/2+50, 280.0f, 31.0f);
    UITextField *lastNameField = [[UITextField alloc] initWithFrame:lastNameFieldFrame];
    lastNameField.placeholder = @"Last Name";
    lastNameField.borderStyle = UITextBorderStyleRoundedRect;
    lastNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:lastNameField];
    
    CGRect emailFieldFrame = CGRectMake(20.0f, screenRect.size.height/2+100, 280.0f, 31.0f);
    UITextField *emailField = [[UITextField alloc] initWithFrame:emailFieldFrame];
    emailField.placeholder = @"Email";
    emailField.borderStyle = UITextBorderStyleRoundedRect;
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:emailField];
}

- (void)loginWasTouched
{
    [self setModalPresentationStyle:UIModalPresentationCurrentContext];
    
    if(self.presentedViewController == nil){
        SignupCodeViewController *viewController = [[SignupCodeViewController alloc] init];
        [self addChildViewController:viewController];
        [self.view addSubview:viewController.view];
        viewController.view.frame = viewController.frame;
        [viewController didMoveToParentViewController:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
