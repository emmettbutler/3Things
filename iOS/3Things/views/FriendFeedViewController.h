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

@interface FriendFeedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, BottomNavViewControllerDelegate, TTNetManagerDelegate>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSDictionary *feedData;
@property (nonatomic, retain) NSMutableArray *parsedFeed;

@end
