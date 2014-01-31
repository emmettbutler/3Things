//
//  ThingDetailViewController.h
//  3Things
//
//  Created by Emmett Butler on 10/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTNetManager.h"

@interface ThingDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TTNetManagerDelegate, UITextFieldDelegate>
{
    float textFieldOriginalY, pastCommentsOriginalY, pastCommentsOriginalHeight;
    int commentHeight, commentWidth, commentViewMargins;
}

@property (nonatomic) CGRect screenFrame;
@property (nonatomic) NSDictionary *thing;
@property (nonatomic) NSMutableDictionary *commentData;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIImageView *picView;
@property (nonatomic) UITextField *commentField;
@property (nonatomic) UITextView *text;

- (id)initWithThing:(NSDictionary *)inThing;

@end
