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
#import "AppDelegate.h"
#import "TTNetManager.h"
#import "My3ThingsViewController.h"

@interface LoginTypePickerViewController ()

@end

@implementation LoginTypePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_YELLOW];
    
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [shareButton addTarget:self
                    action:@selector(doFBLogin:)
          forControlEvents:UIControlEventTouchDown];
    [shareButton setTitle:@"" forState:UIControlStateNormal];
    int fbButtonWidth = 230;
    shareButton.frame = CGRectMake(screenFrame.size.width/2-fbButtonWidth/2, 150, fbButtonWidth, 40.0);
    shareButton.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_FACEBOOK];
    shareButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    UIView *buttonView = [[UIView alloc] init];
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Facebook_logo_white.png"]];
    logo.frame = CGRectMake(20, 5, 27, 27);
    [buttonView addSubview:logo];
    UITextView *buttonText = [[UITextView alloc] initWithFrame:CGRectMake(50, 4, 200, 30)];
    buttonText.text = @"SIGN IN WITH FACEBOOK";
    buttonText.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    buttonText.font = [UIFont fontWithName:HEADER_FONT size:12];
    buttonText.textColor = [UIColor colorWithWhite:1 alpha:1];
    [buttonView addSubview:buttonText];
    [shareButton addSubview:buttonView];
    [self.view addSubview:shareButton];
    
    int logoWidth = 240;
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(screenFrame.size.width/2-logoWidth/2, 55, 240, 80)];
    [logoView setImage:[UIImage imageNamed:@"Three_Things_logo.png"]];
    [self.view addSubview:logoView];
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 210, screenFrame.size.width, 60)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = @"OR DO IT THE OLD FASHIONED WAY";
    text.font = [UIFont fontWithName:HEADER_FONT size:11];
    text.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    text.backgroundColor = self.view.backgroundColor;
    text.editable = NO;
    [self.view addSubview:text];
    
    float textFieldWidth = screenFrame.size.width*.85, textFieldHeight = 35;
    
    int unameFieldY = 280;
    UITextView *unameText = [[UITextView alloc] initWithFrame:CGRectMake(screenFrame.size.width/2-textFieldWidth/2, unameFieldY-24, 70, 30)];
    unameText.textAlignment = NSTextAlignmentLeft;
    unameText.text = @"USERNAME";
    unameText.font = [UIFont fontWithName:HEADER_FONT size:9];
    unameText.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    unameText.backgroundColor = self.view.backgroundColor;
    unameText.editable = NO;
    [self.view addSubview:unameText];
    
    CGRect idFieldFrame = CGRectMake(screenFrame.size.width/2-textFieldWidth/2, unameFieldY, textFieldWidth, textFieldHeight);
    idField = [[UITextField alloc] initWithFrame:idFieldFrame];
    idField.placeholder = @"";
    idField.delegate = self;
    idField.font = [UIFont fontWithName:HEADER_FONT size:11];
    idField.returnKeyType = UIReturnKeyNext;
    idField.autocorrectionType = UITextAutocorrectionTypeNo;
    idField.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    idField.borderStyle = UITextBorderStyleRoundedRect;
    idField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:idField];
    
    int pwFieldY = 340;
    UITextView *pwText = [[UITextView alloc] initWithFrame:CGRectMake(screenFrame.size.width/2-textFieldWidth/2, pwFieldY-24, 70, 30)];
    pwText.textAlignment = NSTextAlignmentLeft;
    pwText.text = @"PASSWORD";
    pwText.font = [UIFont fontWithName:HEADER_FONT size:9];
    pwText.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    pwText.backgroundColor = self.view.backgroundColor;
    pwText.editable = NO;
    [self.view addSubview:pwText];
    
    CGRect pwFieldFrame = CGRectMake(screenFrame.size.width/2-textFieldWidth/2, pwFieldY, textFieldWidth, textFieldHeight);
    pwField = [[UITextField alloc] initWithFrame:pwFieldFrame];
    pwField.placeholder = @"";
    pwField.delegate = self;
    pwField.font = [UIFont fontWithName:HEADER_FONT size:11];
    pwField.returnKeyType = UIReturnKeyGo;
    pwField.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    pwField.secureTextEntry = YES;
    pwField.borderStyle = UITextBorderStyleRoundedRect;
    pwField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:pwField];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton addTarget:self
                    action:@selector(loginWasTouched)
          forControlEvents:UIControlEventTouchDown];
    [loginButton setTitle:@"SIGN IN" forState:UIControlStateNormal];
    loginButton.frame = CGRectMake(screenFrame.size.width/2-textFieldWidth/2, pwFieldY+70, textFieldWidth/2, 40);
    loginButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:12];
    loginButton.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    loginButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    [self.view addSubview:loginButton];
    [loginButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
    
    UIButton *newAccountButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [newAccountButton addTarget:self
                         action:@selector(newAccountWasTouched)
               forControlEvents:UIControlEventTouchDown];
    [newAccountButton setTitle:@"I NEED AN ACCOUNT" forState:UIControlStateNormal];
    newAccountButton.frame = CGRectMake(150, pwFieldY+75, 170, 30.0);
    newAccountButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:11];
    [self.view addSubview:newAccountButton];
    [newAccountButton setTitleColor:[[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR] forState:UIControlStateNormal];
}

- (void)doFBLogin:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate openSession];
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

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = self.view.frame;
    frame.origin.y = -216;
    self.view.frame = frame;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;
}

- (void)loginWasTouched {
    [pwField resignFirstResponder];
    [idField resignFirstResponder];
    if ([self loginIsValid]){
        [TTNetManager sharedInstance].netDelegate = self;
        [[TTNetManager sharedInstance] loginUser:idField.text withPassword:pwField.text andImage:nil];
    } else {
        if (!self.errViewIsShown) {
            TTLog(@"Error: not all required fields are present in signin data");
            self.errViewIsShown = YES;
            ErrorPromptViewController *errViewController = [[ErrorPromptViewController alloc] initWithPromptText:@"Please fill in all fields"];
            [self addChildViewController:errViewController];
            [self.view addSubview:errViewController.view];
            errViewController.errDelegate = self;
            errViewController.view.frame = errViewController.frame;
            [errViewController didMoveToParentViewController:self];
        }
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
