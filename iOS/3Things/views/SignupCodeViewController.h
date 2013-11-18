//
//  SignupCodeViewController.h
//  3Things
//
//  Created by Emmett Butler on 9/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPromptViewController.h"

@interface SignupCodeViewController : UIViewController <PhotoPromptViewControllerDelegate, UITextFieldDelegate>
{
    UITextField *codeField;
    NSString *confirmationCode;
}

- (BOOL)codeIsValid;
- (id)initWithConfirmationCode:(NSString *)confCode;

@property (nonatomic) CGRect frame;
@property (nonatomic) BOOL photoPromptIsHidden;

@end
