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
    self.view.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_YELLOW];
    
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 40, screenFrame.size.width, 60)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = @"CREATE AN ACCOUNT";
    text.font = [UIFont fontWithName:HEADER_FONT size:16];
    text.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    text.backgroundColor = self.view.backgroundColor;
    text.editable = NO;
    [self.view addSubview:text];
    
    float textFieldWidth = screenFrame.size.width*.85, textFieldHeight = 35;
    
    int fNameFieldY = 110, fieldSpacing = 60;
    
    UITextView *fnameText = [[UITextView alloc] initWithFrame:CGRectMake(screenFrame.size.width/2-textFieldWidth/2, fNameFieldY-24, 70, 30)];
    fnameText.textAlignment = NSTextAlignmentLeft;
    fnameText.text = @"NAME";
    fnameText.font = [UIFont fontWithName:HEADER_FONT size:9];
    fnameText.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    fnameText.backgroundColor = self.view.backgroundColor;
    fnameText.editable = NO;
    [self.view addSubview:fnameText];
    
    CGRect firstNameFieldFrame = CGRectMake(screenFrame.size.width/2-textFieldWidth/2, fNameFieldY, textFieldWidth, textFieldHeight);
    firstNameField = [[UITextField alloc] initWithFrame:firstNameFieldFrame];
    firstNameField.delegate = self;
    firstNameField.placeholder = @"";
    firstNameField.borderStyle = UITextBorderStyleRoundedRect;
    firstNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    firstNameField.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:firstNameField];
    
    UITextView *emailText = [[UITextView alloc] initWithFrame:CGRectMake(screenFrame.size.width/2-textFieldWidth/2, fNameFieldY+fieldSpacing-24, 70, 30)];
    emailText.textAlignment = NSTextAlignmentLeft;
    emailText.text = @"EMAIL";
    emailText.font = [UIFont fontWithName:HEADER_FONT size:9];
    emailText.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    emailText.backgroundColor = self.view.backgroundColor;
    emailText.editable = NO;
    [self.view addSubview:emailText];
    
    CGRect emailFieldFrame = CGRectMake(screenFrame.size.width/2-textFieldWidth/2, fNameFieldY+fieldSpacing, textFieldWidth, textFieldHeight);
    emailField = [[UITextField alloc] initWithFrame:emailFieldFrame];
    emailField.delegate = self;
    emailField.placeholder = @"";
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.borderStyle = UITextBorderStyleRoundedRect;
    emailField.returnKeyType = UIReturnKeyNext;
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:emailField];
    
    UITextView *pwText = [[UITextView alloc] initWithFrame:CGRectMake(screenFrame.size.width/2-textFieldWidth/2, fNameFieldY+fieldSpacing*2-24, 70, 30)];
    pwText.textAlignment = NSTextAlignmentLeft;
    pwText.text = @"PASSWORD";
    pwText.font = [UIFont fontWithName:HEADER_FONT size:9];
    pwText.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    pwText.backgroundColor = self.view.backgroundColor;
    pwText.editable = NO;
    [self.view addSubview:pwText];
    
    CGRect pwFieldFrame = CGRectMake(screenFrame.size.width/2-textFieldWidth/2, fNameFieldY+fieldSpacing*2, textFieldWidth, textFieldHeight);
    pwField = [[UITextField alloc] initWithFrame:pwFieldFrame];
    pwField.delegate = self;
    pwField.placeholder = @"";
    pwField.secureTextEntry = YES;
    pwField.returnKeyType = UIReturnKeyNext;
    pwField.borderStyle = UITextBorderStyleRoundedRect;
    pwField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:pwField];
    
    UITextView *pwcText = [[UITextView alloc] initWithFrame:CGRectMake(screenFrame.size.width/2-textFieldWidth/2, fNameFieldY+fieldSpacing*3-24, 120, 30)];
    pwcText.textAlignment = NSTextAlignmentLeft;
    pwcText.text = @"CONFIRM PASSWORD";
    pwcText.font = [UIFont fontWithName:HEADER_FONT size:9];
    pwcText.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    pwcText.backgroundColor = self.view.backgroundColor;
    pwcText.editable = NO;
    [self.view addSubview:pwcText];
    
    CGRect pwConfirmFieldFrame = CGRectMake(screenFrame.size.width/2-textFieldWidth/2, fNameFieldY+fieldSpacing*3, textFieldWidth, textFieldHeight);
    pwConfirmField = [[UITextField alloc] initWithFrame:pwConfirmFieldFrame];
    pwConfirmField.placeholder = @"";
    pwConfirmField.delegate = self;
    pwConfirmField.secureTextEntry = YES;
    pwConfirmField.returnKeyType = UIReturnKeyGo;
    pwConfirmField.borderStyle = UITextBorderStyleRoundedRect;
    pwConfirmField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:pwConfirmField];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton addTarget:self
                    action:@selector(loginWasTouched)
          forControlEvents:UIControlEventTouchDown];
    [loginButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
    loginButton.frame = CGRectMake(screenFrame.size.width/2-textFieldWidth/4, fNameFieldY+fieldSpacing*3+70, textFieldWidth/2, 40);
    loginButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:12];
    loginButton.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    loginButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    [self.view addSubview:loginButton];
    [loginButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton addTarget:self
                    action:@selector(backWasTouched)
          forControlEvents:UIControlEventTouchDown];
    [backButton setTitle:@"BACK" forState:UIControlStateNormal];
    backButton.frame = CGRectMake(screenFrame.size.width/2-textFieldWidth/4, fNameFieldY+fieldSpacing*3+120, textFieldWidth/2, 40);
    backButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:12];
    //backButton.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    //backButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    [self.view addSubview:backButton];
    [backButton setTitleColor:[[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR] forState:UIControlStateNormal];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = self.view.frame;
    if (textField == firstNameField) {
    } else if (textField == emailField) {
    } else if (textField == pwField) {
        frame.origin.y = -120;
    } else if (textField == pwConfirmField) {
        frame.origin.y = -150;
    }
    self.view.frame = frame;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;
}

