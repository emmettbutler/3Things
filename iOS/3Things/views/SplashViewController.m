//
//  SplashViewController.m
//  3Things
//
//  Created by Emmett Butler on 9/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "SplashViewController.h"
#import "SignupCodeViewController.h"
#import "DayListViewController.h"
#import "UserStore.h"
#import "My3ThingsViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.profLocalImageURL = nil;
    self.didSelectImage = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(loginWasTouched)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Login" forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 30.0, 160.0, 40.0);
    [self.view addSubview:button];
    
    CGRect firstNameFieldFrame = CGRectMake(20.0f, screenRect.size.height/2-170, 280.0f, 31.0f);
    firstNameField = [[UITextField alloc] initWithFrame:firstNameFieldFrame];
    firstNameField.placeholder = @"First Name";
    firstNameField.borderStyle = UITextBorderStyleRoundedRect;
    firstNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:firstNameField];
    
    CGRect lastNameFieldFrame = CGRectMake(20.0f, screenRect.size.height/2-120, 280.0f, 31.0f);
    lastNameField = [[UITextField alloc] initWithFrame:lastNameFieldFrame];
    lastNameField.placeholder = @"Last Name";
    lastNameField.borderStyle = UITextBorderStyleRoundedRect;
    lastNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:lastNameField];
    
    CGRect emailFieldFrame = CGRectMake(20.0f, screenRect.size.height/2-70, 280.0f, 31.0f);
    emailField = [[UITextField alloc] initWithFrame:emailFieldFrame];
    emailField.placeholder = @"Email";
    emailField.borderStyle = UITextBorderStyleRoundedRect;
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:emailField];
    
    CGRect pwFieldFrame = CGRectMake(20.0f, screenRect.size.height/2-20, 280.0f, 31.0f);
    pwField = [[UITextField alloc] initWithFrame:pwFieldFrame];
    pwField.placeholder = @"Password";
    pwField.secureTextEntry = YES;
    pwField.borderStyle = UITextBorderStyleRoundedRect;
    pwField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:pwField];
    
    CGRect pwConfirmFieldFrame = CGRectMake(20.0f, screenRect.size.height/2+30, 280.0f, 31.0f);
    pwConfirmField = [[UITextField alloc] initWithFrame:pwConfirmFieldFrame];
    pwConfirmField.placeholder = @"Confirm Password";
    pwConfirmField.secureTextEntry = YES;
    pwConfirmField.borderStyle = UITextBorderStyleRoundedRect;
    pwConfirmField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:pwConfirmField];
}

- (void)loginWasTouched
{
    [self.view endEditing:YES];
    
    if (![self fieldsAreValid]){
        if (!self.errViewIsShown) {
            NSLog(@"Error: not all required fields are present in signup data");
            self.errViewIsShown = YES;
            ErrorPromptViewController *errViewController = [[ErrorPromptViewController alloc] initWithPromptText:@"Please fill in all fields"];
            [self addChildViewController:errViewController];
            [self.view addSubview:errViewController.view];
            errViewController.errDelegate = self;
            errViewController.view.frame = errViewController.frame;
            [errViewController didMoveToParentViewController:self];
        }
    } else {
        NSLog(@"Signup information received:\n    fname: %@\n    lname: %@\n    email: %@",
              firstNameField.text, lastNameField.text, emailField.text);
        signupCodeController = [[SignupCodeViewController alloc] init];
        [self addChildViewController:signupCodeController];
        [self.view addSubview:signupCodeController.view];
        signupCodeController.view.frame = signupCodeController.frame;
        [signupCodeController didMoveToParentViewController:self];
        self.didSelectImage = YES;
    }
}

- (void)photoWasSelected:(UIImage *)selectedImage {
    NSLog(@"got image: %@", selectedImage);
}
- (void)photoWasSaved:(NSURL *)savedPhotoURL {
    NSLog(@"got image url: %@", savedPhotoURL);
    self.profLocalImageURL = [savedPhotoURL absoluteString];
}

- (void)continueWasTouched {
    [UserStore initCurrentUserWithImage:self.profLocalImageURL];
    UIViewController *viewController;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"day_complete"] boolValue] == YES) {
        viewController = [[DayListViewController alloc] init];
    } else {
        viewController = [[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] init] andIsCurrent:[NSNumber numberWithBool:YES]];
    }
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:NULL];
}

- (BOOL) fieldsAreValid {
    if ([firstNameField.text isEqualToString:@""]){
        return NO;
    }
    if ([lastNameField.text isEqualToString:@""]){
        return NO;
    }
    if ([emailField.text isEqualToString:@""]){
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
