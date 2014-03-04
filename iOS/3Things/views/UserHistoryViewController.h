//
//  UserHistoryViewController.h
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "TTNetManager.h"
#import "BottomNavViewController.h"

@interface UserHistoryViewController : UIViewController <UITableViewDataSource,
                                                         UITableViewDelegate,
                                                         BottomNavViewControllerDelegate,
                                                         TTNetManagerDelegate>

-(id)initWithPostedDay:(TTShareDay *)postedDay;
-(id)initWithPostedDay:(TTShareDay *)postedDay andMissed:(BOOL)missed;

@property (nonatomic) TTShareDay *postedDay;
@property (nonatomic, retain) NSArray *userHistory;
@property (nonatomic) CGRect screenFrame;
@property (nonatomic, retain) User *user;
@property (nonatomic) UISegmentedControl *segmentControl;
@property (nonatomic) BOOL multipleYears;
@property (nonatomic) BOOL startOnMissed;
@property (nonatomic) UITableView *tableView;
@property (nonatomic, retain) NSMutableDictionary *feedData;
@property (nonatomic, retain) NSNumber *tableHeight;

@end
