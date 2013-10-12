//
//  ErrorThrowingViewController.h
//  3Things
//
//  Created by Emmett Butler on 10/12/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorPromptViewController.h"

@interface ErrorThrowingViewController : UIViewController <ErrorPromptViewControllerDelegate>

@property (nonatomic) BOOL errViewIsShown;

@end
