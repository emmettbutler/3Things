//
//  SplashViewController.h
//  3Things
//
//  Created by Emmett Butler on 9/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPromptViewController.h"
#import "ErrorThrowingViewController.h"
#import "TTNetManager.h"

@class SignupCodeViewController;

@interface SplashViewController : ErrorThrowingViewController <UITextFieldDelegate, PhotoPromptViewControllerDelegate, TTNetManagerDelegate>
{
    SignupCodeViewController *signupCodeController;
    UITextField *firstNameField, *lastNameField, *emailField, *pwField, *pwConfirmField;
}

@property (nonatomic) NSString *profLocalImageURL;
@property (nonatomic) BOOL didSelectImage;

-(BOOL) fieldsAreValid;
-(void)continueWasTouched;

@end
