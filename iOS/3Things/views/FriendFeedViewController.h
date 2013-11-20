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
#import "TTTableView.h"
#import "FriendSearchViewController.h"

@class FriendFeedViewController;
@protocol FriendFeedViewControllerDelegate <NSObject>
@optional
- (void)searchQueryChanged:(NSString *)text;
@end

id <FriendFeedViewControllerDelegate> feedDelegate;

@interface FriendFeedViewController : UIViewController <UITableViewDataSource,
                                                        UITableViewDelegate,
                                                        BottomNavViewControllerDelegate,
                                                        TTNetManagerDelegate,
                                                        UITextFieldDelegate,
                                                        FriendSearchViewControllerDelegate,
                                                        TTTableViewTouchDelegate>
{
    UITextField *searchBox;
    BOOL dragging;
    float oldY, touchLastY;
}

@property (nonatomic, retain) TTTableView *tableView;
@property (nonatomic, retain) NSDictionary *feedData;
@property (nonatomic, retain) NSMutableArray *parsedFeed;
@property (nonatomic, assign) id <FriendFeedViewControllerDelegate> feedDelegate;
@property (nonatomic, retain) FriendSearchViewController *searchViewController;

@end
