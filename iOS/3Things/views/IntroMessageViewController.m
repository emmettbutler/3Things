//
//  IntroMessageViewController.m
//  3Things
//
//  Created by Emmett Butler on 2/19/14.
//  Copyright (c) 2014 Emmett Butler. All rights reserved.
//

#import "IntroMessageViewController.h"
#import "TTNetManager.h"
#import "AppDelegate.h"
#import "FriendFeedViewController.h"
#import "LoginTypePickerViewController.h"

@interface IntroMessageViewController ()

@end

@implementation IntroMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"336766"];
    self.screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
    UIButton *bgButton = [[UIButton alloc] initWithFrame:self.screenFrame];
    bgButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    [bgButton addTarget:self
                 action:@selector(continueWasTouched)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bgButton];
    
    UIImageView *quoteImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IntroScreen_without_Background.png"]];
    float height = self.screenFrame.size.width*1.1;
    quoteImg.frame = CGRectMake(self.screenFrame.size.width*.05, self.screenFrame.size.height/2-height/2, self.screenFrame.size.width*.9, height);
    [self.view addSubview:quoteImg];
}

- (void)continueWasTouched {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSString *storedToken = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%d", kAccessToken]];
    TTLog(@"Stored token: %@", storedToken);
    if (storedToken != NULL ||
        FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            TTLog(@"Facebook session found");
        }
        // get the stored access token from defauls, put it in TTNetManager's memory, re-save it
        [[TTNetManager sharedInstance] loginToken:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d", kAccessToken]]];
        self.viewController = [[FriendFeedViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
        [self presentViewController:navController animated:YES completion:NULL];
    } else {
        [self presentViewController:[[LoginTypePickerViewController alloc] init] animated:YES completion:NULL];
    }
}

@end
