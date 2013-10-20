//
//  SignupCodeViewController.m
//  3Things
//
//  Created by Emmett Butler on 9/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "SignupCodeViewController.h"
#import "DayListViewController.h"
#import "My3ThingsViewController.h"
#import "UserStore.h"
#import "SplashViewController.h"

@interface SignupCodeViewController ()

@end

@implementation SignupCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self.view.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1];
    self.frame = CGRectMake((screenRect.size.width/2)-150, (screenRect.size.height/2)-100, 300, 200);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(confirmWasTouched)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Choose profile photo" forState:UIControlStateNormal];
    button.frame = CGRectMake(50, screenRect.size.height/6, 160.0, 40.0);
    [self.view addSubview:button];
    
    CGRect codeFieldFrame = CGRectMake(50.0f, screenRect.size.height/6-50, 160.0f, 31.0f);
    codeField = [[UITextField alloc] initWithFrame:codeFieldFrame];
    codeField.placeholder = @"123456";
    codeField.borderStyle = UITextBorderStyleRoundedRect;
    codeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:codeField];
}

- (void)continueWasTouched {
    [(SplashViewController*)self.parentViewController continueWasTouched];
}

- (void)confirmWasTouched {
    if (![self codeIsValid]) {
        NSLog(@"Invalid signup code");
        return;
    }
    [self.view endEditing:YES];
    PhotoPromptViewController *promptViewController = [[PhotoPromptViewController alloc] init];
    promptViewController.promptDelegate = (SplashViewController*)self.parentViewController;
    [self.parentViewController addChildViewController:promptViewController];
    [self.parentViewController.view addSubview:promptViewController.view];
    promptViewController.view.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width+20, 200);
    [promptViewController didMoveToParentViewController:self];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button2 addTarget:self
                action:@selector(continueWasTouched)
      forControlEvents:UIControlEventTouchDown];
    [button2 setTitle:@"Continue" forState:UIControlStateNormal];
    button2.frame = CGRectMake(50, self.frame.size.height/6+100, 160.0, 40.0);
    [self.view addSubview:button2];
}

- (BOOL)codeIsValid {
    // TODO - get this from web
    NSString *enteredCode = [codeField text];
    if ([enteredCode isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
