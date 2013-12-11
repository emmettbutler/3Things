//
//  BottomNavViewController.h
//  3Things
//
//  Created by Emmett Butler on 10/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class BottomNavViewController;
@protocol BottomNavViewControllerDelegate <NSObject>
@required
- (void)reviewWasTouched;
- (void)friendsWasTouched;
- (void)calendarWasTouched;
@end

id <BottomNavViewControllerDelegate> navDelegate;

@interface BottomNavViewController : UIViewController
{
    UIImageView *calImageView;
    UITextView *calTextView;
}

@property (nonatomic) CGRect frame;
@property (nonatomic) CGRect screenFrame;
@property (nonatomic, assign) id <BottomNavViewControllerDelegate> navDelegate;

@end
