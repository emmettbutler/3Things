//
//  UserHistoryViewController.h
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "BottomNavViewController.h"

@interface UserHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, BottomNavViewControllerDelegate>

@property (nonatomic, retain) NSArray *userHistory;
@property (nonatomic) CGRect screenFrame;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSNumber *tableHeight;

@end
