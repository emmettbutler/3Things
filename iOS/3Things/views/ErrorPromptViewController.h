//
//  ErrorPromptViewController.h
//  3Things
//
//  Created by Emmett Butler on 10/12/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ErrorPromptViewController;
@protocol ErrorPromptViewControllerDelegate <NSObject>
@optional
- (void)dismissWasTouched;
- (BOOL)shouldShowNavBar;
@end

id <ErrorPromptViewControllerDelegate> errDelegate;

@interface ErrorPromptViewController : UIViewController
{
    UIView *smoke;
}

-(id)initWithPromptText:(NSString *)promptText;

@property (nonatomic, assign) id <ErrorPromptViewControllerDelegate> errDelegate;
@property (nonatomic) CGRect frame;
@property (nonatomic) NSString *promptText;

@end
