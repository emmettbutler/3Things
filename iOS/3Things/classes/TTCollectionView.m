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

/*
 * WARNING
 * 
 * THIS MEANS YOU
 *
 * If you use this class, every single touch event that hits your instance will be sent to this method
 * This class is here only to manually handle touch events that are meant for collectionViews that are
 * nested inside of the friend feed tableview. It's highly unlikely that this class will work with any
 * other nesting of views.
 *
 * You probably should not use this class.
 */

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
        // this view is not inside a tableview - ie this touch did not originate on a tableviewcell
        view = touch.view.superview.superview;
    } else {
        // this path assumes a very specific nesting of views containing the collectionView
        // if this view hierarchy changes, this needs to as well.
        UIView *secondSubview = firstSubview.subviews[0];
        view = secondSubview.subviews[2];
    }
    // if this condition is ever not true then the whole assumption of the above lines is wrong
    // by this point, view should be the TTCollectionView
    assert([view isKindOfClass:[TTCollectionView class]]);
    if ([view isKindOfClass:[TTCollectionView class]]) {
        TTCollectionView *collection = (TTCollectionView*)view;
        NSArray *subviews = collection.subviews;
        int i;
        for (i = 0; i < 3; i++) {
            // determine the indexPath by getting the touch's location in the collectionview
            if (CGRectContainsPoint(((UIView*)subviews[i]).frame, [touch locationInView:collection])) {
                TTLog(@"Touched collectionview index %d", i);
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [collection.delegate collectionView:collection didSelectItemAtIndexPath:indexPath];
                break;
            }
        }
    }
}

@end
