//
//  SignupCodeViewController.m
//  3Things
//
//  Created by Emmett Butler on 9/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "SignupCodeViewController.h"
#import "FriendFeedViewController.h"
#import "My3ThingsViewController.h"
#import "UserStore.h"
#import "SplashViewController.h"

@interface SignupCodeViewController ()

@end

@implementation SignupCodeViewController

-(id)initWithConfirmationCode:(NSString *)confCode{
    if (self = [super init]){
        confirmationCode = confCode;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    float width = 240, height = 140;
    self.frame = CGRectMake((screenRect.size.width/2)-width/2, (screenRect.size.height/2)-height/2, width, height);
    
    smoke = [[UIView alloc] initWithFrame:screenRect];
    smoke.backgroundColor = [UIColor colorWithWhite:0 alpha:.7];
    [self.parentViewController.view addSubview:smoke];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(confirmWasTouched)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"CHOOSE PROFILE PHOTO" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, screenRect.size.height/6, self.frame.size.width, 40.0);
    button.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:12];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:button];
    [button setTitleColor:[[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR] forState:UIControlStateNormal];
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 60)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = @"ENTER YOUR CONFIRMATION CODE";
    text.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    text.font = [UIFont fontWithName:HEADER_FONT size:12];
    text.backgroundColor = self.view.backgroundColor;
    text.editable = NO;
    [self.view addSubview:text];
    
    float fieldWidth = 160;
    CGRect codeFieldFrame = CGRectMake(self.frame.size.width/2-fieldWidth/2, screenRect.size.height/6-50, fieldWidth, 31.0f);
    codeField = [[UITextField alloc] initWithFrame:codeFieldFrame];
    codeField.placeholder = @"######";
    codeField.delegate = self;
    codeField.font = [UIFont fontWithName:HEADER_FONT size:12];
    codeField.returnKeyType = UIReturnKeyGo;
    codeField.autocorrectionType = UITextAutocorrectionTypeNo;
    codeField.borderStyle = UITextBorderStyleRoundedRect;
    codeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:codeField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self confirmWasTouched];
    return YES;
}

- (void)continueWasTouched {
    [(SplashViewController*)self.parentViewController continueWasTouched];
}

- (void)confirmWasTouched {
    if (![self codeIsValid]) {
        TTLog(@"Invalid signup code");
        return;
    }
    [self.view endEditing:YES];
    PhotoPromptViewController *promptViewController = [[PhotoPromptViewController alloc] init];
    promptViewController.promptDelegate = (SplashViewController*)self.parentViewController;
    [self.parentViewController addChildViewController:promptViewController];
    [self.parentViewController.view addSubview:promptViewController.view];
    promptViewController.view.frame = CGRectMake(0, self.frame.size.height+180, self.frame.size.width+20, 200);
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
    NSString *enteredCode = [codeField text];
    TTLog(@"Expected signup code: %@", confirmationCode);
    if ([enteredCode isEqualToString:confirmationCode]) {
        return YES;
    }
    return NO;
}

@end
