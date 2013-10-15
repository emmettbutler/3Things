//
//  LoginTypePickerViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/14/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "LoginTypePickerViewController.h"
#import "SplashViewController.h"
#import "LoginEmailViewController.h"

@interface LoginTypePickerViewController ()

@end

@implementation LoginTypePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [shareButton addTarget:self
                    action:@selector(emailLoginWasTouched)
          forControlEvents:UIControlEventTouchDown];
    [shareButton setTitle:@"Login via email" forState:UIControlStateNormal];
    shareButton.frame = CGRectMake(0, 240, screenFrame.size.width, 40.0);
    [self.view addSubview:shareButton];
    
    UIButton *newAccountButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [newAccountButton addTarget:self
                    action:@selector(newAccountWasTouched)
          forControlEvents:UIControlEventTouchDown];
    [newAccountButton setTitle:@"I don't have an account" forState:UIControlStateNormal];
    newAccountButton.frame = CGRectMake(0, 290, screenFrame.size.width, 40.0);
    [self.view addSubview:newAccountButton];
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 140, screenFrame.size.width, 60)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = @"THREE THINGS";
    text.font = [UIFont systemFontOfSize:23];
    text.backgroundColor = self.view.backgroundColor;
    text.editable = NO;
    [self.view addSubview:text];
}

- (void)emailLoginWasTouched
{
    NSLog(@"Chose login via email");
    [self setModalPresentationStyle:UIModalPresentationPageSheet];
    UIViewController *viewController = [[LoginEmailViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:NULL];
}

- (void)newAccountWasTouched
{
    NSLog(@"New account was selected");
    [self setModalPresentationStyle:UIModalPresentationPageSheet];
    UIViewController *viewController = [[SplashViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