- (void)loginWasTouched
{
    [self.view endEditing:YES];
    
    if (![self fieldsAreValid]){
        if (!self.errViewIsShown) {
            TTLog(@"Error: not all required fields are present in signup data");
            self.errViewIsShown = YES;
            ErrorPromptViewController *errViewController = [[ErrorPromptViewController alloc] initWithPromptText:@"YOU DIDN'T FILL IN ALL THE FIELDS"];
            [self addChildViewController:errViewController];
            [self.view addSubview:errViewController.view];
            errViewController.errDelegate = self;
            errViewController.view.frame = errViewController.frame;
            [errViewController didMoveToParentViewController:self];
        }
    } else if (![self passwordsMatch]) {
        if (!self.errViewIsShown) {
            TTLog(@"Error: passwords don't match");
            self.errViewIsShown = YES;
            ErrorPromptViewController *errViewController = [[ErrorPromptViewController alloc] initWithPromptText:@"PASSWORDS DO NOT MATCH"];
            [self addChildViewController:errViewController];
            [self.view addSubview:errViewController.view];
            errViewController.errDelegate = self;
            errViewController.view.frame = errViewController.frame;
            [errViewController didMoveToParentViewController:self];
        }
    } else {
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
            if([((NSHTTPURLResponse *)res) statusCode] != 304 && [((NSHTTPURLResponse *)res) statusCode] != 400){
                NSError *jsonError = nil;
                NSDictionary *json = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                      error:&jsonError];
                TTLog(@"json response: %@", json);
                
                NSString *confCode = json[@"data"][@"conf_code"];
                self.userEmail = json[@"data"][@"email"];
                self.userPassword = pwField.text;
                
                signupCodeController = [[SignupCodeViewController alloc] initWithConfirmationCode:confCode];
                [self addChildViewController:signupCodeController];
                [self.view addSubview:signupCodeController.view];
                signupCodeController.view.frame = signupCodeController.frame;
                [signupCodeController didMoveToParentViewController:self];
                self.didSelectImage = YES;
            } else if ([((NSHTTPURLResponse *)res) statusCode] == 304) {
                if (!self.errViewIsShown) {
                    TTLog(@"Error: user with email %@ already exists", emailField.text);
                    self.errViewIsShown = YES;
                    ErrorPromptViewController *errViewController = [[ErrorPromptViewController alloc] initWithPromptText:@"A USER EXISTS WITH THAT EMAIL"];
                    [self addChildViewController:errViewController];
                    [self.view addSubview:errViewController.view];
                    errViewController.errDelegate = self;
                    errViewController.view.frame = errViewController.frame;
                    [errViewController didMoveToParentViewController:self];
                }
            } else if ([((NSHTTPURLResponse *)res) statusCode] == 400) {
                if (!self.errViewIsShown) {
                    TTLog(@"Error: 400");
                    self.errViewIsShown = YES;
                    ErrorPromptViewController *errViewController = [[ErrorPromptViewController alloc] initWithPromptText:@"THERE WAS AN ERROR"];
                    [self addChildViewController:errViewController];
                    [self.view addSubview:errViewController.view];
                    errViewController.errDelegate = self;
                    errViewController.view.frame = errViewController.frame;
                    [errViewController didMoveToParentViewController:self];
                }
            }
        } else if([url.path isEqualToString:@"/login"]){
            if([((NSHTTPURLResponse *)res) statusCode] == 200){
                NSError *jsonError = nil;
                NSDictionary *json = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                      error:&jsonError];
                TTLog(@"json response: %@", json);
                NSString *uid = json[@"data"][@"uid"];
                [[TTNetManager sharedInstance] loginToken:json[@"data"][@"access_token"]];
                [UserStore initCurrentUserWithImage:json[@"data"][@"profileImageID"]
                                           andEmail:self.userEmail
                                        andUserName:firstNameField.text
                                        andPassword:self.userPassword
                                          andUserID:uid];
            }
        }
    }
}

- (void)photoWasSelected:(UIImage *)selectedImage {}
- (void)photoWasSaved:(NSURL *)savedPhotoURL {
    TTLog(@"got image url: %@", savedPhotoURL);
    [signupCodeController removeSmoke];
    self.profLocalImageURL = [savedPhotoURL absoluteString];
    [TTNetManager sharedInstance].netDelegate = self;
    [[TTNetManager sharedInstance] loginUser:self.userEmail withPassword:self.userPassword andImage:self.profLocalImageURL];
}

- (void)continueWasTouched {
    UserStore *userStore = [[UserStore alloc] init];
    if (self.profLocalImageURL != nil && [userStore getAuthenticatedUser] != NULL){
        TTLog(@"Current access token: %@", [[TTNetManager sharedInstance] currentAccessToken]);
        UIViewController *viewController;
        viewController = [[FriendFeedViewController alloc] init];
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

-(void)backWasTouched
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^(void){}];
}

-(void)cancelWasTouched {
    [self backWasTouched];
}

- (BOOL) passwordsMatch {
    return [pwField.text isEqualToString:pwConfirmField.text];
}

- (BOOL) fieldsAreValid {
    if ([firstNameField.text isEqualToString:@""]){
        return NO;
    }
    if ([emailField.text isEqualToString:@""]){
        return NO;
    }
    if ([pwField.text isEqualToString:@""]){
        return NO;
    }
    if ([pwConfirmField.text isEqualToString:@""]){
        return NO;
    }
    return YES;
}

@end
