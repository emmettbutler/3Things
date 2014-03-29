//
//  LoginTypePickerViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/14/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "LoginTypePickerViewController.h"
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

	touchLock = NO;
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_YELLOW];
    
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [shareButton addTarget:self
                    action:@selector(doFBLogin:)
          forControlEvents:UIControlEventTouchDown];
    [shareButton setTitle:@"" forState:UIControlStateNormal];
    int fbButtonWidth = 230;
    shareButton.frame = CGRectMake(screenFrame.size.width/2-fbButtonWidth/2, 250, fbButtonWidth, 40.0);
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
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(screenFrame.size.width/2-logoWidth/2, 155, 240, 80)];
    [logoView setImage:[UIImage imageNamed:@"Three_Things_logo.png"]];
    [self.view addSubview:logoView];
}

- (void)doFBLogin:(id)sender
{
    if (!touchLock) {
        touchLock = YES;
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate openSession];
    }
}

-(BOOL)shouldShowNavBar {
    return NO;
}

@end
