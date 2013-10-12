//
//  SignupCodeViewController.h
//  3Things
//
//  Created by Emmett Butler on 9/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupCodeViewController : UIViewController
{
    UITextField *codeField;
}

- (BOOL)codeIsValid;

@property (nonatomic) CGRect frame;

@end
