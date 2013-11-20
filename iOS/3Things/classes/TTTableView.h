//
//  TTView.h
//  3Things
//
//  Created by Emmett Butler on 11/19/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTTableView;
@protocol TTTableViewTouchDelegate <NSObject>
@required
- (void)tableTouchesEnded:(NSSet *)touches;
- (void)tableTouchesMoved:(NSSet *)touches;
- (void)tableTouchesBegan:(NSSet *)touches;
@end

id <TTTableViewTouchDelegate> touchDelegate;

@interface TTTableView : UITableView

@property (nonatomic, assign) id <TTTableViewTouchDelegate> touchDelegate;

@end
