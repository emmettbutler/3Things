//
//  My3ThingsViewController.h
//  3Things
//
//  Created by Emmett Butler on 9/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSharesAccessor.h"
#import "TTShareDay.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@interface My3ThingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithIsCurrent:(NSNumber *)isCurrent;
- (id)initWithShareDay:(TTShareDay *)shares;
- (id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent;

@property (nonatomic, retain) TTShareDay *shares;
@property (nonatomic) BOOL isCurrent;
@property (nonatomic, retain) TTSharesAccessor *accessor;
@property (nonatomic) CGRect screenFrame;
@property (nonatomic, retain) NSNumber *tableHeight;

@end
