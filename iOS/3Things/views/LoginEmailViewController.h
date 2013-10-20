//
//  LoginEmailViewController.h
//  3Things
//
//  Created by Emmett Butler on 10/14/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginEmailViewController : UIViewController
{
    UITextField *idField, *pwField;
}

-(BOOL) loginIsValid;

@end
