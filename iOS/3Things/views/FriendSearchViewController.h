//
//  FriendSearchViewController.h
//  3Things
//
//  Created by Emmett Butler on 11/13/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTNetManager.h"

@protocol FriendFeedViewControllerDelegate;

@class FriendSearchViewController;
@protocol FriendSearchViewControllerDelegate <NSObject>
@optional
- (void)dismissSearchWasTouched;
@end

id <FriendSearchViewControllerDelegate> searchDelegate;

@interface FriendSearchViewController : UIViewController <UITableViewDataSource,
                                                          UITableViewDelegate,
                                                          TTNetManagerDelegate,
                                                          FriendFeedViewControllerDelegate>
{
    int lastSearchTime;
}

@property (nonatomic) CGRect frame;
@property (nonatomic, assign) id <FriendSearchViewControllerDelegate> searchDelegate;
@property (nonatomic) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *friendData;
@property (nonatomic, retain) UIView *inviteView;

@end
