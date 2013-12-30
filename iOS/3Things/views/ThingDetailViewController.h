//
//  ThingDetailViewController.h
//  3Things
//
//  Created by Emmett Butler on 10/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTNetManager.h"

@interface ThingDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TTNetManagerDelegate>

@property (nonatomic) CGRect screenFrame;
@property (nonatomic) NSDictionary *thing;
@property (nonatomic) NSDictionary *commentData;
@property (nonatomic) UITableView *tableView;

- (id)initWithThing:(NSDictionary *)inThing;

@end
