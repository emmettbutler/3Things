//
//  SingleDayViewController.h
//  3Things
//
//  Created by Emmett Butler on 11/11/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTShareDay.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SingleDayViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

- (id)initWithIsCurrent:(NSNumber *)isCurrent;
- (id)initWithShareDay:(TTShareDay *)shares;
- (id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent;

@property (nonatomic) CGRect frame;
@property (nonatomic, retain) TTShareDay *shares;
@property (nonatomic) BOOL isCurrent;
@property (nonatomic) CGRect screenFrame;
@property (nonatomic, retain) NSNumber *tableHeight;
@property (nonatomic) NSNumber *completedThings;

@end
