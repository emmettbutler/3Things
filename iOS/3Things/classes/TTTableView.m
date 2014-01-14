//
//  TTTableView.m
//  3Things
//
//  Created by Emmett Butler on 1/14/14.
//  Copyright (c) 2014 Emmett Butler. All rights reserved.
//

#import "TTTableView.h"
#import "TTNetManager.h"
#import "TTCollectionView.h"

@implementation TTTableView

// to re-enable feed element selection at daily granularity, comment this method and set the tableview's allowsSelection to YES

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    TTLog(@"Touch in custom table");
    UITouch *touch = [touches anyObject];
    TTCollectionView *collectionView = (TTCollectionView*)(((UIView*)((UIView*)touch.view.superview.subviews[0]).subviews[0]).subviews[2]);
    [collectionView touchesEnded:touches withEvent:event];
    //[self.nextResponder touchesEnded:touches withEvent:event];
}

@end
