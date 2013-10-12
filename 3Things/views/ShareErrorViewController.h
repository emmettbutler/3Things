//
//  ShareErrorViewController.h
//  3Things
//
//  Created by Emmett Butler on 10/12/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareErrorViewController;
@protocol ShareErrorViewControllerDelegate <NSObject>
@optional
- (void)dismissWasTouched;
@end

id <ShareErrorViewControllerDelegate> errDelegate;

@interface ShareErrorViewController : UIViewController

@property (nonatomic, assign) id <ShareErrorViewControllerDelegate> errDelegate;
@property (nonatomic) CGRect frame;

@end
