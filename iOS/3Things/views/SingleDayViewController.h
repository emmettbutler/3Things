//
//  SingleDayViewController.h
//  3Things
//
//  Created by Emmett Butler on 11/11/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTShareDay.h"
#import "User.h"
#import "TTNetManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SingleDayViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, TTNetManagerDelegate>

- (id)initWithIsCurrent:(NSNumber *)isCurrent;
- (id)initWithShareDay:(TTShareDay *)shares;
- (id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent andUser:(User *)user;
- (id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent andUser:(User *)user andIsEdited:(NSNumber *)isEdited;

@property (nonatomic) CGRect frame;
@property (nonatomic, retain) TTShareDay *shares;
@property (nonatomic) BOOL isCurrent;
@property (nonatomic) BOOL isEdited;
@property (nonatomic) CGRect screenFrame;
@property (nonatomic) NSDictionary *feedData;
@property (nonatomic, retain) NSNumber *tableHeight;
@property (nonatomic) NSNumber *completedThings;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) User *user;

@end
