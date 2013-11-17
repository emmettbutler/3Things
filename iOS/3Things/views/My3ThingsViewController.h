//
//  My3ThingsViewController.h
//  3Things
//
//  Created by Emmett Butler on 9/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTShareDay.h"
#import "ErrorPromptViewController.h"
#import "ErrorThrowingViewController.h"
#import "SingleDayViewController.h"
#import "User.h"
#import "TTNetManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@interface My3ThingsViewController : ErrorThrowingViewController <ErrorPromptViewControllerDelegate>

- (id)initWithIsCurrent:(NSNumber *)isCurrent;
- (id)initWithShareDay:(TTShareDay *)shares;
- (id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent andUser:(User *)user;
- (id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent andUser:(User *)user andIsEdited:(NSNumber *)isEdited;
- (id)initWithShareDay:(TTShareDay *)shares andIsEdited:(NSNumber *)isEdited;

@property (nonatomic, retain) TTShareDay *shares;
@property (nonatomic) BOOL isCurrent;
@property (nonatomic) BOOL isEdited;
@property (nonatomic) CGRect screenFrame;
@property (nonatomic, retain) NSNumber *tableHeight;
@property (nonatomic) SingleDayViewController *dayView;
@property (nonatomic) User *user;

@end
