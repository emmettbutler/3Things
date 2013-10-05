//
//  SplashViewController.h
//  3Things
//
//  Created by Emmett Butler on 9/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SignupCodeViewController;

@interface SplashViewController : UIViewController <UITextFieldDelegate>
{
    SignupCodeViewController *signupCodeViewController;
}

@end
