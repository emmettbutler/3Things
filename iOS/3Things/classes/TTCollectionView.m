//
//  TTCollectionView.m
//  3Things
//
//  Created by Emmett Butler on 1/14/14.
//  Copyright (c) 2014 Emmett Butler. All rights reserved.
//

#import "TTCollectionView.h"
#import "TTNetManager.h"

@implementation TTCollectionView

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
     * Manually route touches to the appropriate collectionviewcell in a single day view
     */
    UITouch *touch = [touches anyObject];
    UIView *firstSubview = ((UIView*)touch.view.superview.subviews[0]);
    NSArray *subviews = firstSubview.subviews;
    UIView *view;
    if (((UIView *)subviews[0]).tag == FLAG_TAG) {
        TTLog(@"Touch view first subview is flag");
        // this view is not inside a tableview
        view = touch.view.superview.superview;
    } else {
        UIView *secondSubview = firstSubview.subviews[0];
        view = secondSubview.subviews[2];
    }
    if ([view isKindOfClass:[TTCollectionView class]]) {
        TTLog(@"View is a TTCollectionView");
        TTCollectionView *collection = (TTCollectionView*)view;
        NSArray *subviews = collection.subviews;
        int i;
        for (i = 0; i < 3; i++) {
            if (CGRectContainsPoint(((UIView*)subviews[i]).frame, [touch locationInView:((UIView*)subviews[0]).superview])) {
                TTLog(@"Touched collectionview index %d", i);
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [collection.delegate collectionView:collection didSelectItemAtIndexPath:indexPath];
                break;
            }
        }
    }
}

@end
