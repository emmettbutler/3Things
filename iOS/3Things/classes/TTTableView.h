//
//  TTView.h
//  3Things
//
//  Created by Emmett Butler on 11/19/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTView;
@protocol TTViewTouchDelegate <NSObject>
@required
- (void)tableTouchesEnded:(NSSet *)touches;
- (void)tableTouchesMoved:(NSSet *)touches;
- (void)tableTouchesBegan:(NSSet *)touches;
@end

id <TTViewTouchDelegate> touchDelegate;

@interface TTView : UIView

@property (nonatomic, assign) id <TTViewTouchDelegate> touchDelegate;

@end
