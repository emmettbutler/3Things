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
#import "ErrorPromptViewController.h"
#import "ErrorThrowingViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@interface My3ThingsViewController : ErrorThrowingViewController <UITableViewDataSource, UITableViewDelegate, ErrorPromptViewControllerDelegate>

- (id)initWithIsCurrent:(NSNumber *)isCurrent;
- (id)initWithShareDay:(TTShareDay *)shares;
- (id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent;

@property (nonatomic, retain) TTShareDay *shares;
@property (nonatomic) BOOL isCurrent;
@property (nonatomic, retain) TTSharesAccessor *accessor;
@property (nonatomic) CGRect screenFrame;
@property (nonatomic, retain) NSNumber *tableHeight;
@property (nonatomic) NSNumber *completedThings;

@end
