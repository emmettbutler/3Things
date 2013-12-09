//
//  LoginTypePickerViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/14/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "LoginTypePickerViewController.h"
#import "SplashViewController.h"
#import "UserStore.h"
#import "FriendFeedViewController.h"
#import "My3ThingsViewController.h"

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
    [shareButton setTitle:@"Sign in with Facebook" forState:UIControlStateNormal];
    shareButton.frame = CGRectMake(0, 240, screenFrame.size.width, 40.0);
    [self.view addSubview:shareButton];
    
    UIButton *newAccountButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [newAccountButton addTarget:self
                    action:@selector(newAccountWasTouched)
          forControlEvents:UIControlEventTouchDown];
    [newAccountButton setTitle:@"I need an account" forState:UIControlStateNormal];
    newAccountButton.frame = CGRectMake(0, 290, screenFrame.size.width, 40.0);
    [self.view addSubview:newAccountButton];
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 140, screenFrame.size.width, 60)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = @"THREE THINGS";
    text.font = [UIFont systemFontOfSize:23];
    text.backgroundColor = self.view.backgroundColor;
    text.editable = NO;
    [self.view addSubview:text];

    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton addTarget:self
                    action:@selector(loginWasTouched)
          forControlEvents:UIControlEventTouchDown];
    [loginButton setTitle:@"SIGN IN" forState:UIControlStateNormal];
    loginButton.frame = CGRectMake(0, 70, screenFrame.size.width, 40.0);
    [self.view addSubview:loginButton];
    
    CGRect idFieldFrame = CGRectMake(20.0f, screenFrame.size.height/2-100, 280.0f, 31.0f);
    idField = [[UITextField alloc] initWithFrame:idFieldFrame];
    idField.placeholder = @"Username or email";
    idField.delegate = self;
    idField.returnKeyType = UIReturnKeyNext;
    idField.autocorrectionType = UITextAutocorrectionTypeNo;
    idField.borderStyle = UITextBorderStyleRoundedRect;
    idField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [idField becomeFirstResponder];
    [self.view addSubview:idField];
    
    CGRect pwFieldFrame = CGRectMake(20.0f, screenFrame.size.height/2-50, 280.0f, 31.0f);
    pwField = [[UITextField alloc] initWithFrame:pwFieldFrame];
    pwField.placeholder = @"Password";
    pwField.delegate = self;
    pwField.returnKeyType = UIReturnKeyGo;
    pwField.secureTextEntry = YES;
    pwField.borderStyle = UITextBorderStyleRoundedRect;
    pwField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:pwField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == idField){
        [idField resignFirstResponder];
        [pwField becomeFirstResponder];
    } else if (theTextField == pwField) {
        [self loginWasTouched];
    }
    return YES;
}

- (void)loginWasTouched {
    if ([self loginIsValid]){
        [TTNetManager sharedInstance].netDelegate = self;
        [[TTNetManager sharedInstance] loginUser:idField.text withPassword:pwField.text andImage:nil];
    }
}

-(void)dataWasReceived:(NSURLResponse *)res withData:(NSData *)data andError:(NSError *)error andOriginURL:(NSURL *)url {
    if([((NSHTTPURLResponse *)res) statusCode] == 200){
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                              error:&jsonError];
        TTLog(@"json response: %@", json);
        NSString *uid = [[json objectForKey:@"data"] objectForKey:@"uid"];
        
        [[TTNetManager sharedInstance] loginToken:[[json objectForKey:@"data"] objectForKey:@"access_token"]];
        [UserStore initCurrentUserWithImage:[[json objectForKey:@"data"] objectForKey:@"profileImageID"]
                                   andEmail:idField.text
                                andUserName:[[json objectForKey:@"data"] objectForKey:@"name"]
                                andPassword:nil
                                  andUserID:uid];
        [self setModalPresentationStyle:UIModalPresentationPageSheet];
        UIViewController *viewController;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d", kDayComplete]] boolValue] == YES) {
            viewController = [[FriendFeedViewController alloc] init];
        } else {
            UserStore *userStore = [[UserStore alloc] init];
            viewController = [[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] init] andIsCurrent:[NSNumber numberWithBool:YES] andUser:[userStore getAuthenticatedUser]];
        }
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self presentViewController:navController animated:YES completion:NULL];
    }
}

-(BOOL) loginIsValid {
    if ([pwField.text isEqualToString:@""]){
        return NO;
    }
    if ([idField.text isEqualToString:@""]){
        return NO;
    }
    return YES;
}

- (void)newAccountWasTouched
{
    [self setModalPresentationStyle:UIModalPresentationPageSheet];
    UIViewController *viewController = [[SplashViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:NULL];
}

@end
