//
//  SplashViewController.m
//  3Things
//
//  Created by Emmett Butler on 9/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "SplashViewController.h"
#import "SignupCodeViewController.h"
#import "FriendFeedViewController.h"
#import "UserStore.h"
#import "My3ThingsViewController.h"
#import "TTNetManager.h"

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
    firstNameField.delegate = self;
    firstNameField.placeholder = @"Name";
    firstNameField.borderStyle = UITextBorderStyleRoundedRect;
    firstNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    firstNameField.returnKeyType = UIReturnKeyNext;
    [firstNameField becomeFirstResponder];
    [self.view addSubview:firstNameField];
    
    CGRect emailFieldFrame = CGRectMake(20.0f, screenRect.size.height/2-120, 280.0f, 31.0f);
    emailField = [[UITextField alloc] initWithFrame:emailFieldFrame];
    emailField.delegate = self;
    emailField.placeholder = @"Email";
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.borderStyle = UITextBorderStyleRoundedRect;
    emailField.returnKeyType = UIReturnKeyNext;
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:emailField];
    
    CGRect pwFieldFrame = CGRectMake(20.0f, screenRect.size.height/2-70, 280.0f, 31.0f);
    pwField = [[UITextField alloc] initWithFrame:pwFieldFrame];
    pwField.delegate = self;
    pwField.placeholder = @"Password";
    pwField.secureTextEntry = YES;
    pwField.returnKeyType = UIReturnKeyNext;
    pwField.borderStyle = UITextBorderStyleRoundedRect;
    pwField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:pwField];
    
    CGRect pwConfirmFieldFrame = CGRectMake(20.0f, screenRect.size.height/2-20, 280.0f, 31.0f);
    pwConfirmField = [[UITextField alloc] initWithFrame:pwConfirmFieldFrame];
    pwConfirmField.placeholder = @"Confirm Password";
    pwConfirmField.delegate = self;
    pwConfirmField.secureTextEntry = YES;
    pwConfirmField.returnKeyType = UIReturnKeyGo;
    pwConfirmField.borderStyle = UITextBorderStyleRoundedRect;
    pwConfirmField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:pwConfirmField];
}

- (void)loginWasTouched
{
    [self.view endEditing:YES];
    
    if (![self fieldsAreValid]){
        if (!self.errViewIsShown) {
            TTLog(@"Error: not all required fields are present in signup data");
            self.errViewIsShown = YES;
            ErrorPromptViewController *errViewController = [[ErrorPromptViewController alloc] initWithPromptText:@"Please fill in all fields"];
            [self addChildViewController:errViewController];
            [self.view addSubview:errViewController.view];
            errViewController.errDelegate = self;
            errViewController.view.frame = errViewController.frame;
            [errViewController didMoveToParentViewController:self];
        }
    } else {
        TTLog(@"Signup information received:\n    fname: %@\n   email: %@",
              firstNameField.text, emailField.text);
        [TTNetManager sharedInstance].netDelegate = self;
        [[TTNetManager sharedInstance] registerUser:emailField.text
                                           withName:firstNameField.text
                                        andPassword:pwField.text
                                    andPasswordConf:pwConfirmField.text];
    }
}

- (void)dataWasReceived:(NSURLResponse *)res withData:(NSData *)data andError:(NSError *)error andOriginURL:(NSURL *)url {
    TTLog(@"Data received from %@", url.path);
    TTLog(@"Response: %@", res);
    if (error == NULL) {
        if ([url.path isEqualToString:@"/register"]){
            if([((NSHTTPURLResponse *)res) statusCode] != 304){
                NSError *jsonError = nil;
                NSDictionary *json = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                      error:&jsonError];
                TTLog(@"json response: %@", json);
                
                NSString *confCode = [[json objectForKey:@"data"] objectForKey:@"conf_code"];
                self.userEmail = [[json objectForKey:@"data"] objectForKey:@"email"];
                self.userPassword = pwField.text;
                
                signupCodeController = [[SignupCodeViewController alloc] initWithConfirmationCode:confCode];
                [self addChildViewController:signupCodeController];
                [self.view addSubview:signupCodeController.view];
                signupCodeController.view.frame = signupCodeController.frame;
                [signupCodeController didMoveToParentViewController:self];
                self.didSelectImage = YES;
            }
        } else if([url.path isEqualToString:@"/login"]){
            if([((NSHTTPURLResponse *)res) statusCode] == 200){
                NSError *jsonError = nil;
                NSDictionary *json = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                      error:&jsonError];
                TTLog(@"json response: %@", json);
                NSString *uid = [[json objectForKey:@"data"] objectForKey:@"uid"];
                [[TTNetManager sharedInstance] loginToken:[[json objectForKey:@"data"] objectForKey:@"access_token"]];
                [UserStore initCurrentUserWithImage:self.profLocalImageURL
                                           andEmail:self.userEmail
                                        andUserName:firstNameField.text
                                        andPassword:self.userPassword
                                          andUserID:uid];
            }
        }
    }
}

- (void)photoWasSelected:(UIImage *)selectedImage {
    TTLog(@"got image: %@", selectedImage);
}
- (void)photoWasSaved:(NSURL *)savedPhotoURL {
    TTLog(@"got image url: %@", savedPhotoURL);
    self.profLocalImageURL = [savedPhotoURL absoluteString];
    [[TTNetManager sharedInstance] loginUser:self.userEmail withPassword:self.userPassword];
}

- (void)continueWasTouched {
    UserStore *userStore = [[UserStore alloc] init];
    if (self.profLocalImageURL != nil && [userStore getAuthenticatedUser] != NULL){
        TTLog(@"Current access token: %@", [[TTNetManager sharedInstance] currentAccessToken]);
        UIViewController *viewController;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d", kDayComplete]] boolValue] == YES) {
            viewController = [[FriendFeedViewController alloc] init];
        } else {
            viewController = [[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] init] andIsCurrent:[NSNumber numberWithBool:YES] andUser:[userStore getAuthenticatedUser]];
        }
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self presentViewController:navController animated:YES completion:NULL];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == firstNameField) {
        [firstNameField resignFirstResponder];
        [emailField becomeFirstResponder];
    } else if(theTextField == emailField) {
        [emailField resignFirstResponder];
        [pwField becomeFirstResponder];
    } else if (theTextField == pwField){
        [pwField resignFirstResponder];
        [pwConfirmField becomeFirstResponder];
    } else if (theTextField == pwConfirmField) {
        [self loginWasTouched];
    }
    return YES;
}

- (BOOL) fieldsAreValid {
    if ([firstNameField.text isEqualToString:@""]){
        return NO;
    }
    if ([emailField.text isEqualToString:@""]){
        return NO;
    }
    return YES;
}

@end
