//
//  LoginEmailViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/14/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "LoginEmailViewController.h"
#import "DayListViewController.h"
#import "My3ThingsViewController.h"
#import "UserStore.h"

@interface LoginEmailViewController ()

@end

@implementation LoginEmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton addTarget:self
                         action:@selector(loginWasTouched)
               forControlEvents:UIControlEventTouchDown];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    loginButton.frame = CGRectMake(0, 70, screenFrame.size.width, 40.0);
    [self.view addSubview:loginButton];
    
    CGRect idFieldFrame = CGRectMake(20.0f, screenFrame.size.height/2-100, 280.0f, 31.0f);
    idField = [[UITextField alloc] initWithFrame:idFieldFrame];
    idField.placeholder = @"Username or email";
    idField.autocorrectionType = UITextAutocorrectionTypeNo;
    idField.borderStyle = UITextBorderStyleRoundedRect;
    idField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:idField];
    
    CGRect pwFieldFrame = CGRectMake(20.0f, screenFrame.size.height/2-50, 280.0f, 31.0f);
    pwField = [[UITextField alloc] initWithFrame:pwFieldFrame];
    pwField.placeholder = @"Password";
    pwField.secureTextEntry = YES;
    pwField.borderStyle = UITextBorderStyleRoundedRect;
    pwField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:pwField];
}

- (void)loginWasTouched {
    NSLog(@"Login selected");
    if ([self loginIsValid]){
        [TTNetManager sharedInstance].netDelegate = self;
        [[TTNetManager sharedInstance] loginUser:idField.text withPassword:pwField.text];
    }
}

-(void)dataWasReceived:(NSURLResponse *)res withData:(NSData *)data andError:(NSError *)error andOriginURL:(NSURL *)url {
    if([((NSHTTPURLResponse *)res) statusCode] == 200){
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                              error:&jsonError];
        NSLog(@"json response: %@", json);
        
        [UserStore initCurrentUserWithImage:nil
                                   andEmail:nil
                                andUserName:[[json objectForKey:@"data"] objectForKey:@"name"]
                                andPassword:nil];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
