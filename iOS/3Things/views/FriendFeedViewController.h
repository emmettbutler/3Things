//
//  FriendFeedViewController.h
//  3Things
//
//  Created by Emmett Butler on 9/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomNavViewController.h"
#import "TTNetManager.h"
#import "FriendSearchViewController.h"

@interface FriendFeedViewController : UIViewController <UITableViewDataSource,
                                                        UITableViewDelegate,
                                                        BottomNavViewControllerDelegate,
                                                        TTNetManagerDelegate,
                                                        UITextFieldDelegate,
                                                        FriendSearchViewControllerDelegate>
{
    UITextField *searchBox;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSDictionary *feedData;
@property (nonatomic, retain) NSMutableArray *parsedFeed;
@property (nonatomic, retain) FriendSearchViewController *searchViewController;

@end
