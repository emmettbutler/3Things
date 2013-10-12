//
//  SplashViewController.h
//  3Things
//
//  Created by Emmett Butler on 9/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorThrowingViewController.h"

@class SignupCodeViewController;

@interface SplashViewController : ErrorThrowingViewController <UITextFieldDelegate>
{
    SignupCodeViewController *signupCodeViewController;
    UITextField *firstNameField, *lastNameField, *emailField;
}

-(BOOL) fieldsAreValid;

@end
