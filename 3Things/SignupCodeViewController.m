//
//  SignupCodeViewController.m
//  3Things
//
//  Created by Emmett Butler on 9/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "SignupCodeViewController.h"
#import "DayListViewController.h"

@interface SignupCodeViewController ()

@end

@implementation SignupCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(confirmWasTouched)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Start Sharing" forState:UIControlStateNormal];
    button.frame = CGRectMake(50, screenRect.size.height/6, 160.0, 40.0);
    [self.view addSubview:button];
    
    CGRect codeFieldFrame = CGRectMake(50.0f, screenRect.size.height/6-50, 160.0f, 31.0f);
    UITextField *codeField = [[UITextField alloc] initWithFrame:codeFieldFrame];
    codeField.placeholder = @"123456";
    codeField.borderStyle = UITextBorderStyleRoundedRect;
    codeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:codeField];
}

- (void)confirmWasTouched {
    [self setModalPresentationStyle:UIModalPresentationPageSheet];
    UIViewController *viewController = [[DayListViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
