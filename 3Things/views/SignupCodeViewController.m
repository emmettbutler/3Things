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
    [button setTitle:@"Start Sharing" forState:UIControlStateNormal];
    button.frame = CGRectMake(50, screenRect.size.height/6, 160.0, 40.0);
    [self.view addSubview:button];
    
    CGRect codeFieldFrame = CGRectMake(50.0f, screenRect.size.height/6-50, 160.0f, 31.0f);
    codeField = [[UITextField alloc] initWithFrame:codeFieldFrame];
    codeField.placeholder = @"123456";
    codeField.borderStyle = UITextBorderStyleRoundedRect;
    codeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:codeField];
}

- (void)confirmWasTouched {
    if (![self codeIsValid]) {
        NSLog(@"Invalid signup code");
        return;
    }
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
